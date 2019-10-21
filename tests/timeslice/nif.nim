import os
import ../../nimler

proc test_consume_timeslice(env: ptr ErlNifEnv, argc: cint, argv: ErlNifArgs): ErlNifTerm =
  var it, invocations: int32

  discard enif_get_int(env, argv[0], addr(it))
  discard enif_get_int(env, argv[1], addr(invocations))

  inc(invocations)

  while it < 1000:
    if enif_consume_timeslice(env, cint(10)):
      let fun_name = cstring("test_consume_timeslice")
      let flags = cint(0)
      let fptr = test_consume_timeslice
      let next_args = [ it.encode(env), invocations.encode(env) ]
      return enif_schedule_nif(env, fun_name, flags, fptr, next_args)
    os.sleep(1)
    inc(it)

  let result = encode(
    it.encode(env),
    invocations.encode(env),
    env
  )
  return ResultOk(result).encode(env) # {:ok, {1000, 932}}

export_nifs("Elixir.NimlerWrapper", @[
  ("test_consume_timeslice", 2, test_consume_timeslice)
])

