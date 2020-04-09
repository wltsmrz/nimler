import ../../nimler
import ../../nimler/codec
import sequtils
import tables

proc codec_int32(env: ptr ErlNifEnv, argc: cint, argv: ErlNifArgs): ErlNifTerm {.nif(arity=2).} =
  let a1 = argv[0].decode(env, int32).get(0)
  let a2 = argv[1].decode(env, int32).get(0)
  let r = a1 + a2
  doAssert(decode(1'i32.encode(env), env, int32).get() == 1)
  return r.encode(env)

proc codec_uint32(env: ptr ErlNifEnv, argc: cint, argv: ErlNifArgs): ErlNifTerm {.nif(arity=2).} =
  let a1 = argv[0].decode(env, uint32).get(0)
  let a2 = argv[1].decode(env, uint32).get(0)
  let r = a1 + a2
  doAssert(decode(1'u32.encode(env), env, uint32).get() == 1)
  return r.encode(env)

proc codec_double(env: ptr ErlNifEnv, argc: cint, argv: ErlNifArgs): ErlNifTerm {.nif(arity=1).} =
  let v = argv[0].decode(env, float64).get()
  doAssert(decode(1.0'f64.encode(env), env, float64).get() == 1.0)
  return v.encode(env)

proc codec_uint64(env: ptr ErlNifEnv, argc: cint, argv: ErlNifArgs): ErlNifTerm {.nif(arity=1).} =
  let v = argv[0].decode(env, uint64).get()
  discard 1'u64.encode(env)
  doAssert(decode(1'u64.encode(env), env, uint64).get() == 1)
  return v.encode(env)

proc codec_atom(env: ptr ErlNifEnv, argc: cint, argv: ErlNifArgs): ErlNifTerm {.nif(arity=1).} =
  let a1 = argv[0].decode(env, ErlAtom).get()
  doAssert(a1.val == "test")
  doAssert(a1 == ErlAtom(val: "test"))
  return a1.encode(env)

proc codec_string(env: ptr ErlNifEnv, argc: cint, argv: ErlNifArgs): ErlNifTerm {.nif(arity=1).} =
  let a1 = argv[0].decode(env, string).get()
  let a2 = argv[1].decode(env, string).get("default")
  doAssert(a1 == "testϴ")
  doAssert(a2 == "default")
  let a3 = "test".encode(env)
  doAssert(a3.decode(env, string).get() == "test")
  return a1.encode(env)

proc codec_charlist(env: ptr ErlNifEnv, argc: cint, argv: ErlNifArgs): ErlNifTerm {.nif(arity=1).} =
  let a1 = argv[0].decode(env, ErlCharlist).get()
  let a2 = argv[1].decode(env, ErlCharlist).get("default".toSeq())
  doAssert(a1 == "test".toSeq())
  doAssert(a2 == "default".toSeq())
  let a3 = "test".toSeq().encode(env)
  doAssert(a3.decode(env, ErlCharlist).get() == "test".toSeq())
  return a1.encode(env)

proc codec_binary(env: ptr ErlNifEnv, argc: cint, argv: ErlNifArgs): ErlNifTerm {.nif(arity=1).} =
  let a1 = argv[0].decode(env, ErlBinary)
  if a1.isNone():
    return enif_make_badarg(env)
  let a1v = a1.get()
  doAssert(cast[cstring](a1v.data) == "test".cstring)
  return a1v.encode(env)

proc codec_list(env: ptr ErlNifEnv, argc: cint, argv: ErlNifArgs): ErlNifTerm {.nif(arity=1).} =
  var l = argv[0].decode(env, seq[int]).get()
  doAssert(l == @[1,2,3])
  return @[1,2,3].encode(env)

proc codec_tuple(env: ptr ErlNifEnv, argc: cint, argv: ErlNifArgs): ErlNifTerm {.nif(arity=1).} =
  var a1 = argv[0].decode(env, tuple[a: string, b: int, c: float]).get()
  doAssert(a1 == ("test", 1, 1.2))
  return ("test", 1, 1.2).encode(env)

proc codec_map(env: ptr ErlNifEnv, argc: cint, argv: ErlNifArgs): ErlNifTerm {.nif(arity=3).} =
  var a1 = argv[0].decode(env, Table[ErlCharlist, int]).get()
  var a2 = argv[1].decode(env, Table[string, int]).get()
  var a3 = argv[2].decode(env, Table[ErlAtom, string]).get()

  return (a1, a2, a3).encode(env)

proc codec_result_ok(env: ptr ErlNifEnv, argc: cint, argv: ErlNifArgs): ErlNifTerm {.nif(arity=1).} =
  return argv[0].ok(env)

proc codec_result_error(env: ptr ErlNifEnv, argc: cint, argv: ErlNifArgs): ErlNifTerm {.nif(arity=1).} =
  return error(env, argv[0])

export_nifs("Elixir.NimlerWrapper", [
  codec_int32,
  codec_uint32,
  codec_uint64,
  codec_double,
  codec_atom,
  codec_string,
  codec_charlist,
  codec_binary,
  codec_tuple,
  codec_list,
  codec_map,
  codec_result_ok,
  codec_result_error
])

