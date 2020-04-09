import ../../nimler
import ../../nimler/codec
import ../../nimler/resources

type MyResource {.packed.} = object
  thing: int32

proc new_res(env: ptr ErlNifEnv, argc: cint, argv: ErlNifArgs): ErlNifTerm =
  let res = env.new(MyResource)
  if res.isNone():
    return env.error(env.encode("fail to allocate new resource"))
  res.get().thing = 0
  return env.ok(env.release(res.get()))

proc set_res(env: ptr ErlNifEnv, argc: cint, argv: ErlNifArgs): ErlNifTerm =
  let resource = env.get(argv[0], MyResource)
  let newval = env.decode(argv[1], int32).get(-1)
  
  if resource.isNone():
    return AtomErr.encode(env)

  resource.get().thing = newval

  return AtomOk.encode(env)
    
proc check_res(env: ptr ErlNifEnv, argc: cint, argv: ErlNifArgs): ErlNifTerm =
  let resource = env.get(argv[0], MyResource)
  let comp = env.decode(argv[1], int32)

  if resource.isNone() and comp.isNone():
    return AtomErr.encode(env)

  if resource.get().thing == comp.get():
    return AtomOk.encode(env)

  return AtomErr.encode(env)

resources.export_nifs("Elixir.NimlerWrapper", [
  to_nif(new_res, "new", 0),
  to_nif(set_res, "set", 2),
  to_nif(check_res, "check", 2)
])

