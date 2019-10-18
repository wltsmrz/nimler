import options
import bindings/erl_nif

export options

type ErlAtom* = Buffer

# INT
# nim: int
# erl: long
proc decode*(term: ErlNifTerm, env: ptr ErlNifEnv, T: typedesc[int]): Option[T] =
  var res: int
  if not enif_get_long(env, term, addr(res)):
    return none(T)
  return some(res)

proc encode*(V: int, env: ptr ErlNifEnv): ErlNifTerm =
  enif_make_long(env, cast[clong](V))

# UINT
# nim: uint
# erl: ulong
proc decode*(term: ErlNifTerm, env: ptr ErlNifEnv, T: typedesc[uint]): Option[T] =
  var res: uint
  if not enif_get_ulong(env, term, addr(res)):
    return none(T)
  return some(res)

proc encode*(V: uint, env: ptr ErlNifEnv): ErlNifTerm =
  enif_make_ulong(env, cast[culong](V))

# ATOM
# nim: Buffer
# erl: Atom
proc decode*(term: ErlNifTerm, env: ptr ErlNifEnv, T: typedesc[ErlAtom]): Option[T] =
  var atom_len: cuint

  if not enif_get_atom_length(env, term, addr(atom_len), ERL_NIF_LATIN1):
    return none(T)

  let atom_buf = cast[Buffer](create(cchar, atom_len + 1))

  if enif_get_atom(env, term, atom_buf, atom_len + 1, ERL_NIF_LATIN1) == 0:
    return none(T)

  return some(ErlAtom(atom_buf))

proc encode*(V: ErlAtom, env: ptr ErlNifEnv): ErlNifTerm =
  enif_make_atom(env, V)


