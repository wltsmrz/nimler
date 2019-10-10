import ../nif_interfacex

proc is_atom(env: ptr ErlNifEnv, argc: cint, argv: array[1, ErlNifTerm]): ErlNifTerm {.exportc.} =
  return enif_make_int(env, cast[cint](enif_is_atom(env, argv[0])))
proc is_binary(env: ptr ErlNifEnv, argc: cint, argv: array[1, ErlNifTerm]): ErlNifTerm {.exportc.} =
  return enif_make_int(env, cast[cint](enif_is_binary(env, argv[0])))

proc is_current_process_alive(env: ptr ErlNifEnv, argc: cint, argv: array[0, ErlNifTerm]): ErlNifTerm {.exportc.} =
  return enif_make_int(env, cast[cint](enif_is_current_process_alive(env)))

proc is_empty_list(env: ptr ErlNifEnv, argc: cint, argv: array[1, ErlNifTerm]): ErlNifTerm {.exportc.} =
  return enif_make_int(env, cast[cint](enif_is_empty_list(env, argv[0])))

proc is_exception(env: ptr ErlNifEnv, argc: cint, argv: array[1, ErlNifTerm]): ErlNifTerm {.exportc.} =
  return enif_make_int(env, cast[cint](enif_is_exception(env, argv[0])))
proc is_fun(env: ptr ErlNifEnv, argc: cint, argv: array[1, ErlNifTerm]): ErlNifTerm {.exportc.} =
  return enif_make_int(env, cast[cint](enif_is_fun(env, argv[0])))

proc is_identical(env: ptr ErlNifEnv, argc: cint, argv: array[2, ErlNifTerm]): ErlNifTerm {.exportc.} =
  return enif_make_int(env, cast[cint](enif_is_identical(argv[0], argv[1])))

proc is_list(env: ptr ErlNifEnv, argc: cint, argv: array[1, ErlNifTerm]): ErlNifTerm {.exportc.} =
  return enif_make_int(env, cast[cint](enif_is_list(env, argv[0])))
proc is_map(env: ptr ErlNifEnv, argc: cint, argv: array[1, ErlNifTerm]): ErlNifTerm {.exportc.} =
  return enif_make_int(env, cast[cint](enif_is_map(env, argv[0])))
proc is_number(env: ptr ErlNifEnv, argc: cint, argv: array[1, ErlNifTerm]): ErlNifTerm {.exportc.} =
  return enif_make_int(env, cast[cint](enif_is_number(env, argv[0])))
proc is_pid(env: ptr ErlNifEnv, argc: cint, argv: array[1, ErlNifTerm]): ErlNifTerm {.exportc.} =
  return enif_make_int(env, cast[cint](enif_is_pid(env, argv[0])))

proc is_pid_undefined(env: ptr ErlNifEnv, argc: cint, argv: array[1, ErlNifTerm]): ErlNifTerm {.exportc.} =
  var pid: ErlNifPid
  discard enif_get_local_pid(env, argv[0], addr(pid))
  return enif_make_int(env, cast[cint](enif_is_pid_undefined(addr(pid))))
 
# proc is_port(env: ptr ErlNifEnv, argc: cint, argv: array[1, ErlNifTerm]): ErlNifTerm {.exportc.} =
#   return enif_make_int(env, cast[cint](enif_is_port(env, argv[0])))
# 
# proc is_port_alive(env: ptr ErlNifEnv, argc: cint, argv: array[1, ErlNifTerm]): ErlNifTerm {.exportc.} =
#   return enif_make_int(env, cast[cint](enif_is_port_alive(env, argv[0])))

proc is_process_alive(env: ptr ErlNifEnv, argc: cint, argv: array[1, ErlNifTerm]): ErlNifTerm {.exportc.} =
  var pid: ErlNifPid
  discard enif_get_local_pid(env, argv[0], addr(pid))
  return enif_make_int(env, cast[cint](enif_is_process_alive(env, addr(pid))))

proc is_ref(env: ptr ErlNifEnv, argc: cint, argv: array[1, ErlNifTerm]): ErlNifTerm {.exportc.} =
  return enif_make_int(env, cast[cint](enif_is_ref(env, argv[0])))
proc is_tuple(env: ptr ErlNifEnv, argc: cint, argv: array[1, ErlNifTerm]): ErlNifTerm {.exportc.} =
  return enif_make_int(env, cast[cint](enif_is_tuple(env, argv[0])))

proc get_atom(env: ptr ErlNifEnv, argc: cint, argv: array[1, ErlNifTerm]): ErlNifTerm {.exportc.} =
  var atom_len: cuint

  if not enif_get_atom_length(env, argv[0], addr(atom_len), ERL_NIF_LATIN1):
    return enif_make_badarg(env)

  let string_buf = alloc_c_string(atom_len)

  if enif_get_atom(env, argv[0], string_buf, atom_len + 1, ERL_NIF_LATIN1) == 0:
    return enif_make_badarg(env)

  return enif_make_string(env, cast[string](string_buf), ERL_NIF_LATIN1)


proc get_string(env: ptr ErlNifEnv, argc: cint, argv: array[1, ErlNifTerm]): ErlNifTerm {.exportc.} =
  var string_len: cuint

  if not enif_get_list_length(env, argv[0], addr(string_len)):
    return enif_make_badarg(env)

  let string_buf = alloc_c_string(string_len)

  if enif_get_string(env, argv[0], string_buf, string_len + 1, ERL_NIF_LATIN1) == 0:
    return enif_make_badarg(env)

  return enif_make_string(env, cast[cstring](string_buf), ERL_NIF_LATIN1)


proc get_int(env: ptr ErlNifEnv, argc: cint, argv: array[1, ErlNifTerm]): ErlNifTerm {.exportc.} =
  var v: cint

  if not enif_get_int(env, argv[0], addr(v)):
    return enif_make_badarg(env)

  return enif_make_int(env, v)

proc get_long(env: ptr ErlNifEnv, argc: cint, argv: array[1, ErlNifTerm]): ErlNifTerm {.exportc.} =
  var v: clong

  if not enif_get_long(env, argv[0], addr(v)):
    return enif_make_badarg(env)

  return enif_make_long(env, v)

proc get_int64(env: ptr ErlNifEnv, argc: cint, argv: array[1, ErlNifTerm]): ErlNifTerm {.exportc.} =
  var v: clonglong

  if not enif_get_int64(env, argv[0], addr(v)):
    return enif_make_badarg(env)

  return enif_make_int64(env, v)

proc get_uint(env: ptr ErlNifEnv, argc: cuint, argv: array[1, ErlNifTerm]): ErlNifTerm {.exportc.} =
  var v: cuint

  if not enif_get_uint(env, argv[0], addr(v)):
    return enif_make_badarg(env)

  return enif_make_uint(env, v)

proc get_ulong(env: ptr ErlNifEnv, argc: cuint, argv: array[1, ErlNifTerm]): ErlNifTerm {.exportc.} =
  var v: culong

  if not enif_get_ulong(env, argv[0], addr(v)):
    return enif_make_badarg(env)

  return enif_make_ulong(env, v)

proc get_double(env: ptr ErlNifEnv, argc: cint, argv: array[1, ErlNifTerm]): ErlNifTerm {.exportc.} =
  var v: cdouble

  if not enif_get_double(env, argv[0], addr(v)):
    return enif_make_badarg(env)

  return enif_make_double(env, v)

proc get_list_length(env: ptr ErlNifEnv, argc: cint, argv: array[1, ErlNifTerm]): ErlNifTerm {.exportc.} =
  var list_len: cuint

  if not enif_get_list_length(env, argv[0], addr(list_len)):
    return enif_make_badarg(env)

  return enif_make_uint(env, cast[cuint](list_len))

proc get_list_cell(env: ptr ErlNifEnv, argc: cint, argv: array[1, ErlNifTerm]): ErlNifTerm {.exportc.} =
  var head: ErlNifTerm
  var tail: ErlNifTerm

  if not enif_get_list_cell(env, argv[0], addr(head), addr(tail)):
    return enif_make_badarg(env)

  return tail

proc get_map_size(env: ptr ErlNifEnv, argc: cint, argv: array[1, ErlNifTerm]): ErlNifTerm {.exportc.} =
  var map_size: csize

  if not enif_get_map_size(env, argv[0], addr(map_size)):
    return enif_make_badarg(env)

  return enif_make_int(env, cast[cint](map_size))

proc get_map_value(env: ptr ErlNifEnv, argc: cint, argv: array[2, ErlNifTerm]): ErlNifTerm {.exportc.} =
  var map_val_term: ErlNifTerm

  if not enif_get_map_value(env, argv[0], argv[1], addr(map_val_term)):
    return enif_make_badarg(env)

  return map_val_term

proc make_map_put(env: ptr ErlNifEnv, argc: cint, argv: array[3, ErlNifTerm]): ErlNifTerm {.exportc.} =
  let new_map = enif_make_new_map(env)

  if not enif_make_map_put(env, argv[0], argv[1], argv[2], unsafeAddr(new_map)):
    return enif_make_badarg(env)

  return new_map

proc make_map_remove(env: ptr ErlNifEnv, argc: cint, argv: array[2, ErlNifTerm]): ErlNifTerm {.exportc.} =
  let new_map = enif_make_new_map(env)

  if not enif_make_map_remove(env, argv[0], argv[1], unsafeAddr(new_map)):
    return enif_make_badarg(env)

  return new_map

proc make_map_update(env: ptr ErlNifEnv, argc: cint, argv: array[3, ErlNifTerm]): ErlNifTerm {.exportc.} =
  let new_map = enif_make_new_map(env)

  if not enif_make_map_update(env, argv[0], argv[1], argv[2], unsafeAddr(new_map)):
    return enif_make_badarg(env)

  return new_map


{.emit: """
static ErlNifFunc funcs[] = {
  {"enif_is_atom", 1, is_atom},
  {"enif_is_binary", 1, is_binary},
  {"enif_is_current_process_alive", 0, is_current_process_alive},
  {"enif_is_empty_list", 1, is_empty_list},
  {"enif_is_exception", 1, is_exception},
  {"enif_is_fun", 1, is_fun},
  {"enif_is_identical", 2, is_identical},
  {"enif_is_list", 1, is_list},
  {"enif_is_map", 1, is_map},
  {"enif_is_number", 1, is_number},
  {"enif_is_pid", 1, is_pid},
  {"enif_is_pid_undefined", 1, is_pid_undefined},
  {"enif_is_process_alive", 1, is_process_alive},
  {"enif_is_ref", 1, is_ref},
  {"enif_is_tuple", 1, is_tuple},

  {"get_atom", 1, get_atom},
  {"get_string", 1, get_string},
  {"get_int", 1, get_int},
  {"get_long", 1, get_long},
  {"get_int64", 1, get_int64},
  {"get_uint", 1, get_uint},
  {"get_ulong", 1, get_ulong},
  {"get_double", 1, get_double},

  {"get_list_length", 1, get_list_length},
  {"get_list_cell", 1, get_list_cell},

  {"get_map_size", 1, get_map_size},
  {"get_map_value", 2, get_map_value},
  {"make_map_put", 3, make_map_put},
  {"make_map_remove", 2, make_map_remove},
  {"make_map_update", 3, make_map_update},

};

ERL_NIF_INIT(Elixir.NimNif, funcs, NULL, NULL, NULL, NULL)
""".}

