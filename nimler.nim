import ./erl_sys_info

{.passC: "-I" & ertsPath.}

import nimler/bindings/erl_nif
export erl_nif

import nimler/codec
export codec

type
  NifSpec* = tuple[name: string, arity: int, fptr: ErlNifFptr]
  NifSpecDirty* = tuple[name: string, arity: int, fptr: ErlNifFptr, flags: ErlNifFlags]
  NifOptions* = object
    name*: string
    funcs*: seq[NifSpec]
    dirty_funcs*: seq[NifSpecDirty]
    load*: ErlNifEntryLoad
    reload*: ErlNifEntryReload
    upgrade*: ErlNifEntryUpgrade
    unload*: ErlNifEntryUnload

template export_nifs*(module_name: string, funcs_seq: openArray[NifSpec|NifSpecDirty]) =
  var funcs {.gensym.}: seq[ErlNifFunc]

  for spec in funcs_seq:
    var nifFunc = ErlNifFunc(name: cstring(spec[0]), arity: cuint(spec[1]), fptr: spec[2])
    when spec is NifSpecDirty:
      nifFunc.flags = spec[3]
    funcs.add(nifFunc)

  var entry {.gensym.}: ErlNifEntry
  entry.major = cint(nifMajor)
  entry.minor = cint(nifMinor)
  entry.name = cstring(module_name)
  entry.num_of_funcs = cint(len(funcs))
  entry.funcs = cast [ptr UncheckedArray[ErlNifFunc]](addr(funcs[0]))
  entry.vm_variant = cstring("beam.vanilla")

  proc NimMain() {.gensym, importc: "NimMain".}

  proc nif_init(): ptr ErlNifEntry {.dynlib, exportc.} =
    NimMain()
    result = addr(entry)

template export_nifs*(module_name: string, options: NifOptions) =
  var funcs {.gensym.}: seq[ErlnifFunc]

  for (name, arity, fptr) in options.funcs:
    funcs.add(ErlNifFunc(name: cstring(name), arity: cuint(arity), fptr: fptr))
  for (name, arity, fptr, flags) in options.dirty_funcs:
    funcs.add(ErlNifFunc(name: cstring(name), arity: cuint(arity), fptr: fptr, flags: flags))

  var entry {.gensym.}: ErlNifEntry
  entry.major = cint(nifMajor)
  entry.minor = cint(nifMinor)
  entry.name = cstring(module_name)
  entry.num_of_funcs = cint(len(funcs))
  entry.funcs = cast [ptr UncheckedArray[ErlNifFunc]](addr(funcs[0]))
  entry.load = options.load
  entry.reload = options.reload
  entry.upgrade = options.upgrade
  entry.unload = options.unload
  entry.vm_variant = cstring("beam.vanilla")

  proc NimMain() {.gensym, importc: "NimMain".}

  proc nif_init(): ptr ErlNifEntry {.dynlib, exportc.} =
    NimMain()
    result = addr(entry)

