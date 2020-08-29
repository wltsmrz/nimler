import std/strutils
import std/macros

const (sysInfo, exitCode) = gorgeEx("escript ../scripts/get_erl_sys_info.erl")

when exitCode != 0:
  fatal:
    """
    Could not detect installed Erlang/OTP.
    """"

const infoLines = sysInfo.splitLines()
const ertsPath* = infoLines[0]
const nifVersion {.strdefine.}: string = infoLines[1]

const nifMajor* = parseInt(nifVersion.split(".")[0])
const nifMinor* = parseInt(nifVersion.split(".")[1])

func nifVersionGte*(major, minor: Natural): bool {.compileTime.} =
  (major < nifMajor) or (major == nifMajor and minor <= nifMinor)

macro minNifVersion*(major, minor: typed, body: untyped) =
  let majorInt = major.intVal
  let minorInt = minor.intVal

  if not nifVersionGte(majorInt, minorInt):
    body.addPragma(newTree(nnkPragma,
      newTree(nnkExprColonExpr,
      ident("error"),
      newStrLitNode("""


      $1() not supported in target NIF version: $2.$3.
      Requires at least version $4.$5.

      """ % [$body.name, $nifMajor, $nifMinor, $majorInt, $minorInt]))))

  result = body

