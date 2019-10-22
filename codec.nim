import options
import bindings/erl_nif

export options

type ErlAtom* = tuple[val: string]
type ErlString* = string
type ErlTuple* = varargs[ErlNifTerm]
type ErlList* = seq[ErlNifTerm]
type ErlResult* = tuple[rtype: ErlAtom, rval: ErlNifTerm]
type ErlBinary* = ErlNifBinary

const AtomOk*: ErlAtom = (val: "ok")
const AtomErr*:  ErlAtom = (val: "error")
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

########## ErlAtom, nim=tuple[v=string] ##########
proc decode*(term: ErlNifTerm, env: ptr ErlNifEnv, T: typedesc[ErlAtom]): Option[T] =
  var atom_len: cuint
  if not enif_get_atom_length(env, term, addr(atom_len), ERL_NIF_LATIN1):
    return none(T)
  inc(atom_len)
  let atom_buf = cast[Buffer](create(cchar, atom_len))
  if enif_get_atom(env, term, atom_buf, atom_len, ERL_NIF_LATIN1) != cint(atom_len):
    return none(T)
  let a: ErlAtom = (val: $atom_buf)
  return some(a)

proc encode*(V: ErlAtom, env: ptr ErlNifEnv): ErlNifTerm =
  return enif_make_atom(env, V.val.cstring)

########## ErlString, nim=string ##########
proc decode*(term: ErlNifTerm, env: ptr ErlNifEnv, T: typedesc[ErlString]): Option[T] =
  var string_len: cuint
  if not enif_get_list_length(env, term, addr(string_len)):
    return none(T)
  inc(string_len)
  let string_buf = cast[Buffer](create(cchar, string_len))
  if enif_get_string(env, term, string_buf, string_len, ERL_NIF_LATIN1) != cint(string_len):
    return none(T)
  return some(ErlString($string_buf))

proc encode*(V: ErlString, env: ptr ErlNifEnv): ErlNifTerm =
  return enif_make_string(env, V.cstring, ERL_NIF_LATIN1)

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
  return encode(enif_make_atom(env, V.rtype.val.cstring), V.rval, env)


