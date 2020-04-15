import macros
import typetraits
import tables
import hashes
import bindings/erl_nif

import options
export options

using
  env: ptr ErlNifEnv
  term: ErlNifTerm

type
  ErlAtom* = object
    val*: string
  ErlCharlist* = seq[char]
  ErlBinary* = ErlNifBinary

const AtomOk* = ErlAtom(val: "ok")
const AtomError* = ErlAtom(val: "error")
const AtomTrue* = ErlAtom(val: "true")
const AtomFalse* = ErlAtom(val: "false")
const ExceptionMapEncode* = @"nimler: fail to encode map"

macro generic_params(T: typedesc): untyped =
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

proc hash*(a: ErlAtom): Hash =
  result = a.val.hash
  result = !$result

# int
proc from_term*(env; term; T: typedesc[int]): Option[T] =
  var res: clonglong
  if enif_get_int64(env, term, addr(res)):
    result = some(res.int)
proc to_term*(env; V: int): ErlNifTerm =
  enif_make_int64(env, V)

# int32
proc from_term*(env; term; T: typedesc[int32]): Option[T] =
  var res: clong
  if enif_get_long(env, term, addr(res)):
    result = some(res.int32)
proc to_term*(env; V: int32): ErlNifTerm =
  enif_make_long(env, V)

# uint32
proc from_term*(env; term; T: typedesc[uint32]): Option[T] =
  var res: culong
  if enif_get_ulong(env, term, addr(res)):
    result = some(res.uint32)
proc to_term*(env; V: uint32): ErlNifTerm =
  enif_make_ulong(env, V)

# uint64
proc from_term*(env; term; T: typedesc[uint64]): Option[T] =
  var res: culonglong
  if enif_get_uint64(env, term, addr(res)):
    result = some(res.uint64)
proc to_term*(env; V: uint64): ErlNifTerm =
  enif_make_uint64(env, V)

# float
proc from_term*(env; term; T: typedesc[float]): Option[T] =
  var res: cdouble
  if enif_get_double(env, term, addr(res)):
    result = some(res.float)
proc to_term*(env; V: float): ErlNifTerm =
  enif_make_double(env, V)

# atom
proc from_term*(env; term; T: typedesc[ErlAtom]): Option[T] =
  var atom_len: cuint
  if enif_get_atom_length(env, term, addr(atom_len), ERL_NIF_LATIN1):
    let buf_len = atom_len + 1
    var atom = ErlAtom(val: newString(atom_len))
    if enif_get_atom(env, term, addr(atom.val[0]), buf_len, ERL_NIF_LATIN1) == cint(buf_len):
      result = some(atom)
proc to_term*(env; V: ErlAtom): ErlNifTerm =
  var res: ErlNifTerm
  if enif_make_existing_atom(env, V.val, addr(res), ERL_NIF_LATIN1):
    result = res
  else:
    result = enif_make_atom(env, V.val)

# charlist
proc from_term*(env; term; T: typedesc[ErlCharlist]): Option[T] =
  var string_len: cuint
  if enif_get_list_length(env, term, addr(string_len)):
    let buf_len = string_len + 1
    var string_buf = newSeq[char](string_len)
    if enif_get_string(env, term, addr(string_buf[0]), buf_len, ERL_NIF_LATIN1) == cint(buf_len):
      result = some(string_buf)
proc to_term*(env; V: ErlCharlist): ErlNifTerm =
  # XXX Wonder what happens with characters outside ERL_NIF_LATIN1
  enif_make_string(env, cast[string](V), ERL_NIF_LATIN1)

# string
proc bin_to_str(bin: ErlNifBinary): string {.inline.} =
  result = newString(bin.size)
  copyMem(addr(result[0]), bin.data, result.len)
proc str_to_bin(str: string): ErlNifBinary {.inline.} =
  result.size = cast[csize_t](str.len)
  result.data = cast[ptr cuchar](unsafeAddr(str[0]))
proc from_term*(env; term; T: typedesc[string]): Option[T] =
  var bin: ErlNifBinary
  if enif_inspect_binary(env, term, addr(bin)):
    result = some(bin_to_str(bin))
proc to_term*(env; V: string): ErlNifTerm =
  var bin = str_to_bin(V)
  result = enif_make_binary(env, addr(bin))

# binary
proc from_term*(env; term; T: typedesc[ErlBinary]): Option[T] =
  var bin: ErlNifBinary
  if enif_inspect_binary(env, term, addr(bin)):
    result = some(bin)
proc to_term*(env; V: ErlBinary): ErlNifTerm =
  enif_make_binary(env, unsafeAddr(V))

# list
proc from_term*(env; term; T: typedesc[seq]): Option[T] =
  if not enif_is_list(env, term):
    return none(T)
  var res: T
  var cursor = term
  var head, tail: ErlNifTerm
  type el_type = codec.generic_params(T).get(0)
  while enif_get_list_cell(env, cursor, addr(head), addr(tail)):
    var head_d = env.from_term(head, el_type)
    if head_d.isNone():
      return none(T)
    res.add(move(head_d.get()))
    cursor = tail
  return some(res)
proc to_term*(env; V: seq): ErlNifTerm =
  var v = newSeqOfCap[ErlNifTerm](V.len)
  for el in V:
    v.add(env.to_term(el))
  result = enif_make_list_from_array(env, move(v))

# tuple
proc from_term*(env; term; T: typedesc[tuple]): Option[T] =
  var tup: ptr UncheckedArray[ErlNifTerm]
  var arity: cuint
  if not enif_get_tuple(env, term, addr(arity), addr(tup)):
    return none(T)
  if arity.int < T.arity:
    return none(T)
  var res: T
  var ind = 0
  for field in res.fields:
    let val = env.from_term(tup[ind], type(field))
    if val.isNone():
      return none(T)
    field = val.get()
    inc(ind)
  return some(res)
macro to_term*(env; V: tuple): untyped =
  let tup_len = V.getTypeImpl().len
  result = newCall("enif_make_tuple", env, newLit(tup_len))
  for i in 0 ..< tup_len:
    let v = quote do: `V`[`i`]
    result.add(newCall("to_term", env, v))

# map/table
proc from_term*(env; term; T: typedesc[Table]): Option[T] =
  type key_type = codec.generic_params(T).get(0)
  type val_type = codec.generic_params(T).get(1)
  var res: Table[key_type, val_type]
  var iter: ErlNifMapIterator
  var key, val: ErlNifTerm
  if not enif_map_iterator_create(env, term, addr(iter), ERL_NIF_MAP_ITERATOR_FIRST):
    return none(T)
  while enif_map_iterator_get_pair(env, addr(iter), addr(key), addr(val)):
    let key_d = env.from_term(key, key_type)
    let val_d = env.from_term(val, val_type)
    if key_d.isNone() or val_d.isNone():
      enif_map_iterator_destroy(env, addr(iter))
      return none(T)
    res[key_d.get()] = val_d.get()
    discard enif_map_iterator_next(env, addr(iter))
  enif_map_iterator_destroy(env, addr(iter))
  return some(res)
proc to_term*(env; V: Table): ErlNifTerm =
  var keys = newSeqOfCap[ErlNifTerm](V.len)
  var vals = newSeqOfCap[ErlNifTerm](V.len)
  for k, v in V:
    keys.add(env.to_term(k))
    vals.add(env.to_term(v))
  var map: ErlNifTerm
  if not enif_make_map_from_arrays(env, addr(keys[0]), addr(vals[0]), cuint(keys.len), addr(map)):
    return enif_raise_exception(env, env.to_term(ExceptionMapEncode))
  return map

# result
template result_tuple*(env; res_type: ErlnifTerm; terms: varargs[ErlNifTerm]): ErlNifTerm =
  var result_tup: array[1 + terms.len, ErlNifTerm]
  result_tup[0] = res_type
  result_tup[1 .. result_tup.high] = terms
  enif_make_tuple_from_array(env, result_tup)
template ok*(env; terms: varargs[ErlNifTerm]): ErlNifTerm =
  result_tuple(env, env.to_term(AtomOk), terms)
template error*(env; terms: varargs[ErlNifTerm]): ErlNifTerm =
  result_tuple(env, env.to_term(AtomError), terms)

proc from_term*(term; env; T: typedesc[int]): Option[T] {.inline.} =
  from_term(env, term, T)
proc to_term*(V: int; env): ErlNifTerm {.inline.} =
  to_term(env, V)
proc from_term*(term; env; T: typedesc[int32]): Option[T] {.inline.} =
  from_term(env, term, T)
proc to_term*(V: int32; env): ErlNifTerm {.inline.} =
  to_term(env, V)
proc from_term*(term; env; T: typedesc[uint32]): Option[T] {.inline.} =
  from_term(env, term, T)
proc to_term*(V: uint32; env): ErlNifTerm {.inline.} =
  to_term(env, V)
proc from_term*(term; env; T: typedesc[uint64]): Option[T] {.inline.} =
  from_term(env, term, T)
proc to_term*(V: uint64; env): ErlNifTerm {.inline.} =
  to_term(env, V)
proc from_term*(term; env; T: typedesc[float]): Option[T] {.inline.} =
  from_term(env, term, T)
proc to_term*(V: float; env): ErlNifTerm {.inline.} =
  to_term(env, V)
proc from_term*(term; env; T: typedesc[ErlAtom]): Option[T] {.inline.} =
  from_term(env, term, T)
proc to_term*(V: ErlAtom; env): ErlNifTerm {.inline.} =
  to_term(env, V)
proc from_term*(term; env; T: typedesc[ErlCharlist]): Option[T] {.inline.} =
  from_term(env, term, T)
proc to_term*(V: ErlCharlist; env): ErlNifTerm {.inline.} =
  to_term(env, V)
proc from_term*(term; env; T: typedesc[string]): Option[T] {.inline.} =
  from_term(env, term, T)
proc to_term*(V: string; env): ErlNifTerm {.inline.} =
  to_term(env, V)
proc from_term*(term; env; T: typedesc[ErlBinary]): Option[T] {.inline.} =
  from_term(env, term, T)
proc to_term*(V: ErlBinary; env): ErlNifTerm {.inline.} =
  to_term(env, V)
proc from_term*(term; env; T: typedesc[seq]): Option[T] {.inline.} =
  from_term(env, term, T)
proc to_term*(V: seq; env): ErlNifTerm {.inline.} =
  to_term(env, V)
proc from_term*(term; env; T: typedesc[tuple]): Option[T] {.inline.} =
  from_term(env, term, T)
proc to_term*(V: tuple; env): ErlNifTerm {.inline.} =
  to_term(env, V)
proc from_term*(term; env; T: typedesc[Table]): Option[T] {.inline.} =
  from_term(env, term, T)
proc to_term*(V: Table; env): ErlNifTerm {.inline.} =
  to_term(env, V)
proc ok*(term; env): ErlNifTerm {.inline.} =
  ok(env, term)
proc error*(term; env): ErlNifTerm {.inline.} =
  error(env, term)

