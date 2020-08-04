import ../../nimler

using
  env: ptr ErlNifEnv
  priv_data: ptr pointer
  argc: cint
  argv: ErlNifArgs
  term: ErlNifTerm
  load_info: ErlNifTerm

func on_load(env, priv_data, load_info): cint =
  var load_data: cint
  if not enif_get_int(env, load_info, addr(load_data)):
    return cint(1)

  doAssert(load_data == 123)

  var m = enif_alloc(cast[csize_t](sizeof(cint)))
  var m_a = cast [ptr cint](m)
  priv_data[] = m_a
  m_a[] = 123

  return cint(0)

func on_unload(env: ptr ErlNifEnv, priv_data: pointer): void =
  enif_free(priv_data)

func test(env, argc, argv): ErlNifTerm {.nif, arity: 0.} =
  enif_make_int(env, 1)

func test_dirty(env, argc, argv): ErlNifTerm {.nif, arity: 0, dirty_io.} =
  enif_make_int(env, 1)

func test_priv_data(env, argc, argv): ErlNifTerm {.nif, arity: 0, nif_name: "test_priv".} =
  var ptr_priv = enif_priv_data(env)
  if isNil(ptr_priv):
    return enif_make_badarg(env)
  var vv = cast [ptr cint](ptr_priv)
  doAssert(vv[] == 123)
  return enif_make_int(env, 1)

export_nifs(
  module_name="Elixir.NimlerInitApi",
  nifs=[
    test,
    test_priv_data,
    test_dirty
  ],
  on_load=on_load,
  on_unload=on_unload
)

