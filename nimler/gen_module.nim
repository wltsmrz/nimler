import std/os
import std/compilesettings
import std/strformat
import std/strutils
import std/sequtils
import bindings/erl_nif

const nimlerWrapperFilename {.strdefine.}: string = ""
const nimlerWrapperLoadInfo {.strdefine.}: string = "0"

proc gen_wrapper*(module_name: string, funcs: static openArray[ErlNifFunc]) {.compileTime.} =
  let out_dir = querySetting(outDir)
  let out_file = querySetting(outFile)
  let module_name = module_name.replace("Elixir.", "")
  let module_filename =
    if nimlerWrapperFilename == "":
      &"{module_name}.ex"
    else:
      nimlerWrapperFilename
  let module_filepath = joinPath(out_dir, module_filename)
  let nif_filename = out_file.replace(".so", "")
  let load_info = nimlerWrapperLoadInfo

  if defined(nimlerGenWrapperForce) or (defined(nimlerGenWrapper) and not fileExists(module_filepath)):
    var module_contents = &"defmodule {module_name} do\n"
    module_contents &= "  @on_load :init\n"
    module_contents &= &"  def init(), do: :erlang.load_nif(to_charlist(Path.join(Path.dirname(__ENV__.file), '{nif_filename}')), {load_info})\n\n"

    proc arity_m(i: int): string = "_"

    for fn in funcs:
      module_contents &= &"  def {$fn.name}("
      module_contents &= (0 ..< fn.arity.int).toSeq().map(arity_m).join(", ")
      module_contents &= "), do: exit(:nif_library_not_loaded)\n"
      
    module_contents &= "end\n"

    echo "Generating wrapper module: " & module_filepath
    writeFile(module_filepath, module_contents)

