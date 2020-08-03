import std/strutils

const (sysInfo, exitCode) = gorgeEx("escript ../scripts/get_erl_sys_info.erl")

when exitCode == 0:
  const infoLines = sysInfo.splitLines()
  const ertsPath* = infoLines[0]
  const nifVersionStr = infoLines[1].split(".")
  const nifMajor* = parseInt(nifVersionStr[0])
  const nifMinor* = parseInt(nifVersionStr[1])
else:
  {.fatal: """
  Could not detect installed Erlang/OTP.
  """".}

template min_nif_version*(major, minor: int, body) =
  when (nifMajor, nifMinor) < (major, minor):
    {.fatal: """
    $1

    Not supported in target NIF version: $2.$3.
    Requires at least $4.$5.
    """ % [astToStr(fn), $nifMajor, $nifMinor, $major, $minor].}
  body
