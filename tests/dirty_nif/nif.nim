import os
import ../../nimler

using
  env: ptr ErlNifEnv
  argc: cint
  argv: ErlNifArgs

func fib(n: uint64): uint64 =
  if n > 2.uint64:
    return fib(n - 1) + fib(n - 2)
  return n

func dirty_cpu(env; argc; argv): ErlNifTerm {.nif, arity: 0, dirty_cpu.} =
  let res = fib(30)
  return enif_make_uint64(env, res)

proc dirty_io(env; argc; argv): ErlNifTerm {.nif, arity: 0, dirty_io.} =
  os.sleep(100)
  return enif_make_int(env, 1)

export_nifs("Elixir.NimlerDirtyNif", [
  dirty_cpu,
  dirty_io
])
