import nimler/erl_sys_info
import nimler/bindings/erl_nif
export erl_nif
import nimler/codec
export codec

{.passC: "-I" & ertsPath.}

type
  NifSpec* = tuple[name: string, arity: int, fptr: ErlNifFptr]
  NifSpecDirty* = tuple[name: string, arity: int, fptr: ErlNifFptr, flags: ErlNifFlags]
  NifOptions* = object
    name*: string
    funcs*: seq[ErlNifFunc]
    load*: ErlNifEntryLoad
    reload*: ErlNifEntryReload
    upgrade*: ErlNifEntryUpgrade
    unload*: ErlNifEntryUnload

proc tonif*(fptr: ErlNifFptr, name: string, arity: int, flags: ErlNifFlags = ERL_NIF_REGULAR): ErlNifFunc =
  ErlNifFunc(name: cstring(name), arity: cuint(arity), fptr: fptr, flags: flags)

template export_nifs*(module_name: string, funcs_seq: openArray[ErlNifFunc]) =
  export_nifs(NifOptions(name: module_name, funcs: funcs_seq))

template export_nifs*(module_name: string, funcs_seq: openArray[NifSpec|NifSpecDirty]) =
  var funcs: seq[ErlNifFunc]

  for spec in funcs_seq:
    funcs.add(
      when spec is NifSpec:
        toNif(fptr=spec[2], name=spec[0], arity=spec[1])
      elif spec is NifSpecDirty:
        toNif(fptr=spec[2], name=spec[0], arity=spec[1], flags=spec[3])
    )

  export_nifs(module_name, funcs)

template export_nifs*(options: NifOptions) =
  var funcs = options.funcs
  var entry: ErlNifEntry
  entry.major = cint(nifMajor)
  entry.minor = cint(nifMinor)
  entry.name = cstring(options.name)
  entry.num_of_funcs = cint(len(funcs))
  entry.funcs = addr(funcs[0])
  entry.load = options.load
  entry.reload = options.reload
  entry.upgrade = options.upgrade
  entry.unload = options.unload
  entry.vm_variant = cstring("beam.vanilla")

  proc NimMain() {.gensym, importc: "NimMain".}

  proc nif_init(): ptr ErlNifEntry {.dynlib, exportc.} =
    NimMain()
    result = addr(entry)

