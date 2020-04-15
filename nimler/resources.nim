import options
import ../nimler

proc priv_data*(env: ptr ErlNifEnv): Option[ptr ErlNifResourceType] =
  let priv = cast[ptr ErlNifResourceType](enif_priv_data(env))
  if not isNil(priv):
    return some(priv)

proc get_resource*(env: ptr ErlNifEnv, term: ErlNifTerm, T: typedesc): Option[ptr T] =
  let privdata = priv_data(env)
  var res: ptr T
  if privdata.isSome() and enif_get_resource(env, term, privdata.unsafeGet(), addr(res)):
    return some(res)

proc release_resource*(env: ptr ErlNifEnv, V: ptr): ErlNifTerm =
  let term = enif_make_resource(env, V)
  enif_release_resource(V)
  return term

proc new_resource*(env: ptr ErlNifEnv, T: typedesc): Option[ptr T] =
  let privdata = priv_data(env)
  if privdata.isSome():
    let res = cast[ptr T](enif_alloc_resource(privdata.unsafeGet(), cast[csize_t](sizeof(T))))
    return some(res)

template export_nifs*(module_name: string, nifs: static openArray[ErlNifFunc]) =
  proc on_load(env: ptr ErlNifEnv, priv_data: ptr pointer, load_info: ErlNifTerm): cint =
    let flags = cast[cint]({ERL_NIF_RT_CREATE, ERL_NIF_RT_TAKEOVER})
    var flags_tried: cint
    let open_res = enif_open_resource_type(env, module_name, flags, addr(flags_tried))
    if isNil(open_res): return -1
    priv_data[] = open_res
    return 0

  proc on_unload(env: ptr ErlNifEnv, priv_data: pointer): void =
    enif_free(priv_data)

  nimler.export_nifs(module_name, nifs, on_load=on_load, on_unload=on_unload)

