# import os
import ../../nimler
import ../../nimler/codec

proc fib(n: uint64): uint64 =
  if n > 2.uint64:
    return fib(n - 1) + fib(n - 2)
  return n

proc dirty_cpu(env: ptr ErlNifEnv, argc: cint, argv: ErlNifArgs): ErlNifTerm =
  discard fib(30).encode(env)

  return enif_make_int(env, 1)

proc dirty_io(env: ptr ErlNifEnv, argc: cint, argv: ErlNifArgs): ErlNifTerm =

  return enif_make_int(env, 1)

export_nifs("Elixir.NimlerWrapper", @[
    ("dirty_cpu", 0, dirty_cpu, ERL_NIF_DIRTY_CPU),
    ("dirty_io", 0, dirty_io, ERL_NIF_DIRTY_IO)
])
