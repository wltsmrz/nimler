import ../../nimler
import ../../nimler/codec

proc add_numbers(env: ptr ErlNifEnv, argc: cint, argv: ErlNifArgs): ErlNifTerm {.raises: [].} =
  let a1 = argv[0].decode(env, uint32).get(0)
  let a2 = argv[1].decode(env, uint32).get(0)
  return (a1 + a2).encode(env)

export_nifs("Elixir.NumberAdder", [
  ("add_numbers", 2, add_numbers)
])

