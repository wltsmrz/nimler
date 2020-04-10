import ../../nimler

using
  env: ptr ErlNifEnv
  argc: cint
  argv: ErlNifArgs

type MyResource = object
  thing: int32

type MyResourcePriv = object
  resource_type: ptr ErlNifResourceType

proc on_unload(env; priv_data: pointer): void =
  enif_free(priv_data)

proc on_load(env; priv_data: ptr pointer, load_info: ErlNifTerm): cint =
  let priv = cast[ptr MyResourcePriv](enif_alloc(cast[csize_t](sizeof(MyResourcePriv))))
  var flags_created: ErlNifResourceFlags
  priv.resource_type = enif_open_resource_type(env, "MyResource", ERL_NIF_RT_CREATE, addr(flags_created))
  priv_data[] = priv
  return cint(0)

proc create_resource(env; argc; argv): ErlNifTerm {.nif(arity=0).} =
  let priv = cast[ptr MyResourcePriv](enif_priv_data(env))
  let resource = cast[ptr MyResource](enif_alloc_resource(priv.resource_type, cast[csize_t](sizeof(MyResource))))
  var resource_term = enif_make_resource(env, resource)
  enif_release_resource(resource)
  return resource_term

proc update_resource(env; argc; argv): ErlNifTerm {.nif(arity=1).} =
  let priv = cast[ptr MyResourcePriv](enif_priv_data(env))
  var resource_ptr: ptr MyResource
  if not enif_get_resource(env, argv[0], priv[].resource_type, addr(resource_ptr)):
    return enif_make_badarg(env)
  resource_ptr.thing = 1234
  return argv[0]

proc check_resource(env; argc; argv): ErlNifTerm {.nif(arity=1).} =
  let priv = cast[ptr MyResourcePriv](enif_priv_data(env))
  var resource_ptr: ptr MyResource
  if not enif_get_resource(env, argv[0], priv[].resource_type, addr(resource_ptr)):
    return enif_make_badarg(env)
  doAssert(resource_ptr.thing == 1234)
  return argv[0]

export_nifs("Elixir.NimlerWrapper", [
  create_resource,
  update_resource,
  check_resource
], on_load=on_load, on_unload=on_unload)

