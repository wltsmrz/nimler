import std/macros
import std/os
import std/compilesettings
import std/strutils
import std/sequtils
import bindings/erl_nif

const nimlerWrapperRoot {.strdefine.}: string = ""
const nimlerWrapperFilename {.strdefine.}: string = ""
const nimlerWrapperLoadInfo {.strdefine.}: string = "0"

proc gen_wrapper*(module_name: string, funcs: static openArray[ErlNifFunc]) {.compileTime.} =
  let out_dir =
    if nimlerWrapperRoot == "":
      querySetting(outDir)
    else:
      nimlerWrapperRoot

  doAssert(isAbsolute(out_dir), "Nimler root dir must be absolute")
  discard staticExec("mkdir -p " & out_dir)

  let out_file = querySetting(outFile)
  let module_name = module_name.replace("Elixir.", "")
  let module_filename =
    if nimlerWrapperFilename == "":
      module_name & ".ex"
    else:
      nimlerWrapperFilename

  let module_filepath = joinPath(out_dir, module_filename)

  let nif_filename = out_file.replace(".so", "")
  let load_info = nimlerWrapperLoadInfo

  if defined(nimlerGenWrapperForce) or (defined(nimlerGenWrapper) and not fileExists(module_filepath)):
    var module_contents = ""
    module_contents.addf("defmodule $1 do\n", module_name)
    module_contents.add("  @on_load :init\n")
    module_contents.addf("  def init(), do: :erlang.load_nif(to_charlist(Path.join(Path.dirname(__ENV__.file), \'$1\')), $2)\n\n", nif_filename, load_info)

    {.push hints: off.}
    for fn in funcs:
      module_contents.addf("  def $1(", fn.name)
      module_contents.add((0 ..< fn.arity.int).toSeq().mapIt("_").join(", "))
      module_contents.add("), do: exit(:nif_library_not_loaded)\n")
    {.pop.}
      
    module_contents.add("end\n")

    hint:
      "Generating wrapper module: " & module_filepath

    writeFile(module_filepath, module_contents)

