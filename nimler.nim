import ./bindings/erl_nif
import ./codec

export erl_nif
export codec

type
  NifSpec* = tuple[name: string, arity: int, fptr: NifFunc]
  NifSpecDirty* = tuple[name: string, arity: int, fptr: NifFunc, flags: ErlNifFlags]
  NifOptions* = object
    name*: string
    funcs*: seq[NifSpec]
    dirty_funcs*: seq[NifSpecDirty]
    load*: ErlNifEntryLoad
    reload*: ErlNifEntryReload
    upgrade*: ErlNifEntryUpgrade
    unload*: ErlNifEntryUnload

template export_nifs*(module_name: string, funcs_seq: openArray[NifSpec]) =
  proc NimMain() {.gensym, importc: "NimMain".}

  var entry {.gensym.}: ErlNifEntry
  var funcs {.gensym.}: seq[ErlNifFunc] = @[]

  for (name, arity, fptr) in funcs_seq:
    funcs.add(ErlNifFunc(name: cstring(name), arity: cuint(arity), fptr: fptr))

  proc nif_init(): ptr ErlNifEntry {.dynlib, exportc.} =
    NimMain()
    entry.major = cint(2)
    entry.minor = cint(15)
    entry.name = cstring(module_name)
    entry.num_of_funcs = len(funcs).cint
    entry.funcs = cast[NifFuncArr](unsafeAddr(funcs[0]))
    entry.load = nil
    entry.reload = nil
    entry.upgrade = nil
    entry.unload = nil
    entry.vm_variant = cstring("beam.vanilla")
    result = addr(entry)

template export_nifs*(module_name: string, options: NifOptions) =
  proc NimMain() {.gensym, importc: "NimMain".}

  var entry {.gensym.}: ErlNifEntry
  var funcs {.gensym.}: seq[ErlNifFunc] = @[]

  for (name, arity, fptr) in options.funcs:
    funcs.add(ErlNifFunc(name: cstring(name), arity: cuint(arity), fptr: fptr))
  for (name, arity, fptr, flags) in options.dirty_funcs:
    funcs.add(ErlNifFunc(name: cstring(name), arity: cuint(arity), fptr: fptr, flags: cuint(flags)))

  proc nif_init(): ptr ErlNifEntry {.dynlib, exportc.} =
    NimMain()
    entry.major = cint(2)
    entry.minor = cint(15)
    entry.name = cstring(module_name)
    entry.num_of_funcs = len(funcs).cint
    entry.funcs = cast[NifFuncArr](unsafeAddr(funcs[0]))
    entry.load = options.load
    entry.reload = options.reload
    entry.upgrade = options.upgrade
    entry.unload = options.unload
    entry.vm_variant = cstring("beam.vanilla")
    result = addr(entry)

