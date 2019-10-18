import ../../nimler

proc codec_int(env: ptr ErlNifEnv, argc: cint, argv: ErlNifArgs): ErlNifTerm =
  let a1 = argv[0].decode(env, int).get(0)
  let a2 = argv[1].decode(env, int).get(0)
  let r = a1 + a2
  return r.encode(env)

proc codec_uint(env: ptr ErlNifEnv, argc: cint, argv: ErlNifArgs): ErlNifTerm =
  let a1 = argv[0].decode(env, uint).get(0)
  let a2 = argv[1].decode(env, uint).get(0)
  let r = a1 + a2
  return r.encode(env)

proc codec_atom(env: ptr ErlNifEnv, argc: cint, argv: ErlNifArgs): ErlNifTerm =
  let a1 = argv[0].decode(env, ErlAtom).get()
  return a1.encode(env)

export_nifs("Elixir.NimlerWrapper", @[
  ("codec_int", 2, codec_int),
  ("codec_uint", 2, codec_uint),
  ("codec_atom", 1, codec_atom)
])

