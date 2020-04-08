import options
import ../nimler

type ErlNifResource* = object
  resource_type: ptr ErlNifResourceType

proc priv_data*(env: ptr ErlNifEnv): ptr ErlNifResource  =
  return cast[ptr ErlNifResource](enif_priv_data(env))

proc get*(env: ptr ErlNifEnv, term: ErlNifTerm, T: typedesc[object]): Option[ptr T] =
  let priv = cast[ptr ErlNifResource](enif_priv_data(env))
  var res: ptr T
  if enif_get_resource(env, term, priv.resource_type, addr(res)):
    return some(res)

proc release*(env: ptr ErlNifEnv, V: ptr): ErlNifTerm =
  var term = enif_make_resource(env, V)
  enif_release_resource(V)
  return term

proc new*(env: ptr ErlNifEnv, T: typedesc[object]): ptr T =
  let priv = cast[ptr ErlNifResource](enif_priv_data(env))
  let res = cast[ptr T](enif_alloc_resource(priv.resource_type, cast[csize_t](sizeof(T))))
  return res

proc new*(env: ptr ErlNifEnv, V: object): ptr type(V) =
  let res = new(env, type(V))
  copy_mem(res, unsafe_addr(V), sizeof(res))
  return res

proc new_default*(env: ptr ErlNifEnv, T: typedesc): ErlNifTerm =
  return release(env, new(env, default(T)))

template export_nifs*(module_name: string, funcs: openArray[ErlNifFunc]) =
  proc on_load(env: ptr ErlNifEnv, priv_data: ptr pointer, load_info: ErlNifTerm): cint =
    var priv = cast[ptr ErlNifResource](enif_alloc(cast[csize_t](sizeof(ErlNifResource))))
    var flags = cast[cint]({ERL_NIF_RT_CREATE, ERL_NIF_RT_TAKEOVER})
    var flags_tried: cint
    var open_res = enif_open_resource_type(env, module_name, flags, addr(flags_tried))
    if open_res == nil: return -1
    priv.resource_type = open_res
    priv_data[] = priv
    return 0

  proc on_unload(env: ptr ErlNifEnv, priv_data: pointer): void =
    enif_free(priv_data)

  export_nifs(module_name, funcs, on_load=on_load, on_unload=on_unload)
                  
