import std/strutils
import std/macros

const (sysInfo, exitCode) = gorgeEx("escript ../scripts/get_erl_sys_info.erl")

when exitCode != 0:
  {.fatal: """
  Could not detect installed Erlang/OTP.
  """".}

const info_lines = sysInfo.splitLines()
const erts_path* = infoLines[0]
const nif_version {.strdefine.}: string = info_lines[1]
const nif_major* = parseInt(nif_version.split(".")[0])
const nif_minor* = parseInt(nif_version.split(".")[1])

func nif_version_gte*(major, minor: Natural): bool {.compileTime.} =
  (major < nif_major) or (major == nif_major and minor <= nif_minor)

func clone_func*(fn: NimNode, is_export: bool = false): NimNode =
  if fn.kind == nnkFuncDef:
    result = nnkFuncDef.newTree(newNimNode(nnkEmpty))
  else:
    result = nnkProcDef.newTree(newNimNode(nnkEmpty))

  if is_export:
    let export_marker = newNimNode(nnkPostfix)
    export_marker.add(ident("*"))
    export_marker.add(fn.name)
    result.name = export_marker
  # else:
    # would like to set name here, but ambiguous error
    # "has no type (or is ambiguous)"
    # result.name.add(ident($fn.name & "_nif"))

  for i, child in fn:
    if i != 0:
      result.add(child)

macro min_nif_version*(major, minor: typed, body: untyped) =
  let nif_fn = clone_func(body, is_export=true)
  let major_int = major.intVal
  let minor_int = minor.intVal

  if not nif_version_gte(major_int, minor_int):
    let err_pragma = newNimNode(nnkPragma)
    let pragma_body = newNimNode(nnkExprColonExpr)
    pragma_body.add(ident("error"))
    pragma_body.add(newStrLitNode("""


    $1() not supported in target NIF version: $2.$3.
    Requires at least version $4.$5.

    """ % [$body.name, $nif_major, $nif_minor, $major_int, $minor_int]
    ))
    err_pragma.add(pragma_body)
    nif_fn.pragma = errpragma

  result = nif_fn

