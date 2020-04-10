import os
import ../../nimler
import ../../nimler/codec

using
  env: ptr ErlNifEnv
  argc: cint
  argv: ErlNifArgs

proc test_consume_timeslice(env; argc; argv): ErlNifTerm =
  var it = env.from_term(argv[0], int).get(0)
  var invocations = env.from_term(argv[1], int).get(0)
  inc(invocations)

  while it < 1000:
    if enif_consume_timeslice(env, cint(10)):
      let next_args = [ env.to_term(it), env.to_term(invocations) ]
      return enif_schedule_nif(env, test_consume_timeslice, next_args)
    os.sleep(1)
    inc(it)

  return env.ok(env.to_term(it), env.to_term(invocations))

export_nifs("Elixir.NimlerWrapper", [
  tonif("test_consume_timeslice", 2, test_consume_timeslice)
])

