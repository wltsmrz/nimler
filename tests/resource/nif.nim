import ../../nimler
import ../../nimler/codec

type MyResource = object
  thing: int32

type MyResourcePriv = object
  resource_type: ptr ErlNifResourceType

proc on_unload(env: ptr ErlNifEnv, priv_data: pointer): void =
  enif_free(priv_data)

proc on_load(env: ptr ErlNifEnv, priv_data: ptr pointer, load_info: ErlNifTerm): cint =
  let priv = cast[ptr MyResourcePriv](enif_alloc(cast[csize_t](sizeof(MyResourcePriv))))
  var flags_created: ErlNifResourceFlags
  priv.resource_type = enif_open_resource_type(env, "MyResource", ERL_NIF_RT_CREATE, addr(flags_created))
  priv_data[] = priv
  return cint(0)

proc create_resource(env: ptr ErlNifEnv, argc: cint, argv: ErlNifArgs): ErlNifTerm =
  let priv = cast[ptr MyResourcePriv](enif_priv_data(env))
  let resource = cast[ptr MyResource](enif_alloc_resource(priv.resource_type, cast[csize_t](sizeof(MyResource))))
  var resource_term = enif_make_resource(env, resource)
  enif_release_resource(resource)
  return resource_term

proc update_resource(env: ptr ErlNifEnv, argc: cint, argv: ErlNifArgs): ErlNifTerm =
  let priv = cast[ptr MyResourcePriv](enif_priv_data(env))
  var resource_ptr: ptr MyResource
  if not enif_get_resource(env, argv[0], priv[].resource_type, addr(resource_ptr)):
    return enif_make_badarg(env)
  resource_ptr.thing = 1234
  return argv[0]

proc check_resource(env: ptr ErlNifEnv, argc: cint, argv: ErlNifArgs): ErlNifTerm =
  let priv = cast[ptr MyResourcePriv](enif_priv_data(env))
  var resource_ptr: ptr MyResource
  if not enif_get_resource(env, argv[0], priv[].resource_type, addr(resource_ptr)):
    return enif_make_badarg(env)
  doAssert(resource_ptr.thing == 1234)
  return argv[0]


export_nifs(NifOptions(
  name: "Elixir.NimlerWrapper",
  funcs: @[
    toNif(create_resource, "create_resource", 0),
    toNif(update_resource, "update_resource", 1),
    toNif(check_resource, "check_resource", 1)
  ],
  load: on_load,
  unload: on_unload
))

