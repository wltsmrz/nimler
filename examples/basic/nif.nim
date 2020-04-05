import ../../nimler
import ../../nimler/codec

proc add_numbers(env: ptr ErlNifEnv, argc: cint, argv: ErlNifArgs): ErlNifTerm =
  let a1 = argv[0].decode(env, uint32).get(0)
  let a2 = argv[1].decode(env, uint32).get(0)
  let r = a1 + a2
  return r.encode(env)

# var options {.compileTime.}: NifOptions
# options.name = "Elixir.NumberAdder"
# options.funcs = @[
#   add_numbers.toNif("add_numbers", 2)
# ]
# export_nifs(options)

export_nifs("Elixir.NumberAdder", @[
  ("add_numbers", 2, add_numbers)
])

