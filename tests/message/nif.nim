import ../../nimler

func error(env: ptr ErlNifEnv, msg: string): ErlNifTerm =
  return enif_make_tuple(env, cast[csize_t](2),
    enif_make_atom(env, "error"),
    enif_make_string(env, msg))

func send_message(env: ptr ErlNifEnv; argc: cint; argv: ptr UncheckedArray[ErlNifTerm]): ErlNifTerm {.nif, arity: 2.} =
  doAssert(enif_is_pid(env, argv[0]))
  var pid: ErlNifPid

  if not enif_get_local_pid(env, argv[0], pid.addr):
    return error(env, "Could not get local PID")

  if not enif_send(env, pid.addr, nil, argv[1]):
    return error(env, "Failed to send message")

  return enif_make_atom(env, "ok")

func send_message_caller(env: ptr ErlNifEnv; argc: cint; argv: ptr UncheckedArray[ErlNifTerm]): ErlNifTerm {.nif, arity: 1.} =
  doAssert(enif_is_number(env, argv[0]))
  var pid: ErlNifPid

  if isNil(enif_self(env, pid.addr)):
    return error(env, "Could not get local PID")

  if not enif_send(env, pid.addr, nil, argv[0]):
    return error(env, "Failed to send message")

  return enif_make_atom(env, "ok")

export_nifs("Elixir.NimlerMessage", [
  send_message,
  send_message_caller
])

