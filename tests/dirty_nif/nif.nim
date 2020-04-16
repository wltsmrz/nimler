import os
import ../../nimler

using
  env: ptr ErlNifEnv
  argc: cint
  argv: ErlNifArgs

proc fib(n: uint64): uint64 =
  if n > 2.uint64:
    return fib(n - 1) + fib(n - 2)
  return n

proc dirty_cpu(env; argc; argv): ErlNifTerm =
  discard fib(30)
  return enif_make_int(env, 1)

proc dirty_io(env; argc; argv): ErlNifTerm =
  os.sleep(100)
  return enif_make_int(env, 1)

export_nifs("Elixir.NimlerDirtyNif", [
  tonif(dirty_cpu, "dirty_cpu", 0, flags=ERL_NIF_DIRTY_CPU),
  tonif(dirty_io, "dirty_io", 0, flags=ERL_NIF_DIRTY_IO)
])
