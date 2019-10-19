import os
import ../../nimler

proc dirty_cpu(env: ptr ErlNifEnv, argc: cint, argv: ErlNifArgs): ErlNifTerm =
  os.sleep(1000)
  return enif_make_int(env, 1)

proc dirty_io(env: ptr ErlNifEnv, argc: cint, argv: ErlNifArgs): ErlNifTerm =
  os.sleep(1000)
  return enif_make_int(env, 1)

export_nifs("Elixir.NimlerWrapper", [
  ("dirty_cpu", 0, dirty_cpu, ERL_NIF_DIRTY_CPU),
  ("dirty_io", 0, dirty_io, ERL_NIF_DIRTY_IO),
])
