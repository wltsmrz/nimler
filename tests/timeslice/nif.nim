import os
import ../../nimler
import ../../nimler/codec

proc test_consume_timeslice(env: ptr ErlNifEnv, argc: cint, argv: ErlNifArgs): ErlNifTerm =
  var it = argv[0].decode(env, int32).get(0)
  var invocations = argv[1].decode(env, int32).get(0)
  inc(invocations)

  while it < 1000:
    if enif_consume_timeslice(env, cint(10)):
      let next_args = [ it.encode(env), invocations.encode(env) ]
      return enif_schedule_nif(env, test_consume_timeslice, next_args)
    os.sleep(1)
    inc(it)

  return ok(env, (it, invocations).encode(env)) # {:ok, {1000, 932}}

export_nifs("Elixir.NimlerWrapper", @[
  ("test_consume_timeslice", 2, test_consume_timeslice)
])

