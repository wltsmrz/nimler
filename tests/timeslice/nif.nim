import os
import ../../nimler

proc test_consume_timeslice(env: ptr ErlNifEnv, argc: cint, argv: ErlNifArgs): ErlNifTerm =
  var it, invocations: cint
  discard enif_get_int(env, argv[0], addr(it))
  discard enif_get_int(env, argv[1], addr(invocations))

  while it < 1000:
    if enif_consume_timeslice(env, cint(10)):
      var next_arga = [enif_make_int(env, it), enif_make_int(env, invocations + 1)]
      var next_argc = cint(2)
      var next_argv = cast [ptr ErlNifArgs](addr(next_arga))

      return enif_schedule_nif(env,
        cstring("test_consume_timeslice"),
        cint(0),
        test_consume_timeslice,
        next_argc,
        next_argv
      )

    os.sleep(1)
    inc(it)

  return enif_make_tuple(env, cuint(3),
    AtomOk.encode(env),
    int32(it).encode(env),
    int32(invocations).encode(env))


export_nifs("Elixir.NimlerWrapper", @[
  ("test_consume_timeslice", 1, test_consume_timeslice)
])

