import ../../nimler
import ../../nimler/codec
import options
import tables

using
  env: ptr ErlNifEnv
  argc: cint
  argv: ErlNifArgs

proc codec_options(env; argc; argv): ErlNifTerm {.nif(arity=2).} =
  let a1 = env.from_term(argv[0], int)
  if a1.isNone():
    return enif_make_atom(env, "bad_type")
  let a2 = env.from_term(argv[1], int).get(-1)
  return env.to_term(a2)

proc codec_int(env; argc; argv): ErlNifTerm {.nif(arity=2).} =
  let a1 = env.from_term(argv[0], int).get()
  let a2 = env.from_term(argv[1], int).get()
  doAssert(env.from_term(env.to_term(1), int).get() == 1)
  return env.to_term(a1 + a2)

proc codec_int32(env; argc; argv): ErlNifTerm {.nif(arity=2).} =
  let a1 = env.from_term(argv[0], int32).get()
  let a2 = env.from_term(argv[1], int32).get()
  doAssert(env.from_term(env.to_term(1'i32), int32).get() == 1)
  return env.to_term(a1 + a2)

proc codec_uint32(env; argc; argv): ErlNifTerm {.nif(arity=2).} =
  let a1 = env.from_term(argv[0], uint32).get()
  let a2 = env.from_term(argv[1], uint32).get()
  doAssert(env.from_term(env.to_term(1'u32), uint32).get() == 1)
  return env.to_term(a1 + a2)

proc codec_uint64(env; argc; argv): ErlNifTerm {.nif(arity=1).} =
  let a1 = env.from_term(argv[0], uint64).get()
  doAssert(env.from_term(env.to_term(1'u64), uint64).get() == 1)
  return env.to_term(a1)

proc codec_double(env; argc; argv): ErlNifTerm {.nif(arity=1).} =
  let a1 = env.from_term(argv[0], float).get()
  doAssert(env.from_term(env.to_term(1.0'f64), float).get() == 1.0)
  return env.to_term(a1)

proc codec_atom(env, argc, argv): ErlNifTerm {.nif(arity=1).} =
  let a1 = env.from_term(argv[0], ErlAtom).get()
  doAssert(a1 == ErlAtom(val: "test"))
  return env.to_term(a1)

proc codec_charlist(env, argc, argv): ErlNifTerm {.nif(arity=1).} =
  let a1 = env.from_term(argv[0], ErlCharlist).get()
  doAssert(a1 == @"test")
  doAssert(env.from_term(env.to_term(@"test2"), ErlCharlist).get() == @"test2")
  return env.to_term(a1)

proc codec_string(env, argc, argv): ErlNifTerm {.nif(arity=1).} =
  let a1 = env.from_term(argv[0], string).get()
  doAssert(a1 == "testϴ")
  doAssert(env.from_term(env.to_term("test2"), string).get() == "test2")
  return env.to_term(a1)

proc codec_binary(env, argc, argv): ErlNifTerm {.nif(arity=1).} =
  let a1 = env.from_term(argv[0], ErlBinary).get()
  doAssert(cast[cstring](a1.data) == "test".cstring)
  return env.to_term(a1)

proc codec_list_int(env, argc, argv): ErlNifTerm {.nif(arity=1).} =
  let a1 = env.from_term(argv[0], seq[int])
  if a1.isNone():
    return env.to_term(AtomError)
  doAssert(a1.get() == @[1,2,3])
  return env.to_term(a1.get())

proc codec_list_string(env, argc, argv): ErlNifTerm {.nif(arity=1).} =
  let a1 = env.from_term(argv[0], seq[string]).get()
  doAssert(a1 == @["a","b","c"])
  return env.to_term(a1)

proc codec_tuple(env, argc, argv): ErlNifTerm {.nif(arity=1).} =
  let a1 = env.from_term(argv[0], (string, int, float)).get()
  doAssert(a1 == ("test", 1, 1.2))
  return env.to_term(a1)

proc codec_map(env, argc, argv): ErlNifTerm {.nif(arity=3).} =
  let a1 = env.from_term(argv[0], Table[ErlCharlist, int]).get()
  let a2 = env.from_term(argv[1], Table[string, int]).get()
  let a3 = env.from_term(argv[2], Table[ErlAtom, string]).get()
  return env.to_term((a1, a2, a3))

proc codec_result_ok(env, argc, argv): ErlNifTerm {.nif(arity=2).} =
  return env.ok(argv[0], argv[1])

proc codec_result_error(env, argc, argv): ErlNifTerm {.nif(arity=2).} =
  return env.error(argv[0], argv[1])

export_nifs("Elixir.NimlerCodec", [
  codec_options,
  codec_int,
  codec_int32,
  codec_uint32,
  codec_uint64,
  codec_double,
  codec_atom,
  codec_charlist,
  codec_string,
  codec_binary,
  codec_list_int,
  codec_list_string,
  codec_tuple,
  codec_map,
  codec_result_ok,
  codec_result_error
])

