import std/strutils
import std/macros

const (sysInfo, exitCode) = gorgeEx("escript ../scripts/get_erl_sys_info.erl")

when exitCode == 0:
  const infoLines = sysInfo.splitLines()
  const ertsPath* = infoLines[0]
  const nifVersionStr = infoLines[1].split(".")
  const nif_major* = parseInt(nifVersionStr[0])
  const nif_minor* = parseInt(nifVersionStr[1])
else:
  {.fatal: """
  Could not detect installed Erlang/OTP.
  """".}

func version_gte(major, minor: Natural): bool =
  (major < nif_major) or (major == nif_major and minor <= nif_minor)

func clone_proc(fn: NimNode): NimNode =
  result = nnkFuncDef.newTree(newNimNode(nnkEmpty))

  let export_marker = newNimNode(nnkPostfix)
  export_marker.add(ident("*"))
  export_marker.add(fn.name)
  result.name = export_marker

  for i, child in fn:
    if i != 0:
      result.add(child)

macro min_nif_version*(major, minor: typed, body: untyped) =
  let nif_fn = clone_proc(body)
  let major_int = major.intVal
  let minor_int = minor.intVal

  if not version_gte(major_int, minor_int):
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
