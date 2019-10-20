import sharedtables
import ../../nimler

type MyResource = object
  thing: int32

var resource_types {.global.}: seq[pointer] = @[]

proc create_resource(env: ptr ErlNifEnv, argc: cint, argv: ErlNifArgs): ErlNifTerm =
  let my_resource = MyResource(thing: 123)
  var flags_created: ErlNifResourceFlags
  let resource_type_ptr = enif_open_resource_type(
    env,
    nil,
    cstring("MyResource"),
    nil,
    ERL_NIF_RT_CREATE,
    addr(flags_created)
  )
  if flags_created != ERL_NIF_RT_CREATE:
    return enif_make_badarg(env)
  resource_types.add(resource_type_ptr)
  var resource_ptr = enif_alloc_resource(resource_type_ptr, sizeof(MyResource))
  var resource_term = enif_make_resource(env, resource_ptr)
  return resource_term

proc update_resource(env: ptr ErlNifEnv, argc: cint, argv: ErlNifArgs): ErlNifTerm =
  var resource_ptr: ptr MyResource
  if not enif_get_resource(env, argv[0], resource_types[0], addr(resource_ptr)):
    return enif_make_badarg(env)
  resource_ptr[].thing = 1234
  return argv[0]

proc check_resource(env: ptr ErlNifEnv, argc: cint, argv: ErlNifArgs): ErlNifTerm =
  var resource_ptr: ptr MyResource
  if not enif_get_resource(env, argv[0], resource_types[0], addr(resource_ptr)):
    return enif_make_badarg(env)
  if resource_ptr[].thing != 1234:
    return enif_make_badarg(env)
  return argv[0]

proc release_resource(env: ptr ErlNifEnv, argc: cint, argv: ErlNifArgs): ErlNifTerm =
  var resource_ptr: ptr MyResource
  if not enif_get_resource(env, argv[0], resource_types[0], addr(resource_ptr)):
    return enif_make_badarg(env)
  enif_release_resource(resource_ptr)
  return encode(1'i32, env)

export_nifs("Elixir.NimlerWrapper", @[
  ("create_resource", 0, create_resource),
  ("update_resource", 1, update_resource),
  ("check_resource", 1, check_resource),
  ("release_resource", 1, release_resource)
])

