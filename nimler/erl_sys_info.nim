import strutils

const sysInfo = staticExec("escript ../scripts/get_erl_sys_info.erl").splitLines()
const ertsPath* = sysInfo[0]
const nifVersion* = sysInfo[1].split(".")
const nifMajor* = parseInt(nifVersion[0])
const nifMinor* = parseInt(nifVersion[1])
