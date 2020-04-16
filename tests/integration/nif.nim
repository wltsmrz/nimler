import ../../nimler

using
  env: ptr ErlNifEnv
  argc: cint
  argv: ErlNifArgs

proc is_atom(env, argc, argv): ErlNifTerm =
  return enif_make_int(env, cast[cint](enif_is_atom(env, argv[0])))

proc is_binary(env, argc, argv): ErlNifTerm =
  return enif_make_int(env, cast[cint](enif_is_binary(env, argv[0])))

proc is_current_process_alive(env, argc, argv): ErlNifTerm =
  return enif_make_int(env, cast[cint](enif_is_current_process_alive(env)))

proc is_empty_list(env, argc, argv): ErlNifTerm =
  return enif_make_int(env, cast[cint](enif_is_empty_list(env, argv[0])))

proc is_exception(env, argc, argv): ErlNifTerm =
  return enif_make_int(env, cast[cint](enif_is_exception(env, argv[0])))

proc is_fun(env, argc, argv): ErlNifTerm =
  return enif_make_int(env, cast[cint](enif_is_fun(env, argv[0])))

proc is_identical(env, argc, argv): ErlNifTerm =
  return enif_make_int(env, cast[cint](enif_is_identical(argv[0], argv[1])))

proc is_list(env, argc, argv): ErlNifTerm =
  return enif_make_int(env, cast[cint](enif_is_list(env, argv[0])))

proc is_map(env, argc, argv): ErlNifTerm =
  return enif_make_int(env, cast[cint](enif_is_map(env, argv[0])))

proc is_number(env, argc, argv): ErlNifTerm =
  return enif_make_int(env, cast[cint](enif_is_number(env, argv[0])))

proc is_pid(env, argc, argv): ErlNifTerm =
  return enif_make_int(env, cast[cint](enif_is_pid(env, argv[0])))

proc is_pid_undefined(env, argc, argv): ErlNifTerm =
  var pid: ErlNifPid
  if not enif_get_local_pid(env, argv[0], addr(pid)):
    return enif_make_badarg(env)
  return enif_make_int(env, cast[cint](enif_is_pid_undefined(addr(pid))))

proc is_process_alive(env, argc, argv): ErlNifTerm =
  var pid: ErlNifPid
  if not enif_get_local_pid(env, argv[0], addr(pid)):
    return enif_make_badarg(env)
  return enif_make_int(env, cast[cint](enif_is_process_alive(env, addr(pid))))

proc is_ref(env, argc, argv): ErlNifTerm =
  return enif_make_int(env, cast[cint](enif_is_ref(env, argv[0])))

proc is_tuple(env, argc, argv): ErlNifTerm =
  return enif_make_int(env, cast[cint](enif_is_tuple(env, argv[0])))

proc get_atom(env, argc, argv): ErlNifTerm =
  let atom_len = 4
  var string_buf = newString(atom_len)
  if enif_get_atom(env, argv[0], addr(string_buf[0]), cuint(atom_len + 1), ERL_NIF_LATIN1) == 0:
    return enif_make_badarg(env)
  return enif_make_atom(env, string_buf)

proc get_atom_length(env, argc, argv): ErlNifTerm =
  var atom_len: cuint
  if not enif_get_atom_length(env, argv[0], addr(atom_len), ERL_NIF_LATIN1):
    return enif_make_badarg(env)
  return enif_make_uint(env, atom_len)

proc get_string(env, argc, argv): ErlNifTerm =
  var string_len: cuint
  if not enif_get_list_length(env, argv[0], addr(string_len)):
    return enif_make_badarg(env)
  var string_buf = newString(string_len)
  if enif_get_string(env, argv[0], addr(string_buf[0]), string_len + 1, ERL_NIF_LATIN1) == 0:
    return enif_make_badarg(env)
  return enif_make_string(env, string_buf, ERL_NIF_LATIN1)

proc get_int(env, argc, argv): ErlNifTerm =
  var v: cint
  if not enif_get_int(env, argv[0], addr(v)):
    return enif_make_badarg(env)
  return enif_make_int(env, v)

proc get_long(env, argc, argv): ErlNifTerm =
  var v: clong
  if not enif_get_long(env, argv[0], addr(v)):
    return enif_make_badarg(env)
  return enif_make_long(env, v)

proc get_int64(env, argc, argv): ErlNifTerm =
  var v: clonglong
  if not enif_get_int64(env, argv[0], addr(v)):
    return enif_make_badarg(env)
  return enif_make_int64(env, v)

proc get_uint(env, argc, argv): ErlNifTerm =
  var v: cuint
  if not enif_get_uint(env, argv[0], addr(v)):
    return enif_make_badarg(env)
  return enif_make_uint(env, v)

proc get_ulong(env, argc, argv): ErlNifTerm =
  var v: culong
  if not enif_get_ulong(env, argv[0], addr(v)):
    return enif_make_badarg(env)
  return enif_make_ulong(env, v)

proc get_uint64(env, argc, argv): ErlNifTerm =
  var v: culonglong
  if not enif_get_uint64(env, argv[0], addr(v)):
    return enif_make_badarg(env)
  return enif_make_uint64(env, v)

proc get_double(env, argc, argv): ErlNifTerm =
  var v: cdouble
  if not enif_get_double(env, argv[0], addr(v)):
    return enif_make_badarg(env)
  return enif_make_double(env, v)

proc get_tuple(env, argc, argv): ErlNifTerm =
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

proc get_list_length(env, argc, argv): ErlNifTerm =
  var list_len: cuint
  if not enif_get_list_length(env, argv[0], addr(list_len)):
    return enif_make_badarg(env)
  return enif_make_uint(env, cast[cuint](list_len))

proc get_list_cell(env, argc, argv): ErlNifTerm =
  var head: ErlNifTerm
  var tail: ErlNifTerm
  if not enif_get_list_cell(env, argv[0], addr(head), addr(tail)):
    return enif_make_badarg(env)
  return tail

proc get_map_size(env, argc, argv): ErlNifTerm =
  var map_size: csize_t
  if not enif_get_map_size(env, argv[0], addr(map_size)):
    return enif_make_badarg(env)
  return enif_make_uint(env, map_size)

proc get_map_value(env, argc, argv): ErlNifTerm =
  var map_val_term: ErlNifTerm
  if not enif_get_map_value(env, argv[0], argv[1], addr(map_val_term)):
    return enif_make_badarg(env)
  return map_val_term

proc get_local_pid(env, argc, argv): ErlNifTerm =
  var pid_obj: ErlNifPid
  if not enif_get_local_pid(env, argv[0], addr(pid_obj)):
    return enif_make_badarg(env)
  return pid_obj.pid

proc make_map_put(env, argc, argv): ErlNifTerm =
  let k = argv[1]
  let v = argv[2]
  var nm: ErlNifTerm
  discard enif_make_map_put(env, argv[0], k, v, addr(nm))
  return nm

proc make_map_remove(env, argc, argv): ErlNifTerm =
  var nm: ErlNifTerm
  discard enif_make_map_remove(env, argv[0], argv[1], addr(nm))
  return nm

proc make_map_update(env, argc, argv): ErlNifTerm =
  let k = argv[1]
  let v = argv[2]
  var nm: ErlNifTerm
  discard enif_make_map_update(env, argv[0], k, v, addr(nm))
  return nm

proc make_string(env, argc, argv): ErlNifTerm =
  return enif_make_string(env, cstring("test"), ERL_NIF_LATIN1)

proc make_string_len(env, argc, argv): ErlNifTerm =
  return enif_make_string_len(env, cstring("test"), 4, ERL_NIF_LATIN1)

proc make_tuple(env, argc, argv): ErlNifTerm =
  let tuple_len: cuint = 3
  let t1 = enif_make_int(env, cint(1))
  let t2 = enif_make_int(env, cint(2))
  let t3 = enif_make_int(env, cint(3))
  return enif_make_tuple(env, tuple_len, t1, t2, t3)

proc make_tuple_from_array(env, argc, argv): ErlNifTerm =
  return enif_make_tuple_from_array(env, [
    enif_make_int(env, cint(1)),
    enif_make_int(env, cint(2)),
    enif_make_int(env, cint(3))
  ])

proc make_int(env, argc, argv): ErlNifTerm =
  return enif_make_int(env, cint(1))

proc make_long(env, argc, argv): ErlNifTerm =
  return enif_make_long(env, clong(1))

proc make_int64(env, argc, argv): ErlNifTerm =
  return enif_make_int64(env, clonglong(1))

proc make_uint(env, argc, argv): ErlNifTerm =
  return enif_make_uint(env, cuint(1))

proc make_ulong(env, argc, argv): ErlNifTerm =
  return enif_make_ulong(env, culong(1))

proc make_uint64(env, argc, argv): ErlNifTerm =
  return enif_make_uint64(env, culonglong(1))

proc make_double(env, argc, argv): ErlNifTerm =
  return enif_make_double(env, cdouble(1.1))

proc make_new_binary(env, argc, argv): ErlNifTerm =
  var term: ErlNifTerm
  let binary_ptr = enif_make_new_binary(env, sizeof(cchar) * 4, addr(term))
  let res = cast[ptr UncheckedArray[char]](binary_ptr)
  res[0] = 't'
  res[1] = 'e'
  res[2] = 's'
  res[3] = 't'
  return term

proc make_new_map(env, argc, argv): ErlNifTerm =
  return enif_make_new_map(env)

proc make_map_from_arrays(env, argc, argv): ErlNifTerm =
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

proc make_atom(env, argc, argv): ErlNifTerm =
  return enif_make_atom(env, cstring("test"))

proc make_existing_atom(env, argc, argv): ErlNifTerm =
  var existing_atom: ErlNifTerm
  if not enif_make_existing_atom(env, cstring("test"), addr(existing_atom), ERL_NIF_LATIN1):
    return enif_make_badarg(env)
  return existing_atom

proc make_existing_atom_len(env, argc, argv): ErlNifTerm =
  var existing_atom: ErlNifTerm
  if not enif_make_existing_atom_len(env, cstring("test"), cuint(4), addr(existing_atom), ERL_NIF_LATIN1):
    return enif_make_badarg(env)
  return existing_atom

proc make_list(env, argc, argv): ErlNifTerm =
  let list_len: cuint = 3
  let t1 = enif_make_int(env, cint(1))
  let t2 = enif_make_int(env, cint(2))
  let t3 = enif_make_int(env, cint(3))
  return enif_make_list(env, list_len, t1, t2, t3)

proc make_list_cell(env, argc, argv): ErlNifTerm =
  let h = enif_make_int(env, cint(1))
  let t = enif_make_int(env, cint(2))
  return enif_make_list_cell(env, h, t)

proc make_list_from_array(env, argc, argv): ErlNifTerm =
  let values = [
    enif_make_int(env, cint(1)),
    enif_make_int(env, cint(2))
  ]
  return enif_make_list_from_array(env, values)

proc make_reverse_list(env, argc, argv): ErlNifTerm =
 let l1 = make_list(env, argc, argv)
 var l2: ErlNifTerm
 if not enif_make_reverse_list(env, l1, addr(l2)):
   return enif_make_badarg(env)
 return l2

proc make_copy(env, argc, argv): ErlNifTerm =
  let v = enif_make_int(env, cint(1))
  let c = enif_make_copy(env, v)
  doAssert(v == c)
  return c

proc make_pid(env, argc, argv): ErlNifTerm =
  var pid_term = ErlNifPid(pid: 0xBEEF)
  return enif_make_pid(env, addr(pid_term))

proc make_ref(env, argc, argv): ErlNifTerm =
  return enif_make_ref(env)

proc make_unique_integer(env, argc, argv): ErlNifTerm =
  return enif_make_unique_integer(env, ERL_NIF_UNIQUE_POSITIVE)

proc raise_exception(env, argc, argv): ErlNifTerm =
  let ex = enif_raise_exception(env, argv[0])
  doAssert(true == enif_has_pending_exception(env))
  return ex

proc snprintf(env, argc, argv): ErlNifTerm =
  let slen = 32.cuint
  var b = newString(slen)
  discard enif_snprintf(addr(b[0]), slen, "%T", argv[0])
  doAssert(b.cstring == "\"test\"")
  return enif_make_int(env, cint(0))

proc system_info(env, argc, argv): ErlNifTerm =
  var info = enif_system_info()
  doAssert(info.nif_major_version == nifMajor)
  doAssert(info.nif_minor_version == nifMinor)
  return enif_make_int(env, cint(0))

proc term_type(env, argc, argv): ErlNifTerm =
  doAssert(enif_term_type(env, argv[0]) == ERL_NIF_TERM_TYPE_INTEGER)
  doAssert(enif_term_type(env, argv[1]) == ERL_NIF_TERM_TYPE_LIST)
  doAssert(enif_term_type(env, argv[2]) == ERL_NIF_TERM_TYPE_TUPLE)
  doAssert(enif_term_type(env, argv[3]) == ERL_NIF_TERM_TYPE_BITSTRING)
  doAssert(enif_term_type(env, argv[4]) == ERL_NIF_TERM_TYPE_MAP)
  doAssert(enif_term_type(env, argv[5]) == ERL_NIF_TERM_TYPE_PID)
  return enif_make_int(env, cint(0))

proc compare(env, argc, argv): ErlNifTerm =
  let v = enif_compare(argv[0], argv[1])
  return enif_make_int(env, v)

export_nifs("Elixir.NimlerIntegration", [
  tonif("enif_compare", 2, compare),
  tonif("enif_term_type", 6, term_type),
  tonif("enif_system_info", 0, system_info),
  tonif("enif_snprintf", 1, snprintf),
  tonif("enif_raise_exception", 1, raise_exception),
  tonif("enif_is_atom", 1, is_atom),
  tonif("enif_is_binary", 1, is_binary),
  tonif("enif_is_current_process_alive", 0, is_current_process_alive),
  tonif("enif_is_empty_list", 1, is_empty_list),
  tonif("enif_is_exception", 1, is_exception),
  tonif("enif_is_fun", 1, is_fun),
  tonif("enif_is_identical", 2, is_identical),
  tonif("enif_is_list", 1, is_list),
  tonif("enif_is_map", 1, is_map),
  tonif("enif_is_number", 1, is_number),
  tonif("enif_is_pid", 1, is_pid),
  tonif("enif_is_pid_undefined", 1, is_pid_undefined),
  tonif("enif_is_process_alive", 1, is_process_alive),
  tonif("enif_is_ref", 1, is_ref),
  tonif("enif_is_tuple", 1, is_tuple),
  tonif("enif_get_atom", 1, get_atom),
  tonif("enif_get_atom_length", 1, get_atom_length),
  tonif("enif_get_string", 1, get_string),
  tonif("enif_get_int", 1, get_int),
  tonif("enif_get_long", 1, get_long),
  tonif("enif_get_int64", 1, get_int64),
  tonif("enif_get_uint", 1, get_uint),
  tonif("enif_get_ulong", 1, get_ulong),
  tonif("enif_get_uint64", 1, get_uint64),
  tonif("enif_get_double", 1, get_double),
  tonif("enif_get_tuple", 1, get_tuple),
  tonif("enif_get_list_length", 1, get_list_length),
  tonif("enif_get_list_cell", 1, get_list_cell),
  tonif("enif_get_map_size", 1, get_map_size),
  tonif("enif_get_map_value", 2, get_map_value),
  tonif("enif_get_local_pid", 1, get_local_pid),
  tonif("enif_make_map_put", 3, make_map_put),
  tonif("enif_make_map_remove", 2, make_map_remove),
  tonif("enif_make_map_update", 3, make_map_update),
  tonif("enif_make_string", 0, make_string),
  tonif("enif_make_string_len", 0, make_string_len),
  tonif("enif_make_list", 0, make_list),
  tonif("enif_make_list_cell", 0, make_list_cell),
  tonif("enif_make_list_from_array", 0, make_list_from_array),
  tonif("enif_make_reverse_list", 0, make_reverse_list),
  tonif("enif_make_tuple", 0, make_tuple),
  tonif("enif_make_tuple_from_array", 0, make_tuple_from_array),
  tonif("enif_make_int", 0, make_int),
  tonif("enif_make_long", 0, make_long),
  tonif("enif_make_int64", 0, make_int64),
  tonif("enif_make_uint", 0, make_uint),
  tonif("enif_make_ulong", 0, make_ulong),
  tonif("enif_make_uint64", 0, make_uint64),
  tonif("enif_make_double", 0, make_double),
  tonif("enif_make_new_binary", 0, make_new_binary),
  tonif("enif_make_new_map", 0, make_new_map),
  tonif("enif_make_map_from_arrays", 0, make_map_from_arrays),
  tonif("enif_make_atom", 0, make_atom),
  tonif("enif_make_existing_atom", 0, make_existing_atom),
  tonif("enif_make_existing_atom_len", 0, make_existing_atom_len),
  tonif("enif_make_copy", 0, make_copy),
  tonif("enif_make_pid", 0, make_pid),
  tonif("enif_make_ref", 0, make_ref),
  tonif("enif_make_unique_integer", 0, make_unique_integer)
])

