import ../../nimler
import ../../nimler/codec
import ../../nimler/resources

using
  env: ptr ErlNifEnv
  argc: cint
  argv: ErlNifArgs

type MyResource {.packed.} = object
  thing: int32

func new_res(env, argc, argv): ErlNifTerm {.nif(arity=0, name="new").} =
  let res = env.new(MyResource)
  if res.isNone():
    return env.error(env.encode("fail to allocate new resource"))
  res.get().thing = 0
  return env.ok(env.release(res.get()))

func set_res(env, argc, argv): ErlNifTerm {.nif(arity=2, name="set").} =
  let resource = env.get(argv[0], MyResource)
  let newval = env.decode(argv[1], int32).get(-1)
  
  if resource.isNone():
    return AtomErr.encode(env)

  resource.get().thing = newval

  return AtomOk.encode(env)
    
func check_res(env, argc, argv): ErlNifTerm {.nif(arity=2, name="check").} =
  let resource = env.get(argv[0], MyResource)
  let comp = env.decode(argv[1], int32)

  if resource.isNone() and comp.isNone():
    return AtomErr.encode(env)

  if resource.get().thing == comp.get():
    return AtomOk.encode(env)

  return AtomErr.encode(env)

resources.export_nifs("Elixir.NimlerWrapper", [
  new_res,
  set_res,
  check_res
])

