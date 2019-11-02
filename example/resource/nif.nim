import nimler
import ./controller

type ResourcePriv = object
  resource_type: ptr ErlNifResourceType

proc on_unload(env: ptr ErlNifEnv, priv_data: pointer): void =
  enif_free(priv_data)

proc on_load(env: ptr ErlNifEnv, priv_data: ptr pointer, load_info: ErlNifTerm): cint =
  let priv = cast[ptr ResourcePriv](enif_alloc(sizeof(ResourcePriv)))
  var flags_created: ErlNifResourceFlags
  priv.resource_type = enif_open_resource_type(env, "PIController", ERL_NIF_RT_CREATE, addr(flags_created))
  priv_data[] = priv
  return 0

proc create_resource(env: ptr ErlNifEnv, argc: cint, argv: ErlNifArgs): ErlNifTerm =
  let priv = cast[ptr ResourcePriv](enif_priv_data(env))
  let controller = cast[ptr PIControl](enif_alloc_resource(priv.resource_type, sizeof(PIControl)))

  let rate = argv[0].decode(env, float).get()
  let min = argv[1].decode(env, float).get()
  let max = argv[2].decode(env, float).get()

  let kp = argv[3].decode(env, float).get()
  let ki = argv[4].decode(env, float).get()
  let kf = argv[5].decode(env, float).get()

  init_controller(controller, rate, min, max)
  set_gain(controller, kp, ki, kf)
  
  var resource_term = enif_make_resource(env, controller)
  enif_release_resource(controller)

  return resource_term


proc update_resource(env: ptr ErlNifEnv, argc: cint, argv: ErlNifArgs): ErlNifTerm =
  let priv = cast[ptr ResourcePriv](enif_priv_data(env))
  var resource_ptr: ptr PIControl

  if not enif_get_resource(env, argv[0], priv.resource_type, addr(resource_ptr)):
    return enif_make_badarg(env)

  let sp = argv[1].decode(env, float).get()
  let pv = argv[2].decode(env, float).get()
  let res = resource_ptr.update(sp, pv)

  # echo repr(resource_ptr)

  return [ AtomOk.encode(env), res.encode(env) ].encode(env)


export_nifs("Elixir.PIController", NifOptions(
  funcs: @[
    ("create_resource", 6, create_resource),
    ("update_resource", 3, update_resource)
  ],
  load: on_load,
  unload: on_unload
))


