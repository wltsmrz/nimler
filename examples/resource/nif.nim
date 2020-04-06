import ../../nimler
import ../../nimler/codec
import ./controller

const rate = 100.0
const min = -10.0
const max = 10.0
const kp = 0.5
const ki = 0.25
const kf = 1.0

type ResourcePriv = object
  resource_type: ptr ErlNifResourceType

proc on_unload(env: ptr ErlNifEnv, priv_data: pointer): void =
  enif_free(priv_data)

proc on_load(env: ptr ErlNifEnv, priv_data: ptr pointer, load_info: ErlNifTerm): cint =
  let priv = cast[ptr ResourcePriv](enif_alloc(cast[csize_t](sizeof(ResourcePriv))))
  priv.resource_type = enif_open_resource_type(env, "PIController", ERL_NIF_RT_CREATE)
  priv_data[] = priv
  return 0

proc create_resource(env: ptr ErlNifEnv, argc: cint, argv: ErlNifArgs): ErlNifTerm {.raises: [].}  =
  let priv = cast[ptr ResourcePriv](enif_priv_data(env))
  var controller = cast[ptr PIControl](enif_alloc_resource(priv.resource_type, cast[csize_t](sizeof(PIControl))))

  init_controller(controller, rate, min, max, kp, ki, kf)
  
  var resource_term = enif_make_resource(env, controller)
  enif_release_resource(controller)

  return resource_term


proc update_resource(env: ptr ErlNifEnv, argc: cint, argv: ErlNifArgs): ErlNifTerm {.raises: [].}  =
  let priv = cast[ptr ResourcePriv](enif_priv_data(env))
  var controller: ptr PIControl

  if not enif_get_resource(env, argv[0], priv.resource_type, addr(controller)):
    return enif_make_badarg(env)

  let sp = argv[1].decode(env, float)
  let pv = argv[2].decode(env, float)
  
  if sp.isNone() or pv.isNone():
    return enif_make_badarg(env)

  let res = controller.update(sp.get(1.0), pv.get(1.0))
  return ok(env, res.encode(env))

export_nifs(
  "Elixir.PIController",
  [
    create_resource.to_nif(name="create_resource", arity=0),
    update_resource.to_nif(name="update_resource", arity=3)
  ],
  on_load=on_load,
  on_unload=on_unload
)

