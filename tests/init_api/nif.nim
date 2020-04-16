import ../../nimler

using
  env: ptr ErlNifEnv
  priv_data: ptr pointer
  argc: cint
  argv: ErlNifArgs
  term: ErlNifTerm
  load_info: ErlNifTerm

proc on_load(env, priv_data, load_info): cint =
  var load_data: cint
  if not enif_get_int(env, load_info, addr(load_data)):
    return cint(1)
  doAssert(load_data == 123)

  var m = enif_alloc(cast[csize_t](sizeof(cint)))
  var m_a = cast [ptr cint](m)
  priv_data[] = m_a
  m_a[] = 123

  return cint(0)

proc on_unload(env: ptr ErlNifEnv, priv_data: pointer): void =
  enif_free(priv_data)

proc test(env, argc, argv): ErlNifTerm {.nif(arity=0).} =
  enif_make_int(env, 1)

func test_dirty(env, argc, argv): ErlNifTerm =
  enif_make_int(env, 1)

proc test_priv_data(env, argc, argv): ErlNifTerm {.nif(name="test_priv", arity=0).}=
  var ptr_priv = enif_priv_data(env)
  if isNil(ptr_priv):
    return enif_make_badarg(env)
  var vv = cast [ptr cint](ptr_priv)
  doAssert(vv[] == 123)
  return enif_make_int(env, 1)

export_nifs("Elixir.NimlerInitApi", [
  test,
  test_priv_data,
  tonif(test_dirty, "test_dirty", 0, flags=ERL_NIF_DIRTY_IO)
], on_load=on_load, on_unload=on_unload)
