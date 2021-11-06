import std/macros
import std/os
import std/compilesettings
import std/strutils
import bindings/erl_nif

const nimlerWrapperRoot {.strdefine.}: string = ""
const nimlerWrapperFilename {.strdefine.}: string = ""
const nimlerWrapperLoadInfo {.strdefine.}: string = "0"
const nimlerWrapperType {.strdefine.}: string = "elixir"

const elixirModule = """
  defmodule $1 do
    @on_load :init

    def init(), do: :erlang.load_nif(to_charlist(
        Path.join(Path.dirname(__ENV__.file), '$2')), $3)

$4
  end
"""
const elixirFn = """
  def $1($2), do: :erlang.nif_error(:nif_library_not_loaded)
"""

const erlangModule = """
  -module($1).
  -export([
$4
  ]).
  -on_load(init/0).

  init() -> ok = erlang:load_nif("./$2", $3).

$5
"""
const erlangFn = """
  $1($2) -> :erlang.nif_error(:nif_library_not_loaded).
"""

proc genFn(templ: string, fn: ErlNifFunc): string {.compileTime.} =
  let params = "_".repeat(fn.arity).join(", ")
  return format(templ, [$fn.name, params]).unindent()

proc genErlangWrapper(moduleName: string, nifFilename: string, loadInfo: string,
    funcs: openArray[ErlNifFunc]): string {.compileTime.} =
  var exports = newSeqOfCap[string](len(funcs))
  var fns = newSeqOfCap[string](len(funcs))

  for i in 0 .. high(funcs):
    fns.add(genFn(erlangFn, funcs[i]).unindent())
    exports.add($funcs[i].name & "/" & $funcs[i].arity)

  return erlangModule
  .format([
    moduleName,
    nifFilename,
    loadInfo,
    exports.join(",\n").indent(4),
    fns.join("").indent(2)
  ])
  .unindent(2)

proc genElixirWrapper(moduleName: string, nifFilename: string, loadInfo: string,
    funcs: openArray[ErlNifFunc]): string {.compileTime.} =
  var fns = newSeqOfCap[string](len(funcs))

  for i in 0 .. high(funcs):
    fns.add(genFn(elixirFn, funcs[i]))

  return elixirModule
  .format([
    moduleName,
    nifFilename,
    loadInfo,
    fns.join("").indent(4)
  ])
  .unindent(2)

proc genWrapper*(moduleName: string,
    funcs: static openArray[ErlNifFunc]) {.compileTime.} =
  let outDir =
    if nimlerWrapperRoot == "":
      querySetting(outDir)
    else:
      nimlerWrapperRoot

  doAssert(isAbsolute(outDir), "Nimler root dir must be absolute")

  let outFile = querySetting(outFile)
  let erlModuleName = moduleName.replace("Elixir.", "")
  let moduleFilename =
    if nimlerWrapperFilename == "":
      erlModuleName & ".ex"
    else:
      nimlerWrapperFilename
  let moduleFilepath = joinPath(outDir, moduleFilename)
  let nifFilename = outFile.replace(".so", "")
  let loadInfo = nimlerWrapperLoadInfo

  if defined(nimlerGenWrapperForce) or (defined(nimlerGenWrapper) and
      not fileExists(moduleFilepath)):
    discard staticExec("mkdir -p " & outDir)

    hint("Generating wrapper module: " & moduleFilepath)

    case nimlerWrapperType:
    of "elixir":
      writeFile(moduleFilepath, genElixirWrapper(erlModuleName, nifFilename,
          loadInfo, funcs))
    of "erlang":
      writeFile(moduleFilepath, genErlangWrapper(erlModuleName, nifFilename,
          loadInfo, funcs))
    else:
      error("invalid wrapper module type: " & nimlerWrapperType)

