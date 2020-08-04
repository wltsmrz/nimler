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
const AtomMapEncodeException = ErlAtom(val: "nimler: fail to encode map")

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

func hash*(a: ErlAtom): Hash {.inline.} =
  result = a.val.hash
  result = !$result

# int
func from_term*(env; term; T: typedesc[int]): Option[T] {.inline.} =
  var res: int
  if enif_get_long(env, term, addr(res)):
    result = some(res)

func to_term*(env; term: int): ErlNifTerm {.inline.} =
  enif_make_long(env, term)

# uint
func from_term*(env; term; T: typedesc[uint]): Option[T] {.inline.} =
  var res: uint
  if enif_get_ulong(env, term, addr(res)):
    result = some(res)

func to_term*(env; term: uint): ErlNifTerm {.inline.} =
  enif_make_ulong(env, term)

# int32
func from_term*(env; term; T: typedesc[int32]): Option[T] {.inline.} =
  var res: clong
  if enif_get_long(env, term, addr(res)):
    result = some(res.int32)

func to_term*(env; term: int32): ErlNifTerm {.inline.} =
  enif_make_long(env, term)

# uint32
func from_term*(env; term; T: typedesc[uint32]): Option[T] {.inline.} =
  var res: culong
  if enif_get_ulong(env, term, addr(res)):
    result = some(res.uint32)

func to_term*(env; term: uint32): ErlNifTerm {.inline.} =
  enif_make_ulong(env, term)
  
# int64
func from_term*(env; term; T: typedesc[int64]): Option[T] {.inline.} =
  var res: int64
  if enif_get_int64(env, term, addr(res)):
    result = some(res)

func to_term*(env; term: int64): ErlNifTerm {.inline.} =
  enif_make_int64(env, term)

# uint64
func from_term*(env; term; T: typedesc[uint64]): Option[T] {.inline.} =
  var res: uint64
  if enif_get_uint64(env, term, addr(res)):
    result = some(res)

func to_term*(env; term: uint64): ErlNifTerm {.inline.} =
  enif_make_uint64(env, term)

# float
func from_term*(env; term; T: typedesc[float]): Option[T] {.inline.} =
  var res: float
  if enif_get_double(env, term, addr(res)):
    result = some(res)

func to_term*(env; term: float): ErlNifTerm {.inline.} =
  enif_make_double(env, term)

# atom
func from_term*(env; term; T: typedesc[ErlAtom]): Option[T] {.inline.} =
  var atom_len: cuint
  if enif_get_atom_length(env, term, addr(atom_len), ERL_NIF_LATIN1):
    let buf_len = atom_len + 1
    var atom = ErlAtom(val: newString(atom_len))
    if enif_get_atom(env, term, addr(atom.val[0]), buf_len, ERL_NIF_LATIN1) == cint(buf_len):
      result = some(atom)

func to_term*(env; V: ErlAtom): ErlNifTerm {.inline.} =
  var res: ErlNifTerm
  if enif_make_existing_atom_len(env, V.val, len(V.val).csize_t, addr(res)):
    result = res
  else:
    result = enif_make_atom_len(env, V.val, len(V.val).csize_t)

# charlist
func from_term*(env; term; T: typedesc[ErlCharlist]): Option[T] {.inline.} =
  var string_len: cuint
  if enif_get_list_length(env, term, addr(string_len)):
    let buf_len = string_len + 1
    var string_buf = newSeq[char](string_len)
    if enif_get_string(env, term, addr(string_buf[0]), buf_len, ERL_NIF_LATIN1) == cint(buf_len):
      result = some(string_buf)

func to_term*(env; V: ErlCharlist): ErlNifTerm {.inline.} =
  enif_make_string_len(env, V, ERL_NIF_LATIN1)

# string
func bin_to_str(bin: ErlNifBinary): string {.inline.} =
  result = newString(bin.size)
  copyMem(addr(result[0]), bin.data, result.len)

func from_term*(env; term; T: typedesc[string]): Option[T] {.inline.} =
  var bin: ErlNifBinary
  if enif_inspect_binary(env, term, addr(bin)):
    result = some(bin_to_str(bin))

func to_term*(env; V: string): ErlNifTerm {.inline.} =
  var term: ErlNifTerm
  var bin = cast[ptr byte](enif_make_new_binary(env, len(V).csize_t, term.addr))
  copyMem(bin, unsafeAddr(V[0]), len(V))
  result = term

# binary
func from_term*(env; term; T: typedesc[ErlBinary]): Option[T] {.inline.} =
  var bin: ErlNifBinary
  if enif_inspect_binary(env, term, addr(bin)):
    result = some(bin)

func to_term*(env; V: ErlBinary): ErlNifTerm {.inline.} =
  enif_make_binary(env, unsafeAddr(V))

# list
func from_term*(env; term; T: typedesc[seq]): Option[T] {.inline.} =
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

func to_term*(env; V: seq): ErlNifTerm {.inline.} =
  var v = newSeqOfCap[ErlNifTerm](V.len)
  for el in V:
    v.add(env.to_term(el))
  result = enif_make_list_from_array(env, move(v))

# tuple
func from_term*(env; term; T: typedesc[tuple]): Option[T] =
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

macro to_term*(env: typed; V: tuple): untyped =
  case V.kind:
    of nnkSym:
      let tup_len = V.getTypeImpl().len
      result = newCall("enif_make_tuple", env, newLit(tup_len))
      for i in 0 ..< tup_len:
        let v = quote do: `V`[`i`]
        result.add(newCall("to_term", env, v))
    of nnkTupleConstr:
      result = quote do:
        let erl_tup = `V`
        to_term(env, erl_tup)
    else:
      error "wrong kind: " & $V.kind

# map/table
func from_term*(env; term; T: typedesc[Table]): Option[T] =
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

func to_term*(env; V: Table): ErlNifTerm =
  var keys, vals = newSeqOfCap[ErlNifTerm](len(V))
  for k, v in V:
    keys.add(env.to_term(k))
    vals.add(env.to_term(v))
  var map: ErlNifTerm
  if not enif_make_map_from_arrays(env, addr(keys[0]), addr(vals[0]), cuint(keys.len), addr(map)):
    return enif_raise_exception(env, env.to_term(AtomMapEncodeException))
  return map

# result
template result_tuple*(env; res_type: ErlnifTerm; terms: varargs[ErlNifTerm]): untyped =
  enif_make_tuple_from_array(env, res_type & @terms)

template ok*(env; terms: varargs[ErlNifTerm]): untyped =
  result_tuple(env, env.to_term(AtomOk), terms)

template error*(env; terms: varargs[ErlNifTerm]): untyped =
  result_tuple(env, env.to_term(AtomError), terms)

