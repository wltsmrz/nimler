import strutils

const (sysInfo, exitCode) = gorgeEx("escript ../scripts/get_erl_sys_info.erl")

when exitCode == 0:
  const infoLines = sysInfo.splitLines()
  const ertsPath* = infoLines[0]
  const nifVersion = infoLines[1].split(".")
  const nifMajor* = parseInt(nifVersion[0])
  const nifMinor* = parseInt(nifVersion[1])
else:
  {.fatal: """
  Could not detect installed Erlang/OTP.
  """".}
