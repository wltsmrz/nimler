
import nif_interface

proc add_int(env: ptr ErlNifEnv, argc: cint, argv: array[2, ErlNifTerm]): ErlNifTerm {.exportc.} =
  var v1, v2: cint

  if not enif_get_int(env, argv[0], addr(v1)):
    return enif_make_badarg(env)

  if not enif_get_int(env, argv[1], addr(v2)):
    return enif_make_badarg(env)

  return enif_make_int(env, v1 + v2)

proc add_double(env: ptr ErlNifEnv, argc: cint, argv: array[2, ErlNifTerm]): ErlNifTerm {.exportc.} =
  var v1, v2: cdouble

  if not enif_get_double(env, argv[0], addr(v1)):
    return enif_make_badarg(env)

  if not enif_get_double(env, argv[1], addr(v2)):
    return enif_make_badarg(env)

  return enif_make_double(env, v1 + v2)

proc update_map(env: ptr ErlNifEnv, argc: cint, argv: array[1, ErlNifTerm]): ErlNifTerm {.exportc.} =
  let k = enif_make_atom(env, cstring("a"))
  let v = enif_make_int(env, cint(2))
  var res: ErlNifTerm

  if enif_make_map_update(env, argv[0], k, v, addr(res)):
    return res
  else:
    return enif_make_badarg(env)
