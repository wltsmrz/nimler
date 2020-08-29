import std/macros
import std/os
import std/compilesettings
import std/strutils
import bindings/erl_nif

const nimlerWrapperRoot {.strdefine.}: string = ""
const nimlerWrapperFilename {.strdefine.}: string = ""
const nimlerWrapperLoadInfo {.strdefine.}: string = "0"

type ElixirModule = object
  head: string
  tail: string
  fns: seq[string]

func init(m: var ElixirModule, module_name: string, nif_filename: string, load_info: string) =
  m.head.addf("defmodule $1 do\n", module_name)
  m.head.add("  @on_load :init\n")
  m.head.addf("  def init(), do: :erlang.load_nif(to_charlist(Path.join(Path.dirname(__ENV__.file), \'$1\')), $2)\n\n", nif_filename, load_info)
  m.tail = "\nend\n"

func addFn(m: var ElixirModule, name: string, arity: int) =
  let params = "_".repeat(arity).join(", ")
  m.fns.add("  def $1($2), do: exit(:nif_library_not_loaded)" % [name, params])

func `$`(m: var ElixirModule): string =
  result = m.head & m.fns.join("\n") & m.tail

proc genWrapper*(moduleName: string, funcs: static openArray[ErlNifFunc]) {.compileTime.} =
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

  if defined(nimlerGenWrapperForce) or (defined(nimlerGenWrapper) and not fileExists(moduleFilepath)):
    discard staticExec("mkdir -p " & outDir)

    var elixirModule = ElixirModule()
    elixirModule.init(erlModuleName, nifFilename, loadInfo)
    for fn in funcs:
      elixirModule.addFn($fn.name, fn.arity.int)
      
    hint("Generating wrapper module: " & moduleFilepath)
  
    writeFile(moduleFilepath, $elixirModule)

