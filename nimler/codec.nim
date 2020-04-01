import macros
import typetraits
import options
import tables
import bindings/erl_nif

export options

type ErlAtom* = object
  val*: string
type ErlBinary* = ErlNifBinary

const AtomOk* = ErlAtom(val: "ok")
const AtomErr* = ErlAtom(val: "error")
const AtomTrue* = ErlAtom(val: "true")
const AtomFalse* = ErlAtom(val: "false")

# int
proc decode*(term: ErlNifTerm, env: ptr ErlNifEnv, T: typedesc[int]): Option[T] =
  var res: clonglong
  if not enif_get_int64(env, term, addr(res)):
    return none(T)
  return some(res.int)

proc encode*(V: int, env: ptr ErlNifEnv): ErlNifTerm =
  return enif_make_int64(env, V)

# int32
proc decode*(term: ErlNifTerm, env: ptr ErlNifEnv, T: typedesc[int32]): Option[T] =
  var res: clong
  if not enif_get_long(env, term, addr(res)):
    return none(T)
  return some(res.int32)

proc encode*(V: int32, env: ptr ErlNifEnv): ErlNifTerm =
  return enif_make_long(env, V)

# uint32
proc decode*(term: ErlNifTerm, env: ptr ErlNifEnv, T: typedesc[uint32]): Option[T] =
  var res: culong
  if not enif_get_ulong(env, term, addr(res)):
    return none(T)
  return some(res.uint32)

proc encode*(V: uint32, env: ptr ErlNifEnv): ErlNifTerm =
  return enif_make_ulong(env, V)

# uint64
proc decode*(term: ErlNifTerm, env: ptr ErlNifEnv, T: typedesc[uint64]): Option[T] =
  var res: culonglong
  if not enif_get_uint64(env, term, addr(res)):
    return none(T)
  return some(res.uint64)

proc encode*(V: uint64, env: ptr ErlNifEnv): ErlNifTerm =
  return enif_make_uint64(env, V)

# float
proc decode*(term: ErlNifTerm, env: ptr ErlNifEnv, T: typedesc[float]): Option[T] =
  var res: cdouble
  if not enif_get_double(env, term, addr(res)):
    return none(T)
  return some(res.float)

proc encode*(V: float, env: ptr ErlNifEnv): ErlNifTerm =
  return enif_make_double(env, V)

# atom
proc decode*(term: ErlNifTerm, env: ptr ErlNifEnv, T: typedesc[ErlAtom]): Option[T] =
  var atom_len: cuint
  if not enif_get_atom_length(env, term, addr(atom_len), ERL_NIF_LATIN1):
    return none(T)
  var atom = ErlAtom(val: newString(atom_len))
  let buf_len = atom_len + 1
  if not enif_get_atom(env, term, addr(atom.val[0]), buf_len, ERL_NIF_LATIN1) == cint(buf_len):
    return none(T)
  return some(atom)

proc encode*(V: ErlAtom, env: ptr ErlNifEnv): ErlNifTerm =
  return enif_make_atom(env, V.val)

# string
proc decode*(term: ErlNifTerm, env: ptr ErlNifEnv, T: typedesc[string]): Option[T] =
  var string_len: cuint
  if not enif_get_list_length(env, term, addr(string_len)):
    return none(T)
  var string_buf = newString(string_len)
  var buf_len = string_len + 1
  if not enif_get_string(env, term, addr(string_buf[0]), buf_len, ERL_NIF_LATIN1) == cint(buf_len):
    return none(T)
  return some(string_buf)

proc encode*(V: string, env: ptr ErlNifEnv): ErlNifTerm =
  return enif_make_string(env, V, ERL_NIF_LATIN1)

# binary
proc decode*(term: ErlNifTerm, env: ptr ErlNifEnv, T: typedesc[ErlBinary]): Option[T] =
  var bin: ErlNifBinary
  if not enif_inspect_binary(env, term, addr(bin)):
    return none(T)
  return some(bin)

proc encode*(V: ErlBinary, env: ptr ErlNifEnv): ErlNifTerm =
  return enif_make_binary(env, unsafeAddr(V))

# list
proc decode_list_cell*(term: ErlNifTerm, env: ptr ErlNifEnv): Option[seq[ErlNifTerm]] =
  var head: ErlNifTerm
  var tail: ErlNifTerm
  if enif_get_list_cell(env, term, addr(head), addr(tail)):
    return some(@[head, tail])

proc decode*(term: ErlNifTerm, env: ptr ErlNifEnv, T: typedesc[seq]): Option[T] =
  var list_len: cuint
  if not enif_get_list_length(env, term, addr(list_len)):
    return none(T)
  var res: T
  res = newSeqOfCap[type(res[0])](list_len)
  var list = term.decode_list_cell(env)
  while list.isSome():
    var cell = list.get()
    var head = cell[0].decode(env, type(res[0]))
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
  var res: T
  var tup: ptr UncheckedArray[ErlNifTerm]
  var arity: cuint
  if not enif_get_tuple(env, term, addr(arity), addr(tup)):
    return none(T)
  var ind = 0
  for field in res.fields:
    let val = tup[ind].decode(env, type(field))
    if val.isNone():
      return none(T)
    field = val.get()
    inc(ind)
  return some(res)

macro encode_tuple*(env: ptr ErlNifEnv, tup: typed): untyped =
  let impl = tup.getTypeImpl()
  let tup_len = impl.len
  result = newCall("enif_make_tuple", env, newLit(tup_len))
  for i in 0 ..< tup_len:
    let v = quote do: `tup`[`i`]
    result.add(newCall("encode", v, env))

proc encode*(V: tuple, env: ptr ErlNifEnv): ErlNifTerm =
  return encode_tuple(env, V)

# object field pairs:map
proc encode*(V: object, env: ptr ErlNifEnv): ErlNifTerm =
  var map = enif_make_new_map(env)
  for k, v in fieldPairs(V):
    var key: ErlNifTerm = enif_make_atom(env, $k)
    var value: ErlNifTerm = v.encode(env)
    if not enif_make_map_put(env, map, key, value, addr(map)):
      discard enif_raise_exception(env, "nimler: fail to encode map from field pairs".encode(env))
  return map

# map/table
proc decode*(term: ErlNifTerm, env: ptr ErlNifEnv, T: typedesc[Table]): Option[T] =
  var type_tup: genericParams(T)
  var res = initTable[type(type_tup[0]), type(type_tup[1])](4)
  var iter: ErlNifMapIterator
  var key: ErlNifTerm
  var val: ErlNifTerm
  if not enif_map_iterator_create(env, term, addr(iter), ERL_NIF_MAP_ITERATOR_FIRST):
    return none(T)
  while enif_map_iterator_get_pair(env, addr(iter), addr(key), addr(val)):
    let key_d = key.decode(env, type(type_tup[0])).get()
    let val_d = val.decode(env, type(type_tup[1])).get()
    res[key_d] = val_d
    discard enif_map_iterator_next(env, addr(iter))
  enif_map_iterator_destroy(env, addr(iter))
  return some(res)

proc encode*(V: Table, env: ptr ErlNifEnv): ErlNifTerm =
  var map = enif_make_new_map(env)
  for k, v in V:
    let key = k.encode(env)
    let value = v.encode(env)
    discard enif_make_map_put(env, map, key, value, addr(map))
  return map

# result
proc ok*(env: ptr ErlNifEnv, rterm: ErlNifTerm): ErlNifTerm =
  return enif_make_tuple(env, 2, AtomOk.encode(env), rterm)

proc error*(env: ptr ErlNifEnv, rterm: ErlNifTerm): ErlNifTerm =
  return enif_make_tuple(env, 2, AtomErr.encode(env), rterm)
