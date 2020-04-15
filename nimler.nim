import std/macros

import nimler/erl_sys_info
import nimler/bindings/erl_nif
import nimler/gen_module

export erl_sys_info
export erl_nif

{.passc: "-I" & ertsPath.}

macro tonif*(fptr: ErlNifFptr, name: string, arity: int, flags: ErlNifFlags = ERL_NIF_REGULAR): untyped =
  result = quote do:
    ErlNifFunc(name: `name`, arity: cuint(`arity`), fptr: `fptr`, flags: `flags`)

macro tonif*(name: string, arity: int, fptr: ErlNifFptr, flags: ErlNifFlags = ERL_NIF_REGULAR): untyped =
  result = quote do:
    ErlNifFunc(name: `name`, arity: cuint(`arity`), fptr: `fptr`, flags: `flags`)

proc toproc(fn: NimNode): NimNode {.compileTime.} =
  result = nnkProcDef.newTree(nnkEmpty.newNimNode)
  for i, child in fn:
    if i != 0:
      result.add(child)

macro nif* (name: string, arity: int, fn: untyped): untyped =
  case fn.kind:
    of nnkProcDef, nnkFuncDef:
      let fn_name = fn[0]
      let fn_node = toproc(fn)
      result = quote do:
        const `fn_name` = ErlNifFunc(name: `name`, arity: cuint(`arity`), fptr: `fn_node`)
    of nnkIdent:
      result = quote do:
        ErlNifFunc(name: `name`, arity: `arity`, fn: `fn`)
    else:
      error "wrong kind: " & $fn.kind

macro nif*(arity: int, fn: untyped): untyped =
  case fn.kind:
    of nnkProcDef, nnkFuncDef:
      let fn_name = fn[0]
      let fn_name_lit = fn_name.toStrLit()
      let fn_node = toproc(fn)
      result = quote do:
        const `fn_name` = ErlNifFunc(name: `fn_name_lit`, arity: cuint(`arity`), fptr: `fn_node`)
    of nnkIdent:
      let fn_name_lit = newLit(repr(fn))
      result = quote do:
        ErlNifFunc(name: `fn_name_lit`, arity: `arity`, fptr: `fn`)
    else:
      error "wrong kind: " & $fn.kind

proc NimMain() {.gensym, importc: "NimMain".}

template export_nifs*(
    module_name: string,
    nifs: static openArray[ErlNifFunc],
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

  static:
    when defined(nimlerGenModule) or defined(nimlerGenModuleForce):
      gen_elixir_module(module_name, nifs)

