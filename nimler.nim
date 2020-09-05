import std/macros
import std/tables

import nimler/erl_sys_info
import nimler/bindings/erl_nif
import nimler/gen_module
import nimler/codec

export erl_sys_info
export erl_nif
export codec

{.passc: "-I" & ertsPath.}

template arity*(x: int) {.pragma.}
template nifName*(x: string) {.pragma.}
template dirtyIo*() {.pragma.}
template dirtyCpu*() {.pragma.}

type PragmaSpec = tuple[k: NimNode, v: NimNode]

func pragmaTable(fn: NimNode): seq[PragmaSpec] {.compileTime.} =
  expectKind(fn, {nnkProcDef, nnkFuncDef})
  for p in fn.pragma:
    case p.kind:
      of nnkIdent, nnkSym:
        result.add((p, newEmptyNode()))
      of nnkExprColonExpr:
        result.add((p[0], p[1]))
      else:
        error "wrong kind: " & $p.kind

func getPragmaValue(p: seq[PragmaSpec],
  t: string, d: NimNode = newEmptyNode()): NimNode {.compileTime.} =
  for (k, v) in p:
    if eqIdent(k, t):
      return v
  return d

func hasPragma(p: seq[PragmaSpec], t: string): bool {.compileTime.} =
  for (k, _) in p:
    if eqIdent(k, t):
      return true
  return false

func copyPragmaWithout(p: NimNode, x: string): NimNode {.compileTime.} =
  expectKind(p, {nnkEmpty, nnkPragma})
  result = newTree(nnkPragma)
  for e in p:
    expectKind(e, {nnkIdent, nnkExprColonExpr})
    case e.kind
    of nnkExprColonExpr:
      if not eqIdent(e[0], x):
        result.add(e)
    of nnkIdent:
      if not eqIdent(e, x):
        result.add(e)
    else: error "wrong kind"

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

proc genNifWrapper(nifName: NimNode, fn: NimNode): NimNode {.compileTime.} =
  expectKind(nifName, nnkStrLit)
  expectKind(fn, {nnkProcDef, nnkFuncDef})

  let rname = fn.name
  fn.name = ident("z" & $fn.name & "Internal")

  let rbody = newTree(nnkStmtList, fn)
  let rcall = newCall(fn.name, ident("env"))

  for i in 2 ..< len(fn.params):
    let p = fn.params[i]
    let arg = newTree(nnkBracketExpr, ident("argv"), newLit(i-2))
    rbody.add(newTree(nnkLetSection, newTree(nnkIdentDefs,
      p[0],
      newNimNode(nnkEmpty),
      newCall("fromTerm", ident("env"), arg, p[1]))))
    rbody.add(newTree(nnkIfStmt, newTree(nnkElifBranch,
      newCall("unlikely", newCall("isNone", p[0])),
      newTree(nnkReturnStmt, newCall("enif_make_badarg", ident("env"))))))
    rcall.add(newCall("unsafeGet", p[0]))

  rbody.add(newTree(nnkReturnStmt, newCall("toTerm", ident("env"), rcall)))

  let rfn = newProc(rname, [], rbody, fn.kind)
  rfn.params = newTree(nnkFormalParams,
    ident("ErlTerm"),
    newTree(nnkIdentDefs,
      ident("env"),
      newNimNode(nnkPtrTy).add(ident("ErlNifEnv")),
      newNimNode(nnkEmpty)),
    newTree(nnkIdentDefs,
      ident("argc"),
      ident("cint"),
      newNimNode(nnkEmpty)),
    newTree(nnkIdentDefs,
      ident("argv"),
      ident("ErlNifArgs"),
      newNimNode(nnkEmpty)))

  rfn.pragma = copyPragmaWithout(fn.pragma, "raises")
  rfn.pragma.add(ident("nif"))
  rfn.pragma.add(newTree(nnkExprColonExpr,
    ident("arity"),
    newLit(len(fn.params)-2)))
  rfn.pragma.add(newTree(nnkExprColonExpr, ident("nif_name"), nifName))

  result = rfn

macro xnif*(nifName: untyped, fn: untyped): untyped =
  result = genNifWrapper(nifName, fn)

macro xnif*(fn: untyped): untyped =
  result = genNifWrapper(newLit(repr fn.name), fn)

