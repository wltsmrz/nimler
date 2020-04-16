import os
import ../../nimler
import ../../nimler/codec

using
  env: ptr ErlNifEnv
  argc: cint
  argv: ErlNifArgs

proc consume_timeslice(env; argc; argv): ErlNifTerm =
  var it = env.from_term(argv[0], int).get(0)
  var invocations = env.from_term(argv[1], int).get(0)
  inc(invocations)

  while it < 1000:
    inc(it)
    if enif_consume_timeslice(env, cint(100)):
      let next_args = [ env.to_term(it), env.to_term(invocations) ]
      return enif_schedule_nif(env, consume_timeslice, next_args)
    os.sleep(1)

  return env.ok(env.to_term(it), env.to_term(invocations))

func test_consume_timeslice(env; argc; argv): ErlNifTerm {.nif: 2.} =
  consume_timeslice(env, argc, argv)

export_nifs("Elixir.NimlerTimeslice", [test_consume_timeslice])

