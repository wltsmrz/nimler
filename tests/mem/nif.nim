import os
import ../../nimler

# GC_disableMarkAndSweep()
# GC_setMaxPause(10)

proc test_mem(env: ptr ErlNifEnv, argc: cint, argv: ErlNifArgs): ErlNifTerm =
  let str = argv[0].decode(env, ErlString).get(ErlString("default_str"))
  discard repr(str)
  GC_fullCollect()
  let res = str.encode(env)
  GC_fullCollect()
  echo "occupied mem: " & repr(getOccupiedMem() / 1_000)
  return res

export_nifs("Elixir.NimlerWrapper", NifOptions(
  funcs: @[ ("test_mem", 1, test_mem) ]
))

