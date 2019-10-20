import options
import bindings/erl_nif

export options

type ErlAtom* = Buffer
type ErlResult* = tuple[rtype: ErlAtom, rval: ErlNifTerm]
type ErlTuple* = varargs[ErlNifTerm]
type ErlList* = openArray[ErlNifTerm]

const AtomOk* = cast[ErlAtom]("ok")
const AtomErr* = cast[ErlAtom]("error")

proc ResultOk*(rval: ErlNifTerm): ErlResult = (AtomOk, rval)
proc ResultErr*(rval: ErlNifTerm): ErlResult = (AtomErr, rval)

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

########## ErlAtom ##########
proc decode*(term: ErlNifTerm, env: ptr ErlNifEnv, T: typedesc[ErlAtom]): Option[T] =
  var atom_len: cuint
  if not enif_get_atom_length(env, term, addr(atom_len), ERL_NIF_LATIN1):
    return none(T)
  let atom_buf = cast[Buffer](create(cchar, atom_len + 1))
  if enif_get_atom(env, term, atom_buf, atom_len + 1, ERL_NIF_LATIN1) == 0:
    return none(T)
  return some(ErlAtom(atom_buf))

proc encode*(V: ErlAtom, env: ptr ErlNifEnv): ErlNifTerm =
  return enif_make_atom(env, V)

########## ErlResult ##########
proc encode*(V: ErlResult, env: ptr ErlNifEnv): ErlNifTerm =
  let arity = cuint(2)
  let rtype = enif_make_atom(env, V.rtype)
  return enif_make_tuple(env, arity, rtype, V.rval)

########## tuple ##########
proc encode*(V: ErlTuple, env: ptr ErlNifEnv): ErlNifTerm =
  return enif_make_tuple_from_array(env, V)

########## list ##########
proc encode*(V: ErlList, env: ptr ErlNifEnv): ErlNifTerm =
  return enif_make_list_from_array(env, V)


