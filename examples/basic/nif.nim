import ../../nimler
import ../../nimler/codec

using
  env: ptr ErlNifEnv
  argc: cint
  argv: ErlNifArgs

func add_nums(env; argc; argv): ErlNifTerm {.nif, arity: 2, nif_name: "add_numbers", dirty_cpu.} =
  let a1 = env.from_term(argv[0], int32).get(0)
  let a2 = env.from_term(argv[1], int32).get(0)
  let r = a1 + a2
  return env.to_term(r)

func sub_numbers(env; argc; argv): ErlNifTerm {.nif, arity: 2.} =
  let a1 = env.from_term(argv[0], int32).get(0)
  let a2 = env.from_term(argv[1], int32).get(0)
  let r = a1 - a2
  return env.to_term(r)

export_nifs("Elixir.NumberAdder", [
  add_nums,
  sub_numbers
])

