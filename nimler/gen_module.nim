import std/os
import std/compilesettings
import std/strformat
import std/strutils
import std/sequtils
import bindings/erl_nif

proc gen_elixir_module*(module_name: string, funcs: static openArray[ErlNifFunc]) {.compileTime.} =
  let out_dir = querySetting(outDir)
  let out_file = querySetting(outFile)
  let elixir_module_name = module_name.replace("Elixir.", "")
  let elixir_module_path = joinPath(out_dir, &"{elixir_module_name}.ex")
  let nif_filename = out_file.replace(".so", "")

  if defined(nimlerGenModuleForce) or not fileExists(elixir_module_path):
    var module_contents = &"defmodule {elixir_module_name} do\n"
    module_contents &= "  @on_load :init\n"
    module_contents &= &"  def init(), do: :erlang.load_nif(to_charlist(Path.join(Path.dirname(__ENV__.file), '{nif_filename}')), 0)\n\n"
    proc arity_m(i: int): string = "_"
    for fn in funcs:
      module_contents &= &"  def {$fn.name}("
      module_contents &= (0 ..< fn.arity.int).toSeq().map(arity_m).join(", ")
      module_contents &= "), do: exit(:nif_library_not_loaded)\n"
    module_contents &= "end\n"

    echo "Generating Elixir module: " & elixir_module_path
    writeFile(elixir_module_path, module_contents)

