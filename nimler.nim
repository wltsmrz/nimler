import std/macros
import std/tables

import nimler/erl_sys_info
import nimler/bindings/erl_nif
import nimler/gen_module

export erl_sys_info
export erl_nif

{.passc: "-I" & ertsPath.}

template arity*(x: int) {.pragma.}
template nif_name*(x: string) {.pragma.}
template dirty_io*() {.pragma.}
template dirty_cpu*() {.pragma.}

func pragma_table(fn: NimNode): Table[string, NimNode] =
  result = initTable[string, NimNode]()
  for p in fn.pragma:
    case p.kind:
      of nnkIdent, nnkSym:
        result[repr p] = newEmptyNode()
      of nnkExprColonExpr:
        result[repr p[0]] = p[1]
      else:
        error: "wrong kind: " & $p.kind

func clone_proc(fn: NimNode): NimNode =
  result = nnkProcDef.newTree(nnkEmpty.newNimNode)
  for i, child in fn:
    if i != 0:
      result.add(child)

macro nif*(fn: untyped): untyped =
  if not (fn.kind == nnkProcDef or fn.kind == nnkFuncDef):
    error:
      "nif macro must be applied to proc or func"

  let fn_pragmas = pragma_table(fn)
  if not fn_pragmas.hasKey("arity"):
    error:
      "nif must have specified arity"

  let fn_name = fn.name
  let nif_fn = clone_proc(fn)
  let nif_name = getOrDefault(fn_pragmas, "nif_name", newLit(repr fn_name))
  let nif_arity = getOrDefault(fn_pragmas, "arity", newLit(0))
  let nif_flags = ident(
    if fn_pragmas.hasKey("dirty_io"):
      $ERL_NIF_DIRTY_IO
    elif fn_pragmas.hasKey("dirty_cpu"):
      $ERL_NIF_DIRTY_CPU
    else:
      $ERL_NIF_REGULAR
  )

  result = quote do:
    const `fn_name` = ErlNifFunc(name: `nif_name`, arity: `nif_arity`,
        fptr: `nif_fn`, flags: `nif_flags`)

template export_nifs*(
    module_name: string,
    nifs: static openArray[ErlNifFunc],
    on_load: ErlNifEntryLoad = nil,
    on_reload: ErlNifEntryReload = nil,
    on_upgrade: ErlNifEntryUpgrade = nil,
    on_unload: ErlNifEntryUnload = nil) =

  var funcs {.gensym.} = nifs
  var entry: ErlNifEntry
  entry.name = module_name
  entry.num_of_funcs = len(funcs).cint
  if funcs.len > 0:
    entry.funcs = funcs[0].addr
  entry.major = nifMajor.cint
  entry.minor = nifMinor.cint
  entry.vm_variant = "beam.vanilla"
  entry.load = on_load
  entry.reload = on_reload
  entry.upgrade = on_upgrade
  entry.unload = on_unload

  proc nif_init(): ptr ErlNifEntry {.dynlib, exportc.} =
    addr(entry)

  static:
    gen_wrapper(module_name, nifs)

