import std/macros
import std/tables

import nimler/erl_sys_info
import nimler/bindings/erl_nif
import nimler/gen_module

export erl_sys_info
export erl_nif

{.passc: "-I" & ertsPath.}

template arity*(x: int) {.pragma.}
template nifName*(x: string) {.pragma.}
template dirtyIo*() {.pragma.}
template dirtyCpu*() {.pragma.}

type PragmaSpec = tuple[k: NimNode, v: NimNode]

func pragmaTable(fn: NimNode): seq[PragmaSpec] =
  expectKind(fn, {nnkProcDef, nnkFuncDef})
  for p in fn.pragma:
    case p.kind:
      of nnkIdent, nnkSym:
        let pp: PragmaSpec = (p, newEmptyNode())
        result.add(pp)
      of nnkExprColonExpr:
        result.add((p[0], p[1]))
      else:
        error "wrong kind: " & $p.kind

func getPragmaValue(p: seq[PragmaSpec], t: string, d: NimNode = newEmptyNode()): NimNode =
  for (k, v) in p:
    if eqIdent(k, t):
      return v
  return d

func hasPragma(p: seq[PragmaSpec], t: string): bool =
  for (k, _) in p:
      if eqIdent(k, t):
        return true
  return false

macro nif*(fn: untyped): untyped =
  expectKind(fn, {nnkProcDef, nnkFuncDef})

  let fnPragmas = pragmaTable(fn)

  if not fnPragmas.hasPragma("arity"):
    error "NIF must have specified arity"

  let nifName = getPragmaValue(fnPragmas, "nifName", newLit($fn.name))
  let nifArity = getPragmaValue(fnPragmas, "arity", newLit(0))
  let nifFlags = if fnPragmas.hasPragma("dirtyCpu"):
        ident("ERL_NIF_DIRTY_CPU")
      elif fnPragmas.hasPragma("dirtyIo"):
        ident("ERL_NIF_DIRTY_IO")
      else:
        ident("ERL_NIF_REGULAR")

  let fnName = ident($fn.name)
  let fnInternalName = ident("z" & $fn.name)
  fn.name = fnInternalName
  fn.addPragma(ident("cdecl"))

  result = quote do:
    `fn`
    const `fnName` = ErlNifFunc(
      name: `nifName`,
      arity: `nifArity`,
      fptr: `fnInternalName`,
      flags: `nifFlags`
    )

template exportNifs*(
    moduleName: string,
    nifs: static openArray[ErlNifFunc],
    onLoad: ErlNifEntryLoad = nil,
    onReload: ErlNifEntryReload = nil,
    onUpgrade: ErlNifEntryUpgrade = nil,
    onUnload: ErlNifEntryUnload = nil) =

  let funcs = nifs

  let entry = ErlNifEntry(
    name: module_name,
    num_of_funcs: len(funcs).cint,
    funcs: funcs[0].unsafeAddr,
    major: nifMajor.cint,
    minor: nifMinor.cint,
    vm_variant: "beam.vanilla",
    load: onLoad,
    reload: onReload,
    upgrade: onUpgrade,
    unload: onUnload,
  )

  proc nifInit(): ptr ErlNifEntry {.dynlib, exportc: "nif_init".} =
    entry.unsafeAddr

  static: genWrapper(moduleName, nifs)

