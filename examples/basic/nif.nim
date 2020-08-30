import ../../nimler

func add_nums(env: ptr ErlNifEnv, a1: int, a2: int): int {.xnif: "add_numbers".} =
  a1 + a2

func sub_nums(env: ptr ErlNifEnv, a1: int, a2: int): int {.xnif: "sub_numbers".} =
  a1 - a2

exportNifs "Elixir.NumberAdder", [ add_nums, sub_nums ]

