import macros

import nimler/erl_sys_info
export erl_sys_info

import nimler/bindings/erl_nif
export erl_nif

{.passC: "-I" & ertsPath.}

type NifSpec* = tuple[name: string, arity: int, fptr: ErlNifFptr]

macro tonif*(fptr: ErlNifFptr, name: string, arity: int, flags: ErlNifFlags = ERL_NIF_REGULAR): untyped =
  result = quote do:
    ErlNifFunc(name: `name`, arity: cuint(`arity`), fptr: `fptr`, flags: `flags`)

proc NimMain() {.gensym, importc: "NimMain".}

template export_nifs*(
    module_name: string,
    nifs: openArray[ErlNifFunc],
    on_load: ErlNifEntryLoad = nil,
    on_reload: ErlNifEntryReload = nil,
    on_upgrade: ErlNifEntryUpgrade = nil,
    on_unload: ErlNifEntryUnload = nil
) =
  var funcs = nifs
  var entry: ErlNifEntry
  entry.name = cstring(module_name)
  entry.num_of_funcs = cint(len(funcs))
  if funcs.len > 0:
    entry.funcs = addr(funcs[0])
  entry.major = cint(nifMajor)
  entry.minor = cint(nifMinor)
  entry.vm_variant = cstring("beam.vanilla")
  entry.load = on_load
  entry.reload = on_reload
  entry.upgrade = on_upgrade
  entry.unload = on_unload

  proc nif_init(): ptr ErlNifEntry {.dynlib, exportc.} =
    NimMain()
    result = addr(entry)

template export_nifs*(module_name: string, specs_seq: openArray[NifSpec]) =
  var funcs: array[len(specs_seq), ErlNifFunc]
  for i, (name, arity, fptr) in pairs(specs_seq):
    funcs[i] = fptr.to_nif(name, arity)
  export_nifs(module_name, move(funcs))

