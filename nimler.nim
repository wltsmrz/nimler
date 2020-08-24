import std/macros
import std/tables

import nimler/erl_sys_info
import nimler/bindings/erl_nif
import nimler/gen_module

export erl_sys_info
export erl_nif

{.passc: "-I" & erts_path.}

template arity*(x: int) {.pragma.}
template name*(x: string) {.pragma.}
template nif_name*(x: string) {.pragma.}
template dirty_io*() {.pragma.}
template dirty_cpu*() {.pragma.}

func pragma_table*(fn: NimNode): Table[string, NimNode] =
  result = initTable[string, NimNode]()
  for p in fn.pragma:
    case p.kind:
      of nnkIdent, nnkSym:
        result[repr p] = newEmptyNode()
      of nnkExprColonExpr:
        result[repr p[0]] = p[1]
      else:
        error: "wrong kind: " & $p.kind

macro nif*(fn: untyped): untyped =
  expectKind(fn, {nnkProcDef, nnkFuncDef})

  let fn_pragmas = pragma_table(fn)
  if not fn_pragmas.hasKey("arity"):
    error:
      "nif must have specified arity"

  let fn_name = ident($fn.name)
  let nif_name = getOrDefault(fn_pragmas, "nif_name",
    getOrDefault(fn_pragmas, "name", newLit($fn.name)))
  let nif_arity = getOrDefault(fn_pragmas, "arity", newLit(0))
  let nif_flags = ident(
    if fn_pragmas.hasKey("dirty_cpu"):
      $ERL_NIF_DIRTY_CPU
    elif fn_pragmas.hasKey("dirty_io"):
      $ERL_NIF_DIRTY_IO
    else:
      $ERL_NIF_REGULAR
  )
  let internal_name = ident("Z" & $fn.name)
  fn.name = internal_name
  fn.addPragma(ident("cdecl"))

  result = quote do:
    `fn`
    const `fn_name` = ErlNifFunc(
      name: `nif_name`,
      arity: `nif_arity`,
      fptr: `internal_name`,
      flags: `nif_flags`
    )

template export_nifs*(
    module_name: string,
    nifs: static openArray[ErlNifFunc],
    on_load: ErlNifEntryLoad = nil,
    on_reload: ErlNifEntryReload = nil,
    on_upgrade: ErlNifEntryUpgrade = nil,
    on_unload: ErlNifEntryUnload = nil) =

  let funcs = nifs

  let entry = ErlNifEntry(
    name: module_name,
    num_of_funcs: len(funcs).cint,
    funcs: funcs[0].unsafeAddr,
    major: nifMajor.cint,
    minor: nifMinor.cint,
    vm_variant: "beam.vanilla",
    load: on_load,
    reload: on_reload,
    upgrade: on_upgrade,
    unload: on_unload,
  )

  proc nif_init(): ptr ErlNifEntry {.dynlib, exportc.} =
    entry.unsafeAddr

  static: gen_wrapper(module_name, nifs)

