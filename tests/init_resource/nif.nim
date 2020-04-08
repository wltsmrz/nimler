import ../../nimler
import ../../nimler/codec
import ../../nimler/resources

type MyResource = object
  thing: int32

proc new_res(env: ptr ErlNifEnv, argc: cint, argv: ErlNifArgs): ErlNifTerm =
  env.new_default(MyResource)

proc set_res(env: ptr ErlNifEnv, argc: cint, argv: ErlNifArgs): ErlNifTerm =
  let resource = env.get(argv[0], MyResource)
  let newval = env.decode(argv[1], int32).get(-1)
  
  if resource.isNone():
    return AtomErr.encode(env)

  resource.get().thing = newval

  return AtomOk.encode(env)
    
proc check_res(env: ptr ErlNifEnv, argc: cint, argv: ErlNifArgs): ErlNifTerm =
  let resource = env.get(argv[0], MyResource).get()
  let comp = env.decode(argv[1], int32).get()

  if resource.thing == comp:
    return AtomOk.encode(env)

  return AtomErr.encode(env)

resources.export_nifs("Elixir.NimlerWrapper", [
  to_nif(new_res, "new", 0),
  to_nif(set_res, "set", 2),
  to_nif(check_res, "check", 2)
])

