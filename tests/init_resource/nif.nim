import ../../nimler
import ../../nimler/codec
import ../../nimler/resources

using
  env: ptr ErlNifEnv
  argc: cint
  argv: ErlNifArgs

type MyResource = object
  thing: int32

func new_res(env, argc, argv): ErlNifTerm {.nif(arity=0, name="new").} =
  let res = env.new_resource(MyResource)
  if res.isNone():
    return env.error(env.to_term("fail to allocate new resource"))
  res.get().thing = 0
  return env.ok(env.release_resource(res.get()))

func set_res(env, argc, argv): ErlNifTerm {.nif(arity=2, name="set").} =
  let resource = env.get_resource(argv[0], MyResource)
  let newval = env.from_term(argv[1], int32).get(-1)
  if resource.isNone():
    return env.error()
  let pval = resource.get().thing
  resource.get().thing = newval
  return env.ok(env.to_term(pval), argv[1])
    
func check_res(env, argc, argv): ErlNifTerm {.nif(arity=2, name="check").} =
  let resource = env.get_resource(argv[0], MyResource)
  let comp = env.from_term(argv[1], int32)
  let checked = resource.isSome() and comp.isSome() and resource.get().thing == comp.get()
  return if checked: env.ok() else: env.error()

resources.export_nifs("Elixir.NimlerInitResource", [
  new_res,
  set_res,
  check_res
])

