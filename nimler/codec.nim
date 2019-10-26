import options
import bindings/erl_nif

export options

type ErlAtom* = tuple[val: string]
type ErlString* = string
type ErlTuple* = varargs[ErlNifTerm]
type ErlList* = seq[ErlNifTerm]
type ErlResult* = tuple[rtype: ErlAtom, rval: ErlNifTerm]
type ErlBinary* = ErlNifBinary
type ErlFloat64* = float64
type ErlUint64* = uint64

const AtomOk*: ErlAtom = (val: "ok")
const AtomErr*: ErlAtom = (val: "error")
const AtomTrue*: ErlAtom = (val: "true")
const AtomFalse*: ErlAtom = (val: "false")

proc ResultOk*(rval: ErlNifTerm): ErlResult = cast[ErlResult]((AtomOk, rval))
proc ResultErr*(rval: ErlNifTerm): ErlResult = cast[ErlResult]((AtomErr, rval))

########## int32, nim=int32 ##########
proc decode*(term: ErlNifTerm, env: ptr ErlNifEnv, T: typedesc[int32]): Option[T] =
  var res: clong
  if not enif_get_long(env, term, addr(res)):
    return none(T)
  return some(cast[int32](res))

proc encode*(V: int32, env: ptr ErlNifEnv): ErlNifTerm =
  return enif_make_long(env, V)

########## uint32, nim=uint32 ##########
proc decode*(term: ErlNifTerm, env: ptr ErlNifEnv, T: typedesc[uint32]): Option[T] =
  var res: culong
  if not enif_get_ulong(env, term, addr(res)):
    return none(T)
  return some(cast[uint32](res))

proc encode*(V: uint32, env: ptr ErlNifEnv): ErlNifTerm =
  return enif_make_ulong(env, V)

########## uint64, nim=uint64 ##########
proc decode*(term: ErlNifTerm, env: ptr ErlNifEnv, T: typedesc[ErlUint64]): Option[T] =
  var res: culonglong
  if not enif_get_uint64(env, term, addr(res)):
    return none(T)
  return some(cast[uint64](res))

proc encode*(V: ErlUint64, env: ptr ErlNifEnv): ErlNifTerm =
  return enif_make_uint64(env, V)

########## float64, nim=float64 ##########
proc decode*(term: ErlNifTerm, env: ptr ErlNifEnv, T: typedesc[ErlFloat64]): Option[T] =
  var res: cdouble
  if not enif_get_double(env, term, addr(res)):
    return none(T)
  return some(cast[float64](res))

proc encode*(V: ErlFloat64, env: ptr ErlNifEnv): ErlNifTerm =
  return enif_make_double(env, V)

########## ErlAtom, nim=tuple[v=string] ##########
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

########## ErlString, nim=string ##########
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

########## ErlBinary, nim=ptr UncheckedArray[byte] ##########
proc decode*(term: ErlNifTerm, env: ptr ErlNifEnv, T: typedesc[ErlBinary]): Option[T] =
  var bin: ErlNifBinary
  if not enif_inspect_binary(env, term, addr(bin)):
    return none(T)
  return some(bin)

proc encode*(V: ErlBinary, env: ptr ErlNifEnv): ErlNifTerm =
  return enif_make_binary(env, unsafeAddr(V))

########## ErlTuple nim=array ##########
proc encode*(V: ErlTuple, env: ptr ErlNifEnv): ErlNifTerm =
  return enif_make_tuple_from_array(env, V)

########## ErlList nim=seq##########
proc encode*(V: ErlList, env: ptr ErlNifEnv): ErlNifTerm =
  return enif_make_list_from_array(env, V)

########## ErlResult ##########
proc encode*(V: ErlResult, env: ptr ErlNifEnv): ErlNifTerm =
  return encode(enif_make_atom(env, V.rtype.val), V.rval, env)

