import os
import ../../nimler

proc test_consume_timeslice(env: ptr ErlNifEnv, argc: cint, argv: ErlNifArgs): ErlNifTerm =
  var it, invocations: int32

  discard enif_get_int(env, argv[0], addr(it))
  discard enif_get_int(env, argv[1], addr(invocations))

  inc(invocations)

  while it < 1000:
    if enif_consume_timeslice(env, cint(10)):
      return enif_schedule_nif(env,
        cstring("test_consume_timeslice"),
        cint(0),
        test_consume_timeslice,
        [ it.encode(env), invocations.encode(env) ]
      )

    os.sleep(1)
    inc(it)

  return enif_make_tuple(env, cuint(3),
    AtomOk.encode(env),
    it.encode(env),
    invocations.encode(env))

export_nifs("Elixir.NimlerWrapper", @[
  ("test_consume_timeslice", 2, test_consume_timeslice)
])

