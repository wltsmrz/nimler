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

macro min_nif_version*(major, minor: typed, body: untyped) =
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
    body.pragma = err_pragma

  result = body

