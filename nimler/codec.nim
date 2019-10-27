import tables
import options
import bindings/erl_nif

export options

type ErlAtom* = tuple[val: string]
type ErlString* = string
type ErlTuple* = varargs[ErlNifTerm]
type ErlList* = seq[ErlNifTerm]
type ErlResult* = tuple[rtype: ErlAtom, rval: ErlNifTerm]
type ErlBinary* = ErlNifBinary
type ErlMap* = Table[ErlNifTerm, ErlNifTerm]

const AtomOk*: ErlAtom = (val: "ok")
const AtomErr*: ErlAtom = (val: "error")
const AtomTrue*: ErlAtom = (val: "true")
const AtomFalse*: ErlAtom = (val: "false")

proc ResultOk*(rval: ErlNifTerm): ErlResult = cast[ErlResult]((AtomOk, rval))
proc ResultErr*(rval: ErlNifTerm): ErlResult = cast[ErlResult]((AtomErr, rval))

# ErlNifTerm represented as uint64, for which there is already a hash()
# proc hash*(term: ErlNifTerm): Hash = return cast[Hash](enif_hash(ERL_NIF_PHASH2, term))

########## int ##########
proc decode*(term: ErlNifTerm, env: ptr ErlNifEnv, T: typedesc[int]): Option[T] =
  return decode(term, env, int64)

proc encode*(V: int, env: ptr ErlNifEnv): ErlNifTerm =
  return enif_make_int64(env, V)

########## int32 ##########
proc decode*(term: ErlNifTerm, env: ptr ErlNifEnv, T: typedesc[int32]): Option[T] =
  var res: clong
  if not enif_get_long(env, term, addr(res)):
    return none(T)
  return some(cast[int32](res))

proc encode*(V: int32, env: ptr ErlNifEnv): ErlNifTerm =
  return enif_make_long(env, V)

########## uint32 ##########
proc decode*(term: ErlNifTerm, env: ptr ErlNifEnv, T: typedesc[uint32]): Option[T] =
  var res: culong
  if not enif_get_ulong(env, term, addr(res)):
    return none(T)
  return some(cast[uint32](res))

proc encode*(V: uint32, env: ptr ErlNifEnv): ErlNifTerm =
  return enif_make_ulong(env, V)

########## uint64 ##########
proc decode*(term: ErlNifTerm, env: ptr ErlNifEnv, T: typedesc[uint64]): Option[T] =
  var res: culonglong
  if not enif_get_uint64(env, term, addr(res)):
    return none(T)
  return some(cast[uint64](res))

proc encode*(V: uint64, env: ptr ErlNifEnv): ErlNifTerm =
  return enif_make_uint64(env, V)

########## float64 ##########
proc decode*(term: ErlNifTerm, env: ptr ErlNifEnv, T: typedesc[float64]): Option[T] =
  var res: cdouble
  if not enif_get_double(env, term, addr(res)):
    return none(T)
  return some(cast[float64](res))

proc encode*(V: float64, env: ptr ErlNifEnv): ErlNifTerm =
  return enif_make_double(env, V)

########## ErlAtom ##########
proc decode*(term: ErlNifTerm, env: ptr ErlNifEnv, T: typedesc[ErlAtom]): Option[T] =
  var atom_len: cuint
  if not enif_get_atom_length(env, term, addr(atom_len), ERL_NIF_LATIN1):
    return none(T)
  let buf_len = atom_len + 1
  var atom: ErlAtom = (val: newStringOfCap(atom_len))
  if not enif_get_atom(env, term, addr(atom.val[0]), buf_len, ERL_NIF_LATIN1) == cint(buf_len):
    return none(T)
  setLen(atom.val, atom_len)
  return some(atom)

proc encode*(V: ErlAtom, env: ptr ErlNifEnv): ErlNifTerm =
  return enif_make_atom(env, V.val)

########## ErlString ##########
proc decode*(term: ErlNifTerm, env: ptr ErlNifEnv, T: typedesc[ErlString]): Option[T] =
  var string_len: cuint
  if not enif_get_list_length(env, term, addr(string_len)):
    return none(T)
  let buf_len = string_len + 1
  var string_buf = newStringOfCap(string_len)
  if not enif_get_string(env, term, addr(string_buf[0]), buf_len, ERL_NIF_LATIN1) == cint(buf_len):
    return none(T)
  setLen(string_buf, string_len)
  return some(string_buf)

proc encode*(V: ErlString, env: ptr ErlNifEnv): ErlNifTerm =
  return enif_make_string(env, V, ERL_NIF_LATIN1)

########## ErlBinary ##########
proc decode*(term: ErlNifTerm, env: ptr ErlNifEnv, T: typedesc[ErlBinary]): Option[T] =
  var bin: ErlNifBinary
  if not enif_inspect_binary(env, term, addr(bin)):
    return none(T)
  return some(bin)

proc encode*(V: ErlBinary, env: ptr ErlNifEnv): ErlNifTerm =
  return enif_make_binary(env, unsafeAddr(V))

########## ErlTuple ##########
proc encode*(V: ErlTuple, env: ptr ErlNifEnv): ErlNifTerm =
  return enif_make_tuple_from_array(env, V)

########## ErlList ##########
proc encode*(V: ErlList, env: ptr ErlNifEnv): ErlNifTerm =
  return enif_make_list_from_array(env, V)

########## ErlResult ##########
proc encode*(V: ErlResult, env: ptr ErlNifEnv): ErlNifTerm =
  return encode(enif_make_atom(env, V.rtype.val), V.rval, env)

########## ErlMap ##########
proc encode*(V: ErlMap, env: ptr ErlNifEnv): ErlNifTerm =
  var map = enif_make_new_map(env)
  for k, v in pairs(V):
    if not enif_make_map_put(env, map, k, v, addr(map)):
      discard enif_raise_exception(env, "nimler: fail to encode map from table".encode(env))
  return map

########## object field pairs ##########
proc encode*(V: object, env: ptr ErlNifEnv): ErlNifTerm =
  var map = enif_make_new_map(env)
  for k, v in fieldPairs(V):
    var key: ErlNifTerm = ErlAtom((val: $k)).encode(env)
    var value: ErlNifTerm = v.encode(env)
    if not enif_make_map_put(env, map, key, value, addr(map)):
      discard enif_raise_exception(env, "nimler: fail to encode map from field pairs".encode(env))
  return map


