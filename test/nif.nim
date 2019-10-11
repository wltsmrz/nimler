import ../nif_interface

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

  let string_buf = cast[Buffer](create(cchar, int(atom_len) + 1))

  if enif_get_atom(env, argv[0], string_buf, atom_len + 1, ERL_NIF_LATIN1) == 0:
    return enif_make_badarg(env)

  return enif_make_string(env, string_buf, ERL_NIF_LATIN1)


proc get_string(env: ptr ErlNifEnv, argc: cint, argv: array[1, ErlNifTerm]): ErlNifTerm {.exportc.} =
  var string_len: cuint

  if not enif_get_list_length(env, argv[0], addr(string_len)):
    return enif_make_badarg(env)

  let string_buf = cast[Buffer](create(cchar, int(string_len) + 1))

  if enif_get_string(env, argv[0], string_buf, string_len + 1, ERL_NIF_LATIN1) == 0:
    return enif_make_badarg(env)

  return enif_make_string(env, string_buf, ERL_NIF_LATIN1)

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

proc get_uint64(env: ptr ErlNifEnv, argc: cuint, argv: array[1, ErlNifTerm]): ErlNifTerm {.exportc.} =
  var v: culonglong

  if not enif_get_uint64(env, argv[0], addr(v)):
    return enif_make_badarg(env)

  return enif_make_uint64(env, v)

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

proc make_string(env: ptr ErlNifEnv, argc: cint, argv: array[0, ErlNifTerm]): ErlNifTerm {.exportc.} =

  return enif_make_string(env, cstring("test"), ERL_NIF_LATIN1)

proc make_string_len(env: ptr ErlNifEnv, argc: cint, argv: array[0, ErlNifTerm]): ErlNifTerm {.exportc.} =

  return enif_make_string_len(env, cstring("test"), 4, ERL_NIF_LATIN1)

proc make_tuple(env: ptr ErlNifEnv, argc: cint, argv: array[0, ErlNifTerm]): ErlNifTerm {.exportc.} =

  let tuple_len: cuint = 3
  let t1 = enif_make_int(env, cint(1))
  let t2 = enif_make_int(env, cint(2))
  let t3 = enif_make_int(env, cint(3))

  return enif_make_tuple(env, tuple_len, t1, t2, t3)

proc make_int(env: ptr ErlNifEnv, argc: cint, argv: array[0, ErlNifTerm]): ErlNifTerm {.exportc.} =
  return enif_make_int(env, cint(1))

proc make_long(env: ptr ErlNifEnv, argc: cint, argv: array[0, ErlNifTerm]): ErlNifTerm {.exportc.} =
  return enif_make_long(env, clong(1))

proc make_int64(env: ptr ErlNifEnv, argc: cint, argv: array[0, ErlNifTerm]): ErlNifTerm {.exportc.} =
  return enif_make_int64(env, clonglong(1))


proc make_uint(env: ptr ErlNifEnv, argc: cuint, argv: array[0, ErlNifTerm]): ErlNifTerm {.exportc.} =
  return enif_make_uint(env, cuint(1))

proc make_ulong(env: ptr ErlNifEnv, argc: cuint, argv: array[0, ErlNifTerm]): ErlNifTerm {.exportc.} =
  return enif_make_ulong(env, culong(1))

proc make_uint64(env: ptr ErlNifEnv, argc: cuint, argv: array[0, ErlNifTerm]): ErlNifTerm {.exportc.} =
  return enif_make_uint64(env, culonglong(1))

proc make_double(env: ptr ErlNifEnv, argc: cuint, argv: array[0, ErlNifTerm]): ErlNifTerm {.exportc.} =
  return enif_make_double(env, cdouble(1.1))

proc make_new_binary(env: ptr ErlNifEnv, argc: cuint, argv: array[0, ErlNifTerm]): ErlNifTerm {.exportc.} =
  var term: ErlNifTerm
  let binary_ptr = enif_make_new_binary(env, sizeof(cchar) * 2, addr(term))
  let res = cast[Buffer](binary_ptr)
  res[0] = 'o'
  res[1] = 'k'

  return term

proc make_new_map(env: ptr ErlNifEnv, argc: cuint, argv: array[0, ErlNifTerm]): ErlNifTerm {.exportc.} =
  return enif_make_new_map(env)

proc make_map_from_arrays(env: ptr ErlNifEnv, argc: cuint, argv: array[0, ErlNifTerm]): ErlNifTerm {.exportc.} =

  let keys = [
    enif_make_atom(env, cstring("test1")),
    enif_make_atom(env, cstring("test2"))
  ]
  let values = [
    enif_make_int(env, cint(1)),
    enif_make_int(env, cint(2))
  ]

  let k = cast[ptr ErlNifTerm](unsafeAddr(keys))
  let v = cast[ptr ErlNifTerm](unsafeAddr(values))
  var map_out: ErlNifTerm

  if not enif_make_map_from_arrays(env, k, v, csize(2), addr(map_out)):
    return enif_make_badarg(env)

  return map_out

proc make_atom(env: ptr ErlNifEnv, argc: cuint, argv: array[0, ErlNifTerm]): ErlNifTerm {.exportc.} =
  return enif_make_atom(env, cstring("test"))

proc make_existing_atom(env: ptr ErlNifEnv, argc: cuint, argv: array[0, ErlNifTerm]): ErlNifTerm {.exportc.} =
  var existing_atom: ErlNifTerm

  if not enif_make_existing_atom(env, cstring("test"), addr(existing_atom), ERL_NIF_LATIN1):
    return enif_make_badarg(env)

  return existing_atom

proc make_existing_atom_len(env: ptr ErlNifEnv, argc: cuint, argv: array[0, ErlNifTerm]): ErlNifTerm {.exportc.} =
  var existing_atom: ErlNifTerm

  if not enif_make_existing_atom_len(env, cstring("test"), csize(4), addr(existing_atom), ERL_NIF_LATIN1):
    return enif_make_badarg(env)

  return existing_atom

proc make_list(env: ptr ErlNifEnv, argc: cuint, argv: array[0, ErlNifTerm]): ErlNifTerm {.exportc.} =
  let list_len: cuint = 3
  let t1 = enif_make_int(env, cint(1))
  let t2 = enif_make_int(env, cint(2))
  let t3 = enif_make_int(env, cint(3))

  return enif_make_list(env, list_len, t1, t2, t3)

proc make_list_cell(env: ptr ErlNifEnv, argc: cuint, argv: array[0, ErlNifTerm]): ErlNifTerm {.exportc.} =
  let h = enif_make_int(env, cint(1))
  let t = enif_make_int(env, cint(2))

  return enif_make_list_cell(env, h, t)

proc make_list_from_array(env: ptr ErlNifEnv, argc: cuint, argv: array[0, ErlNifTerm]): ErlNifTerm {.exportc.} =
  let values = [
    enif_make_int(env, cint(1)),
    enif_make_int(env, cint(2))
  ]
  let v = cast[ptr ErlNifTerm](unsafeAddr(values))

  return enif_make_list_from_array(env, v, cuint(2))

proc make_reverse_list(env: ptr ErlNifEnv, argc: cuint, argv: array[0, ErlNifTerm]): ErlNifTerm {.exportc.} =
 let l1 = make_list(env, argc, argv)
 var l2: ErlNifTerm
 if not enif_make_reverse_list(env, l1, addr(l2)):
   return enif_make_badarg(env)
 return l2

proc make_copy(env: ptr ErlNifEnv, argc: cuint, argv: array[0, ErlNifTerm]): ErlNifTerm {.exportc.} =
  let v = enif_make_int(env, cint(1))
  let c = enif_make_copy(env, v)

  return c

proc make_pid(env: ptr ErlNifEnv, argc: cuint, argv: array[0, ErlNifTerm]): ErlNifTerm {.exportc.} =
  var pid_term = ErlNifPid(pid: 0xBEEF)
  return enif_make_pid(env, addr(pid_term))

proc make_ref(env: ptr ErlNifEnv, argc: cuint, argv: array[0, ErlNifTerm]): ErlNifTerm {.exportc.} =
  return enif_make_ref(env)

proc make_resource(env: ptr ErlNifEnv, argc: cuint, argv: array[0, ErlNifTerm]): ErlNifTerm {.exportc.} =
  var res: pointer
  return enif_make_resource(env, addr(res))

proc make_unique_integer(env: ptr ErlNifEnv, argc: cuint, argv: array[0, ErlNifTerm]): ErlNifTerm {.exportc.} =
  return enif_make_unique_integer(env, ERL_NIF_UNIQUE_POSITIVE)

# TODO
# proc make_sub_binary(env: ptr ErlNifEnv, argc: cuint, argv: array[0, ErlNifTerm]): ErlNifTerm {.exportc.} =
#   var bin_term: ErlNifTerm
#   let bin_ptr = enif_make_new_binary(env, sizeof(cchar) * 2, addr(bin_term))
#   let bin_buf = cast[Buffer](bin_ptr)
#   bin_buf[0] = 'o'
#   bin_buf[1] = 'k'
# 
#   # let bin_buf = cast[Buffer](bin_ptr)
#   # for i in 0..len(bin_buf): bin_buf[i] = chr(48 + i)
#   # let sub_bin = enif_make_sub_binary(env, bin_term, csize(0), csize(2))
#   # let sub_bin_buf = cast[Buffer](sub_bin)
#   # echo cast[cstring](sub_bin_buf)
# 
#   return bin_term


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
  {"get_uint64", 1, get_uint64},
  {"get_double", 1, get_double},
  {"get_list_length", 1, get_list_length},
  {"get_list_cell", 1, get_list_cell},
  {"get_map_size", 1, get_map_size},
  {"get_map_value", 2, get_map_value},
  {"make_map_put", 3, make_map_put},
  {"make_map_remove", 2, make_map_remove},
  {"make_map_update", 3, make_map_update},
  {"enif_make_string", 0, make_string},
  {"enif_make_string_len", 0, make_string_len},
  {"enif_make_list", 0, make_list},
  {"enif_make_list_cell", 0, make_list_cell},
  {"enif_make_list_from_array", 0, make_list_from_array},
  {"enif_make_reverse_list", 0, make_reverse_list},
  {"enif_make_tuple", 0, make_tuple},
  {"enif_make_int", 0, make_int},
  {"enif_make_long", 0, make_long},
  {"enif_make_int64", 0, make_int64},
  {"enif_make_uint", 0, make_uint},
  {"enif_make_ulong", 0, make_ulong},
  {"enif_make_uint64", 0, make_uint64},
  {"enif_make_double", 0, make_double},
  {"enif_make_new_binary", 0, make_new_binary},
  {"enif_make_new_map", 0, make_new_map},
  {"enif_make_map_from_arrays", 0, make_map_from_arrays},
  {"enif_make_atom", 0, make_atom},
  {"enif_make_existing_atom", 0, make_existing_atom},
  {"enif_make_existing_atom_len", 0, make_existing_atom_len},
  {"enif_make_copy", 0, make_copy},
  {"enif_make_pid", 0, make_pid},
  {"enif_make_ref", 0, make_ref},
  {"enif_make_unique_integer", 0, make_unique_integer}

};

ERL_NIF_INIT(Elixir.NimNif, funcs, NULL, NULL, NULL, NULL)
""".}

