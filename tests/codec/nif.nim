import ../../nimler
import tables

using
  env: ptr ErlNifEnv
  argc: cint
  argv: ErlNifArgs

func codec_options(env; argc; argv): ErlNifTerm {.nif, arity: 2.} =
  let a1 = env.from_term(argv[0], int)
  if a1.isNone():
    return enif_make_atom(env, "bad_type")
  let a2 = env.from_term(argv[1], int).get(-1)
  return env.to_term(a2)

{.push checks: off.}
func codec_int(env; argc; argv): ErlNifTerm {.nif, arity: 2.} =
  let a1 = env.from_term(argv[0], int).get()
  let a2 = env.from_term(argv[1], int).get()
  doAssert(env.from_term(env.to_term(1), int).get() == 1)
  return env.to_term(a1 + a2)

func codec_int32(env; argc; argv): ErlNifTerm {.nif, arity: 2.} =
  let a1 = env.from_term(argv[0], int32).get()
  let a2 = env.from_term(argv[1], int32).get()
  doAssert(env.from_term(env.to_term(1'i32), int32).get() == 1)
  return env.to_term(a1 + a2)

func codec_uint32(env; argc; argv): ErlNifTerm {.nif, arity: 2.} =
  let a1 = env.from_term(argv[0], uint32).get()
  let a2 = env.from_term(argv[1], uint32).get()
  doAssert(env.from_term(env.to_term(1'u32), uint32).get() == 1)
  return env.to_term(a1 + a2)

func codec_uint64(env; argc; argv): ErlNifTerm {.nif, arity: 1.} =
  let a1 = env.from_term(argv[0], uint64).get()
  doAssert(env.from_term(env.to_term(1'u64), uint64).get() == 1)
  return env.to_term(a1)

func codec_double(env; argc; argv): ErlNifTerm {.nif, arity: 1.} =
  let a1 = env.from_term(argv[0], float).get()
  doAssert(env.from_term(env.to_term(1.0'f64), float).get() == 1.0)
  return env.to_term(a1)
{.pop.}

func codec_atom(env, argc, argv): ErlNifTerm {.nif, arity: 1.} =
  let a1 = env.from_term(argv[0], ErlAtom).get()
  doAssert(a1 == ErlAtom("test"))
  return env.to_term(a1)

func codec_charlist(env, argc, argv): ErlNifTerm {.nif, arity: 1.} =
  let a1 = env.from_term(argv[0], seq[char]).get()
  doAssert(a1 == @"test")
  doAssert(env.from_term(env.to_term(@"test2"), seq[char]).get() == @"test2")
  return env.to_term(a1)

func codec_string(env, argc, argv): ErlNifTerm {.nif, arity: 1.} =
  let a1 = env.from_term(argv[0], string).get()
  doAssert(a1 == "testϴ")
  doAssert(env.from_term(env.to_term("test2"), string).get() == "test2")
  return env.to_term(a1)

func codec_binary(env, argc, argv): ErlNifTerm {.nif, arity: 1.} =
  let a1 = env.from_term(argv[0], seq[byte]).get()
  doAssert(a1 == @[116.byte, 101, 115, 116, 0])

  let a2 = toTerm(env, toOpenArrayByte("test", 0, 3))
  let a3 = toTerm(env, "test")
  doAssert(enif_is_identical(a2, a3))

  doAssert(@[116.byte, 101, 115, 116] == fromTerm(env, a3, seq[byte]).get())
  doAssert(@[116.byte, 101, 115, 116] == fromTerm(env, a2, seq[byte]).get())

  return env.to_term(a1)

func codec_list_int(env, argc, argv): ErlNifTerm {.nif, arity: 1.} =
  let a1 = env.from_term(argv[0], seq[int])
  if a1.isNone():
    return env.to_term(AtomError)
  doAssert(a1.get() == @[1,2,3])
  return env.to_term(a1.get())

func codec_list_string(env, argc, argv): ErlNifTerm {.nif, arity: 1.} =
  let a1 = env.from_term(argv[0], seq[string]).get()
  doAssert(a1 == @["a","b","c"])
  return env.to_term(a1)

func codec_tuple(env, argc, argv): ErlNifTerm {.nif, arity: 1.} =
  let a1 = env.from_term(argv[0], (string, int, float)).get()
  doAssert(a1 == ("test", 1, 1.2))
  return env.to_term(a1)

func codec_map(env, argc, argv): ErlNifTerm {.nif, arity: 3.} =
  let a1 = env.from_term(argv[0], Table[seq[char], int]).get()
  let a2 = env.from_term(argv[1], Table[string, int]).get()
  let a3 = env.from_term(argv[2], Table[ErlAtom, string]).get()
  return env.to_term((a1, a2, a3))

func codec_keywords(env, argc, argv): ErlNifTerm {.nif, arity: 1.} =
  let a1 = fromTerm(env, argv[0], ErlKeywords[int]).get()
  doAssert(a1 == @[ (ErlAtom("a"), 1), (ErlAtom("b"), 2) ])

  let a2 = fromTerm(env, argv[0], ErlKeywords[ErlTerm]).get()
  doAssert(a2[0][0] == ErlAtom("a"))
  doAssert(a2[0][1] == toTerm(env, 1))
  doAssert(a2[1][0] == ErlAtom("b"))
  doAssert(a2[1][1] == toTerm(env, 2))

  type OO = object
    a: int
    b: int

  let a3 = fromTerm(env, argv[0], OO).get()
  doAssert(a3.a == 1)
  doAssert(a3.b == 2)

  type OOO = object
    a: int
    b: int
    c: int

  let a4 = toTerm(env, OOO(a: 1, b: 2, c: 3))

  let a5 = fromTerm(env, a4, OOO).get()
  doAssert(a5.a == 1)
  doAssert(a5.b == 2)
  doAssert(a5.c == 3)

  var a6: ErlKeywords[ErlTerm]
  add(a6, "a", toTerm(env, 1))
  add(a6, "b", toTerm(env, 2))
  add(a6, "c", toTerm(env, 3))

  doAssert(hasKey(a6, ErlAtom("a")))
  doAssert(not hasKey(a6, ErlAtom("z")))
  doAssert(hasKey(a6, "a"))
  doAssert(not hasKey(a6, "z"))

  doAssert(getKey(a6, "a") == (true, toTerm(env, 1)))
  doAssert(getKey(a6, "b") == (true, toTerm(env, 2)))
  doAssert(getKey(a6, "c") == (true, toTerm(env, 3)))
  doAssert(getKey(a6, "d") == (false, ErlNifTerm(0)))

  return toTerm(env, a4)

func codec_result_ok(env, argc, argv): ErlNifTerm {.nif, arity: 1.} =
  let a = ok(env, argv[0])
  let b = ok(env, fromTerm(env, argv[0], int).get())
  let c = ok(env, 1)
  doAssert(enif_is_identical(a, b))
  doAssert(enif_is_identical(a, c))

  let r: ErlResult[int] = (AtomOk, 1)
  doAssert(enif_is_identical(toTerm(env, r), a))

  return env.ok(argv[0])

func codec_result_error(env, argc, argv): ErlNifTerm {.nif, arity: 1.} =
  let a = error(env, argv[0])
  let b = error(env, fromTerm(env, argv[0], int).get())
  let c = error(env, 1)
  doAssert(enif_is_identical(a, b))
  doAssert(enif_is_identical(a, c))

  let r: ErlResult[int] = (AtomError, 1)
  doAssert(enif_is_identical(toTerm(env, r), a))

  return env.error(argv[0])

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
  codec_keywords,
  codec_result_ok,
  codec_result_error
])

