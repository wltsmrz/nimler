import ../../nimler

using
  env: ptr ErlNifEnv
  argc: cint
  argv: ErlNifArgs

func is_atom(env, argc, argv): ErlNifTerm {.nif, arity: 1.} =
  enif_make_int(env, cast[cint](enif_is_atom(env, argv[0])))

func is_binary(env, argc, argv): ErlNifTerm {.nif, arity: 1.} =
  enif_make_int(env, cast[cint](enif_is_binary(env, argv[0])))

func is_current_process_alive(env, argc, argv): ErlNifTerm {.nif, arity: 0.} =
  enif_make_int(env, cast[cint](enif_is_current_process_alive(env)))

func is_empty_list(env, argc, argv): ErlNifTerm {.nif, arity: 1.} =
  enif_make_int(env, cast[cint](enif_is_empty_list(env, argv[0])))

func is_exception(env, argc, argv): ErlNifTerm {.nif, arity: 1.} =
  enif_make_int(env, cast[cint](enif_is_exception(env, argv[0])))

func is_fun(env, argc, argv): ErlNifTerm {.nif, arity: 1.} =
  enif_make_int(env, cast[cint](enif_is_fun(env, argv[0])))

func is_identical(env, argc, argv): ErlNifTerm {.nif, arity: 2.} =
  enif_make_int(env, cast[cint](enif_is_identical(argv[0], argv[1])))

func is_list(env, argc, argv): ErlNifTerm {.nif, arity: 1.} =
  enif_make_int(env, cast[cint](enif_is_list(env, argv[0])))

func is_map(env, argc, argv): ErlNifTerm {.nif, arity: 1.} =
  enif_make_int(env, cast[cint](enif_is_map(env, argv[0])))

func is_number(env, argc, argv): ErlNifTerm {.nif, arity: 1.} =
  enif_make_int(env, cast[cint](enif_is_number(env, argv[0])))

func is_pid(env, argc, argv): ErlNifTerm {.nif, arity: 1.} =
  enif_make_int(env, cast[cint](enif_is_pid(env, argv[0])))

func is_pid_undefined(env, argc, argv): ErlNifTerm {.nif, arity: 1.} =
  var pid: ErlNifPid
  if not enif_get_local_pid(env, argv[0], addr(pid)):
    return enif_make_badarg(env)
  return enif_make_int(env, cast[cint](enif_is_pid_undefined(addr(pid))))

func is_process_alive(env, argc, argv): ErlNifTerm {.nif, arity: 1.} =
  var pid: ErlNifPid
  if not enif_get_local_pid(env, argv[0], addr(pid)):
    return enif_make_badarg(env)
  return enif_make_int(env, cast[cint](enif_is_process_alive(env, addr(pid))))

func is_ref(env, argc, argv): ErlNifTerm {.nif, arity: 1.} =
  return enif_make_int(env, cast[cint](enif_is_ref(env, argv[0])))

func is_tuple(env, argc, argv): ErlNifTerm {.nif, arity: 1.} =
  return enif_make_int(env, cast[cint](enif_is_tuple(env, argv[0])))

func get_atom(env, argc, argv): ErlNifTerm {.nif, arity: 1.} =
  let atom_len = 4
  var string_buf = newString(atom_len)
  if enif_get_atom(env, argv[0], addr(string_buf[0]), cuint(atom_len + 1), ERL_NIF_LATIN1) == 0:
    return enif_make_badarg(env)
  return enif_make_atom(env, string_buf)

func get_atom_length(env, argc, argv): ErlNifTerm {.nif, arity: 1.} =
  var atom_len: cuint
  if not enif_get_atom_length(env, argv[0], addr(atom_len), ERL_NIF_LATIN1):
    return enif_make_badarg(env)
  return enif_make_uint(env, atom_len)

func get_string(env, argc, argv): ErlNifTerm {.nif, arity: 1.} =
  var string_len: cuint
  if not enif_get_list_length(env, argv[0], addr(string_len)):
    return enif_make_badarg(env)
  var string_buf = newString(string_len)
  if enif_get_string(env, argv[0], addr(string_buf[0]), string_len + 1, ERL_NIF_LATIN1) == 0:
    return enif_make_badarg(env)
  return enif_make_string(env, string_buf, ERL_NIF_LATIN1)

func get_int(env, argc, argv): ErlNifTerm {.nif, arity: 1.} =
  var v: cint
  if not enif_get_int(env, argv[0], addr(v)):
    return enif_make_badarg(env)
  return enif_make_int(env, v)

func get_long(env, argc, argv): ErlNifTerm {.nif, arity: 1.} =
  var v: clong
  if not enif_get_long(env, argv[0], addr(v)):
    return enif_make_badarg(env)
  return enif_make_long(env, v)

func get_int64(env, argc, argv): ErlNifTerm {.nif, arity: 1.} =
  var v: clonglong
  if not enif_get_int64(env, argv[0], addr(v)):
    return enif_make_badarg(env)
  return enif_make_int64(env, v)

func get_uint(env, argc, argv): ErlNifTerm {.nif, arity: 1.} =
  var v: cuint
  if not enif_get_uint(env, argv[0], addr(v)):
    return enif_make_badarg(env)
  return enif_make_uint(env, v)

func get_ulong(env, argc, argv): ErlNifTerm {.nif, arity: 1.} =
  var v: culong
  if not enif_get_ulong(env, argv[0], addr(v)):
    return enif_make_badarg(env)
  return enif_make_ulong(env, v)

func get_uint64(env, argc, argv): ErlNifTerm {.nif, arity: 1.} =
  var v: culonglong
  if not enif_get_uint64(env, argv[0], addr(v)):
    return enif_make_badarg(env)
  return enif_make_uint64(env, v)

func get_double(env, argc, argv): ErlNifTerm {.nif, arity: 1.} =
  var v: cdouble
  if not enif_get_double(env, argv[0], addr(v)):
    return enif_make_badarg(env)
  return enif_make_double(env, v)

func get_tuple(env, argc, argv): ErlNifTerm {.nif, arity: 1.} =
  var tuple_len: cuint
  var tup: ptr UncheckedArray[ErlNifTerm]
  if not enif_get_tuple(env, argv[0], addr(tuple_len), addr(tup)):
    return enif_make_badarg(env)
  var t1: cint
  var t2: cint
  discard enif_get_int(env, tup[0], addr(t1))
  discard enif_get_int(env, tup[1], addr(t2))
  doAssert(t1 == 1)
  doAssert(t2 == 2)
  let t11 = enif_make_int(env, t1)
  let t12 = enif_make_int(env, t2)
  return enif_make_tuple(env, tuple_len, t11, t12)

func get_list_length(env, argc, argv): ErlNifTerm {.nif, arity: 1.} =
  var list_len: cuint
  if not enif_get_list_length(env, argv[0], addr(list_len)):
    return enif_make_badarg(env)
  return enif_make_uint(env, cast[cuint](list_len))

func get_list_cell(env, argc, argv): ErlNifTerm {.nif, arity: 1.} =
  var head: ErlNifTerm
  var tail: ErlNifTerm
  if not enif_get_list_cell(env, argv[0], addr(head), addr(tail)):
    return enif_make_badarg(env)
  return tail

func get_map_size(env, argc, argv): ErlNifTerm {.nif, arity: 1.} =
  var map_size: csize_t
  if not enif_get_map_size(env, argv[0], addr(map_size)):
    return enif_make_badarg(env)
  return enif_make_uint(env, map_size)

func get_map_value(env, argc, argv): ErlNifTerm {.nif, arity: 2.} =
  var map_val_term: ErlNifTerm
  if not enif_get_map_value(env, argv[0], argv[1], addr(map_val_term)):
    return enif_make_badarg(env)
  return map_val_term

func get_local_pid(env, argc, argv): ErlNifTerm {.nif, arity: 1.} =
  var pid_obj: ErlNifPid
  if not enif_get_local_pid(env, argv[0], addr(pid_obj)):
    return enif_make_badarg(env)
  return pid_obj.pid

func make_map_put(env, argc, argv): ErlNifTerm {.nif, arity: 3.} =
  let k = argv[1]
  let v = argv[2]
  var nm: ErlNifTerm
  discard enif_make_map_put(env, argv[0], k, v, addr(nm))
  return nm

func make_map_remove(env, argc, argv): ErlNifTerm {.nif, arity: 2.} =
  var nm: ErlNifTerm
  discard enif_make_map_remove(env, argv[0], argv[1], addr(nm))
  return nm

func make_map_update(env, argc, argv): ErlNifTerm {.nif, arity: 3.} =
  let k = argv[1]
  let v = argv[2]
  var nm: ErlNifTerm
  discard enif_make_map_update(env, argv[0], k, v, addr(nm))
  return nm

func make_string(env, argc, argv): ErlNifTerm {.nif, arity: 0.} =
  return enif_make_string(env, "test", ERL_NIF_LATIN1)

func make_string_len(env, argc, argv): ErlNifTerm {.nif, arity: 0.} =
  return enif_make_string_len(env, "test", 4, ERL_NIF_LATIN1)

func make_tuple(env, argc, argv): ErlNifTerm {.nif, arity: 0.} =
  let tuple_len: cuint = 3
  let t1 = enif_make_int(env, cint(1))
  let t2 = enif_make_int(env, cint(2))
  let t3 = enif_make_int(env, cint(3))
  return enif_make_tuple(env, tuple_len, t1, t2, t3)

func make_tuple_from_array(env, argc, argv): ErlNifTerm {.nif, arity: 0.} =
  return enif_make_tuple_from_array(env, [
    enif_make_int(env, cint(1)),
    enif_make_int(env, cint(2)),
    enif_make_int(env, cint(3))
  ])

func make_int(env, argc, argv): ErlNifTerm {.nif, arity: 0.} =
  return enif_make_int(env, cint(1))

func make_long(env, argc, argv): ErlNifTerm {.nif, arity: 0.} =
  return enif_make_long(env, clong(1))

func make_int64(env, argc, argv): ErlNifTerm {.nif, arity: 0.} =
  return enif_make_int64(env, clonglong(1))

func make_uint(env, argc, argv): ErlNifTerm {.nif, arity: 0.} =
  return enif_make_uint(env, cuint(1))

func make_ulong(env, argc, argv): ErlNifTerm {.nif, arity: 0.} =
  return enif_make_ulong(env, culong(1))

func make_uint64(env, argc, argv): ErlNifTerm {.nif, arity: 0.} =
  return enif_make_uint64(env, culonglong(1))

func make_double(env, argc, argv): ErlNifTerm {.nif, arity: 0.} =
  return enif_make_double(env, cdouble(1.1))

func make_new_binary(env, argc, argv): ErlNifTerm {.nif, arity: 0.} =
  var term: ErlNifTerm
  let binary_ptr = enif_make_new_binary(env, sizeof(cchar) * 4, addr(term))
  let res = cast[ptr UncheckedArray[char]](binary_ptr)
  res[0] = 't'
  res[1] = 'e'
  res[2] = 's'
  res[3] = 't'
  return term

func make_new_map(env, argc, argv): ErlNifTerm {.nif, arity: 0.} =
  return enif_make_new_map(env)

func make_map_from_arrays(env, argc, argv): ErlNifTerm {.nif, arity: 0.} =
  var keys = [
    enif_make_atom(env, cstring("a")),
    enif_make_atom(env, cstring("b"))
  ]
  var values = [
    enif_make_int(env, cint(1)),
    enif_make_int(env, cint(2))
  ]
  let k = cast[ptr ErlNifTerm](addr(keys))
  let v = cast[ptr ErlNifTerm](addr(values))
  var map_out: ErlNifTerm
  if not enif_make_map_from_arrays(env, k, v, cuint(2), addr(map_out)):
    return enif_make_badarg(env)
  return map_out

func make_atom(env, argc, argv): ErlNifTerm {.nif, arity: 0.} =
  return enif_make_atom(env, cstring("test"))

func make_existing_atom(env, argc, argv): ErlNifTerm {.nif, arity: 0.} =
  var existing_atom: ErlNifTerm
  if not enif_make_existing_atom(env, cstring("test"), addr(existing_atom), ERL_NIF_LATIN1):
    return enif_make_badarg(env)
  return existing_atom

func make_existing_atom_len(env, argc, argv): ErlNifTerm {.nif, arity: 0.} =
  var existing_atom: ErlNifTerm
  if not enif_make_existing_atom_len(env, cstring("test"), cuint(4), addr(existing_atom), ERL_NIF_LATIN1):
    return enif_make_badarg(env)
  return existing_atom

func make_list(env, argc, argv): ErlNifTerm {.nif, arity: 0.} =
  let list_len: cuint = 3
  let t1 = enif_make_int(env, cint(1))
  let t2 = enif_make_int(env, cint(2))
  let t3 = enif_make_int(env, cint(3))
  return enif_make_list(env, list_len, t1, t2, t3)

func make_list_cell(env, argc, argv): ErlNifTerm {.nif, arity: 0.} =
  let h = enif_make_int(env, cint(1))
  let t = enif_make_int(env, cint(2))
  return enif_make_list_cell(env, h, t)

func make_list_from_array(env, argc, argv): ErlNifTerm {.nif, arity: 0.} =
  let values = [
    enif_make_int(env, cint(1)),
    enif_make_int(env, cint(2))
  ]
  return enif_make_list_from_array(env, values)

func make_reverse_list(env, argc, argv): ErlNifTerm {.nif, arity: 1.} =
  var l2: ErlNifTerm
  if not enif_make_reverse_list(env, argv[0], addr(l2)):
    return enif_make_badarg(env)
  return l2

func make_copy(env, argc, argv): ErlNifTerm {.nif, arity: 0.} =
  let v = enif_make_int(env, cint(1))
  let c = enif_make_copy(env, v)
  doAssert(v == c)
  return c

func make_pid(env, argc, argv): ErlNifTerm {.nif, arity: 0.} =
  var pid_term: ErlNifPid
  pid_term.pid = enif_make_int(env, 0)
  return enif_make_pid(env, addr(pid_term))

func make_ref(env, argc, argv): ErlNifTerm {.nif, arity: 0.} =
  return enif_make_ref(env)

func make_unique_integer(env, argc, argv): ErlNifTerm {.nif, arity: 0.} =
  return enif_make_unique_integer(env, ERL_NIF_UNIQUE_POSITIVE)

func e_raise_exception(env, argc, argv): ErlNifTerm {.nif, arity: 1.} =
  doAssert(false == enif_has_pending_exception(env))
  discard enif_raise_exception(env, argv[0])
  doAssert(true == enif_has_pending_exception(env))
  return argv[0]

func system_info(env, argc, argv): ErlNifTerm {.nif, arity: 0.} =
  var info = enif_system_info()
  doAssert(info.nif_major_version == nifMajor)
  doAssert(info.nif_minor_version == nifMinor)
  return enif_make_int(env, 0)

func term_type(env, argc, argv): ErlNifTerm {.nif, arity: 6.} =
  doAssert(enif_term_type(env, argv[0]) == ERL_NIF_TERM_TYPE_INTEGER)
  doAssert(enif_term_type(env, argv[1]) == ERL_NIF_TERM_TYPE_LIST)
  doAssert(enif_term_type(env, argv[2]) == ERL_NIF_TERM_TYPE_TUPLE)
  doAssert(enif_term_type(env, argv[3]) == ERL_NIF_TERM_TYPE_BITSTRING)
  doAssert(enif_term_type(env, argv[4]) == ERL_NIF_TERM_TYPE_MAP)
  doAssert(enif_term_type(env, argv[5]) == ERL_NIF_TERM_TYPE_PID)
  return enif_make_int(env, 0)

func e_compare(env, argc, argv): ErlNifTerm {.nif, arity: 2.} =
  let v = enif_compare(argv[0], argv[1])
  return enif_make_int(env, v)

func e_monotonic_time(env, argc, argv): ErlNifTerm {.nif, arity: 0.} =
  let v = enif_monotonic_time(ERL_NIF_SEC)
  return enif_make_int64(env, v)

func e_convert_time_unit(env, argc, argv): ErlNifTerm {.nif, arity: 0.} =
  let v = enif_monotonic_time(ERL_NIF_MSEC)
  let vv = enif_convert_time_unit(v, ERL_NIF_MSEC, ERL_NIF_SEC)
  return enif_make_list(env, 2,
    enif_make_int64(env, v),
    enif_make_int64(env, vv))

func e_time_offset(env, argc, argv): ErlNifTerm {.nif, arity: 0.} =
  let v = enif_time_offset(ERL_NIF_SEC)
  return enif_make_int64(env, v)

func e_cpu_time(env, argc, argv): ErlNifTerm {.nif, arity: 0.} =
  return enif_cpu_time(env)

func e_now_time(env, argc, argv): ErlNifTerm {.nif, arity: 0.} =
  return enif_now_time(env)

proc e_fprintf(env, argc, argv): ErlNifTerm {.nif, arity: 0.} =
  var term = enif_make_int(env, 1)
  var file = open("/dev/null", fmWrite)
  doAssert(enif_fprintf(file, "%T", term))
  return term

export_nifs("Elixir.NimlerIntegration", [
   is_atom,
   is_binary,
   is_current_process_alive,
   is_empty_list,
   is_exception,
   is_fun,
   is_identical,
   is_list,
   is_map,
   is_number,
   is_pid,
   is_pid_undefined,
   is_process_alive,
   is_ref,
   is_tuple,

   get_atom,
   get_atom_length,
   get_string,
   get_int,
   get_long,
   get_int64,
   get_uint,
   get_ulong,
   get_uint64,
   get_double,
   get_tuple,
   get_list_length,
   get_list_cell,
   get_map_size,
   get_map_value,
   get_local_pid,

   make_map_put,
   make_map_remove,
   make_map_update,
   make_string,
   make_string_len,
   make_list,
   make_list_cell,
   make_list_from_array,
   make_reverse_list,
   make_tuple,
   make_tuple_from_array,
   make_int,
   make_long,
   make_int64,
   make_uint,
   make_ulong,
   make_uint64,
   make_double,
   make_new_binary,
   make_new_map,
   make_map_from_arrays,
   make_atom,
   make_existing_atom,
   make_existing_atom_len,
   make_copy,
   make_pid,
   make_ref,
   make_unique_integer,

   e_compare,
   term_type,
   system_info,
   e_raise_exception,
   e_monotonic_time,
   e_convert_time_unit,
   e_time_offset,
   e_cpu_time,
   e_now_time,
   e_fprintf
])

