import macros
import typetraits
import tables
import sequtils
import hashes
import bindings/erl_nif

import options
export options

type ErlAtom* = object
  val*: string
type ErlCharlist* = seq[char]
type ErlBinary* = ErlNifBinary

proc hash*(a: ErlAtom): Hash =
  result = a.val.hash
  result = !$result

const AtomOk* = ErlAtom(val: "ok")
const AtomErr* = ErlAtom(val: "error")
const AtomTrue* = ErlAtom(val: "true")
const AtomFalse* = ErlAtom(val: "false")
const ExceptionMapEncode*: ErlCharlist = "nimler: fail to encode map".toSeq()
const ExceptionStringEncode*: ErlCharlist = "nimler: fail to encode string".toSeq()

macro generic_params*(T: typedesc): untyped =
  result = newNimNode(nnkTupleConstr)
  var impl = getTypeImpl(T)
  expectKind(impl, nnkBracketExpr)
  impl = impl[1]
  while true:
    case impl.kind
      of nnkSym:
        impl = impl.getImpl
        continue
      of nnkTypeDef:
        impl = impl[2]
        continue
      of nnkBracketExpr:
        for i in 1..<impl.len:
          result.add impl[i]
        break
      else:
        error "wrong kind: " & $impl.kind

# int
proc decode*(term: ErlNifTerm, env: ptr ErlNifEnv, T: typedesc[int]): Option[T] =
  var res: clonglong
  if enif_get_int64(env, term, addr(res)):
    return some(res.int)
proc encode*(V: int, env: ptr ErlNifEnv): ErlNifTerm =
  return enif_make_int64(env, V)

# int32
proc decode*(term: ErlNifTerm, env: ptr ErlNifEnv, T: typedesc[int32]): Option[T] =
  var res: clong
  if enif_get_long(env, term, addr(res)):
    return some(res.int32)
proc encode*(V: int32, env: ptr ErlNifEnv): ErlNifTerm =
  return enif_make_long(env, V)

# uint32
proc decode*(term: ErlNifTerm, env: ptr ErlNifEnv, T: typedesc[uint32]): Option[T] =
  var res: culong
  if enif_get_ulong(env, term, addr(res)):
    return some(res.uint32)
proc encode*(V: uint32, env: ptr ErlNifEnv): ErlNifTerm =
  return enif_make_ulong(env, V)
# uint64
proc decode*(term: ErlNifTerm, env: ptr ErlNifEnv, T: typedesc[uint64]): Option[T] =
  var res: culonglong
  if enif_get_uint64(env, term, addr(res)):
    return some(res.uint64)
proc encode*(V: uint64, env: ptr ErlNifEnv): ErlNifTerm =
  return enif_make_uint64(env, V)

# float
proc decode*(term: ErlNifTerm, env: ptr ErlNifEnv, T: typedesc[float]): Option[T] =
  var res: cdouble
  if enif_get_double(env, term, addr(res)):
    return some(res.float)
proc encode*(V: float, env: ptr ErlNifEnv): ErlNifTerm =
  return enif_make_double(env, V)

# atom
proc decode*(term: ErlNifTerm, env: ptr ErlNifEnv, T: typedesc[ErlAtom]): Option[T] =
  var atom_len: cuint
  if not enif_get_atom_length(env, term, addr(atom_len), ERL_NIF_LATIN1):
    return none(T)
  let buf_len = atom_len + 1
  var atom = ErlAtom(val: newString(atom_len))
  if enif_get_atom(env, term, addr(atom.val[0]), buf_len, ERL_NIF_LATIN1) == cint(buf_len):
    return some(atom)
proc encode*(V: ErlAtom, env: ptr ErlNifEnv): ErlNifTerm =
  var res: ErlNifTerm
  if not enif_make_existing_atom(env, V.val, addr(res), ERL_NIF_LATIN1):
    return enif_make_atom(env, V.val)
  return res

# charlist
proc decode*(term: ErlNifTerm, env: ptr ErlNifEnv, T: typedesc[ErlCharlist]): Option[T] =
  var string_len: cuint
  if not enif_get_list_length(env, term, addr(string_len)):
    return none(T)
  let buf_len = string_len + 1
  var string_buf = newSeq[char](string_len)
  if enif_get_string(env, term, addr(string_buf[0]), buf_len, ERL_NIF_LATIN1) == cint(buf_len):
    return some(string_buf)
proc encode*(V: ErlCharlist, env: ptr ErlNifEnv): ErlNifTerm =
  return enif_make_string(env, cast[string](V), ERL_NIF_LATIN1)
template decode*(env: ptr ErlNifEnv, term: ErlNifTerm, T: typedesc[ErlCharlist]): Option[T] =
  decode(term, env, T)
template encode*(env: ptr ErlNifEnv, V: ErlCharlist): ErlNifTerm =
  encode(V, env)

# string
proc bin_to_str(bin: ErlNifBinary): string =
  result = newString(bin.size)
  copyMem(addr(result[0]), bin.data, bin.size)
proc str_to_bin(str: string): ErlNifBinary =
  result.size = cast[csize_t](str.len)
  result.data = cast[ptr cuchar](unsafeAddr(str[0]))
proc decode*(term: ErlNifTerm, env: ptr ErlNifEnv, T: typedesc[string]): Option[T] =
  var bin: ErlNifBinary
  if not enif_inspect_binary(env, term, addr(bin)):
    return none(T)
  return some(bin_to_str(bin))
proc encode*(V: string, env: ptr ErlNifEnv): ErlNifTerm =
  var bin = str_to_bin(V)
  return enif_make_binary(env, addr(bin))

# binary
proc decode*(term: ErlNifTerm, env: ptr ErlNifEnv, T: typedesc[ErlBinary]): Option[T] =
  var bin: ErlNifBinary
  if enif_inspect_binary(env, term, addr(bin)):
    return some(bin)
proc encode*(V: ErlBinary, env: ptr ErlNifEnv): ErlNifTerm =
  return enif_make_binary(env, unsafeAddr(V))

# list
proc decode_list_cell*(term: ErlNifTerm, env: ptr ErlNifEnv): Option[tuple[head: ErlNifTerm, tail:ErlNifTerm]] =
  var head, tail: ErlNifTerm
  if enif_get_list_cell(env, term, addr(head), addr(tail)):
    return some((head, tail))
proc decode*(term: ErlNifTerm, env: ptr ErlNifEnv, T: typedesc[seq]): Option[T] =
  var res: T
  type el_type = type(res[0])
  var list = term.decode_list_cell(env)
  while list.isSome():
    var cell = list.get()
    var head = cell[0].decode(env, el_type)
    var tail = cell[1]
    if head.isNone():
      return none(T)
    res.add(head.get())
    list = tail.decode_list_cell(env)
  return some(res)
proc encode*(V: seq, env: ptr ErlNifEnv): ErlNifTerm =
  var v = newSeq[ErlNifTerm](V.len)
  for i, el in V: v[i] = el.encode(env)
  return enif_make_list_from_array(env, v)

# tuple
proc decode*(term: ErlNifTerm, env: ptr ErlNifEnv, T: typedesc[tuple]): Option[T] =
  var tup: ptr UncheckedArray[ErlNifTerm]
  var arity: cuint
  if not enif_get_tuple(env, term, addr(arity), addr(tup)):
    return none(T)
  if arity.int < T.arity:
    return none(T)
  var res: T
  var ind = 0
  for field in res.fields:
    let val = tup[ind].decode(env, type(field))
    if val.isNone():
      return none(T)
    field = val.get()
    inc(ind)
  return some(res)
macro encode*(V: tuple, env: ptr ErlNifEnv): untyped =
  let tup_len = V.getTypeImpl().len
  result = newCall("enif_make_tuple", env, newLit(tup_len))
  for i in 0 ..< tup_len:
    let v = quote do: `V`[`i`]
    result.add(newCall("encode", v, env))
# map/table
proc decode*(term: ErlNifTerm, env: ptr ErlNifEnv, T: typedesc[Table]): Option[T] =
  type key_type = codec.generic_params(T).get(0)
  type val_type = codec.generic_params(T).get(1)
  var res: Table[key_type, val_type]
  var iter: ErlNifMapIterator
  var key, val: ErlNifTerm
  if not enif_map_iterator_create(env, term, addr(iter), ERL_NIF_MAP_ITERATOR_FIRST):
    return none(T)
  while enif_map_iterator_get_pair(env, addr(iter), addr(key), addr(val)):
    let key_d = key.decode(env, key_type)
    let val_d = val.decode(env, val_type)
    if key_d.isNone() or val_d.isNone():
      enif_map_iterator_destroy(env, addr(iter))
      return none(T)
    res[key_d.get()] = val_d.get()
    discard enif_map_iterator_next(env, addr(iter))
  enif_map_iterator_destroy(env, addr(iter))
  return some(res)
proc encode*(V: Table, env: ptr ErlNifEnv): ErlNifTerm =
  var map = enif_make_new_map(env)
  for k, v in V:
    let key = k.encode(env)
    let value = v.encode(env)
    if not enif_make_map_put(env, map, key, value, addr(map)):
      discard enif_raise_exception(env, ExceptionMapEncode.encode(env))
  return map

# result
proc ok*(env: ptr ErlNifEnv, rterm: ErlNifTerm): ErlNifTerm =
  return enif_make_tuple(env, 2, AtomOk.encode(env), rterm)
proc error*(env: ptr ErlNifEnv, rterm: ErlNifTerm): ErlNifTerm =
  return enif_make_tuple(env, 2, AtomErr.encode(env), rterm)

template decode*(env: ptr ErlNifEnv, term: ErlNifTerm, T: typedesc[int]): Option[T] =
  decode(term, env, T)
template encode*(env: ptr ErlNifEnv, V: int): ErlNifTerm =
  encode(V, env)
template decode*(env: ptr ErlNifEnv, term: ErlNifTerm, T: typedesc[int32]): Option[T] =
  decode(term, env, T)
template encode*(env: ptr ErlNifEnv, V: int32): ErlNifTerm =
  encode(V, env)
template decode*(env: ptr ErlNifEnv, term: ErlNifTerm, T: typedesc[uint32]): Option[T] =
  decode(term, env, T)
template encode*(env: ptr ErlNifEnv, V: uint32): ErlNifTerm =
  encode(V, env)
template decode*(env: ptr ErlNifEnv, term: ErlNifTerm, T: typedesc[uint64]): Option[T] =
  decode(term, env, T)
template encode*(env: ptr ErlNifEnv, V: uint64): ErlNifTerm =
  encode(V, env)
template decode*(env: ptr ErlNifEnv, term: ErlNifTerm, T: typedesc[float]): Option[T] =
  decode(term, env, T)
template encode*(env: ptr ErlNifEnv, V: float): ErlNifTerm =
  encode(V, env)
template decode*(env: ptr ErlNifEnv, term: ErlNifTerm, T: typedesc[ErlAtom]): Option[T] =
  decode(term, env, T)
template encode*(env: ptr ErlNifEnv, V: ErlAtom): ErlNifTerm =
  encode(V, env)
template decode*(env: ptr ErlNifEnv, term: ErlNifTerm, T: typedesc[string]): Option[T] =
  decode(term, env, T)
template encode*(env: ptr ErlNifEnv, V: string): ErlNifTerm =
  encode(V, env)
template decode*(env: ptr ErlNifEnv, term: ErlNifTerm, T: typedesc[ErlBinary]): Option[T] =
  decode(term, env, T)
template encode*(env: ptr ErlNifEnv, V: ErlBinary): ErlNifTerm =
  encode(V, env)
template decode*(env: ptr ErlNifEnv, term: ErlNifTerm, T: typedesc[seq]): Option[T] =
  decode(term, env, T)
template encode*(env: ptr ErlNifEnv, V: seq): ErlNifTerm =
  encode(V, env)
template decode*(env: ptr ErlNifEnv, term: ErlNifTerm, T: typedesc[tuple]): Option[T] =
  decode(term, env, T)
template encode*(env: ptr ErlNifEnv, V: tuple): ErlNifTerm =
  encode(V, env)
template decode*(env: ptr ErlNifEnv, term: ErlNifTerm, T: typedesc[Table]): Option[T] =
  decode(term, env, T)
template encode*(env: ptr ErlNifEnv, V: Table): ErlNifTerm =
  encode(V, env)
template ok*(rterm: ErlNifTerm, env: ptr ErlNifEnv): ErlNifTerm =
  ok(env, rterm)
template error*(rterm: ErlNifTerm, env: ptr ErlNifEnv): ErlNifTerm =
  error(env, rterm)

