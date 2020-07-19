import ../../nimler

func send_message(env: ptr ErlNifEnv; argc: cint; argv: ptr UncheckedArray[ErlNifTerm]): ErlNifTerm {.nif, arity: 2.} =
  doAssert(enif_is_pid(env, argv[0]))
  var pid = cast[ptr ErlNifPid](alloc0(sizeof(ErlNifPid)))

  if not enif_get_local_pid(env, argv[0], pid):
    return enif_raise_exception(env, enif_make_string(env, "Could not get local PID"))

  if not enif_send(env, pid, nil, argv[1]):
    return enif_raise_exception(env, enif_make_string(env, "Failed to send message"))

  dealloc(pid)

  return enif_make_int(env, 1)

func send_message_caller(env: ptr ErlNifEnv; argc: cint; argv: ptr UncheckedArray[ErlNifTerm]): ErlNifTerm {.nif, arity: 1.} =
  doAssert(enif_is_number(env, argv[0]))
  var pid: ErlNifPid

  if isNil(enif_self(env, pid.addr)):
    return enif_raise_exception(env, enif_make_string(env, "Could not get local PID"))

  if not enif_send(env, pid.addr, nil, argv[0]):
    return enif_raise_exception(env, enif_make_string(env, "Failed to send message"))

  return enif_make_int(env, 1)

export_nifs("Elixir.NimlerMessage", [
  send_message,
  send_message_caller
])

