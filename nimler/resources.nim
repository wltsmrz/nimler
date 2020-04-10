import options
import ../nimler

type ErlNifResource* = object
  resource_type: ptr ErlNifResourceType

proc priv_data*(env: ptr ErlNifEnv): Option[ptr ErlNifResource] =
  let priv = cast[ptr ErlNifResource](enif_priv_data(env))
  if priv != nil:
    return some(priv)

proc get_resource*(env: ptr ErlNifEnv, term: ErlNifTerm, T: typedesc): Option[ptr T] =
  let privdata = priv_data(env)
  var res: ptr T
  if privdata.isSome() and enif_get_resource(env, term, privdata.get().resource_type, addr(res)):
    return some(res)

proc release_resource*(env: ptr ErlNifEnv, V: ptr): ErlNifTerm =
  let term = enif_make_resource(env, V)
  enif_release_resource(V)
  return term

proc new_resource*(env: ptr ErlNifEnv, T: typedesc): Option[ptr T] =
  let privdata = priv_data(env)
  if privdata.isSome():
    var res = cast[ptr T](enif_alloc_resource(privdata.get().resource_type, cast[csize_t](sizeof(T))))
    zeroMem(res, sizeof(T))
    return some(res)

proc new_resource*(env: ptr ErlNifEnv, V: object): Option[ptr type(V)] =
  let res = new_resource(env, type(V))
  if res.isSome():
    var resv = res.get()
    copyMem(resv, unsafeAddr(V), sizeof(resv[]))
    return some(resv)

proc new_default_resource*(env: ptr ErlNifEnv, T: typedesc): Option[ptr T] =
  let res = new_resource(env, T)
  if res.isSome():
    var V = default(T)
    let res = cast[ptr T](enif_alloc_resource(privdata.get().resource_type, cast[csize_t](sizeof(V))))
    copyMem(res, addr(V), sizeof(res))
    return some(res)

template export_nifs*(module_name: string, nifs: static openArray[ErlNifFunc]) =
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

  export_nifs(module_name, nifs, on_load=on_load, on_unload=on_unload)

