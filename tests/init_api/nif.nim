import ../../nimler

proc on_load(env: ptr ErlNifEnv, priv_data: ptr pointer, load_info: ErlNifTerm): cint =
  var load_data: cint
  if not enif_get_int(env, load_info, addr(load_data)):
    return cint(1)
  doAssert(load_data == 123)

  var m = enif_alloc(sizeof(cint))
  var m_a = cast [ptr cint](m)
  priv_data[] = m_a
  m_a[] = 123

  return cint(0)

proc on_unload(env: ptr ErlNifEnv, priv_data: pointer): void =
  enif_free(priv_data)

proc test(env: ptr ErlNifEnv, argc: cint, argv: ErlNifArgs): ErlNifTerm =
  return enif_make_int(env, 1)

proc test_dirty(env: ptr ErlNifEnv, argc: cint, argv: ErlNifArgs): ErlNifTerm =
  return enif_make_int(env, 1)

proc test_priv_data(env: ptr ErlNifEnv, argc: cint, argv: ErlNifArgs): ErlNifTerm =
  var ptr_priv = enif_priv_data(env)
  if isNil(ptr_priv):
    return enif_make_badarg(env)
  var vv = cast [ptr cint](ptr_priv)
  doAssert(vv[] == 123)
  return enif_make_int(env, 1)


export_nifs("Elixir.NimlerWrapper", NifOptions(
  funcs: @[ ("test", 0, test), ("test_priv", 0, test_priv_data) ],
  dirty_funcs: @[ ("test_dirty", 0, test_dirty, ERL_NIF_DIRTY_IO) ],
  load: on_load,
  unload: on_unload
))

