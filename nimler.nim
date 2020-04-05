import macros

import nimler/erl_sys_info
export erl_sys_info

import nimler/bindings/erl_nif
export erl_nif

{.passC: "-I" & ertsPath.}

type
  NifSpec* = tuple[name: string, arity: int, fptr: ErlNifFptr]
  NifOptions* = object
    name*: string
    funcs*: seq[ErlNifFunc]
    load*: ErlNifEntryLoad
    reload*: ErlNifEntryReload
    upgrade*: ErlNifEntryUpgrade
    unload*: ErlNifEntryUnload

macro tonif*(fptr: ErlNifFptr, name: string, arity: int, flags: ErlNifFlags = ERL_NIF_REGULAR): untyped =
  result = quote do:
    ErlNifFunc(name: `name`, arity: cuint(`arity`), fptr: `fptr`, flags: `flags`)

macro tonif*(spec: NifSpec, flags: ErlNifFlags = ERL_NIF_REGULAR): untyped =
  result = quote do:
    ErlNifFunc(name: `spec`[0], arity: cuint(`spec`[1]), fptr: `spec`[2], flags: `flags`)

proc NimMain() {.gensym, importc: "NimMain".}

template export_nifs*(options: NifOptions) =
  var funcs = options.funcs
  var entry: ErlNifEntry
  entry.name = cstring(options.name)
  entry.num_of_funcs = cint(len(funcs))
  if funcs.len > 0:
    entry.funcs = addr(funcs[0])
  entry.major = cint(nifMajor)
  entry.minor = cint(nifMinor)
  entry.load = options.load
  entry.reload = options.reload
  entry.upgrade = options.upgrade
  entry.unload = options.unload
  entry.vm_variant = cstring("beam.vanilla")

  proc nif_init(): ptr ErlNifEntry {.dynlib, exportc.} =
    NimMain()
    result = addr(entry)

template export_nifs*(module_name: string, funcs_seq: openArray[ErlNifFunc]) =
  var funcs = funcs_seq
  var entry: ErlNifEntry
  entry.name = cstring(module_name)
  entry.num_of_funcs = cint(len(funcs))
  if funcs.len > 0:
    entry.funcs = addr(funcs[0])
  entry.major = cint(nifMajor)
  entry.minor = cint(nifMinor)
  entry.vm_variant = cstring("beam.vanilla")

  proc nif_init(): ptr ErlNifEntry {.dynlib, exportc.} =
    NimMain()
    result = addr(entry)

template export_nifs*(module_name: string, specs_seq: openArray[NifSpec]) =
  var funcs: array[len(specs_seq), ErlNifFunc]
  for i, spec in pairs(specs_seq):
    funcs[i] = spec.toNif()
  export_nifs(module_name, move(funcs))

