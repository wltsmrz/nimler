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
  m.tail = "\nend"

func add_fn(m: var ElixirModule, name: string, arity: int) =
  let params = "_".repeat(arity).join(",")
  m.fns.add("  def $1($2), do: exit(:nif_library_not_loaded)" % [name, params])

func `$`(m: var ElixirModule): string =
  result = m.head & m.fns.join("\n") & m.tail

proc gen_wrapper*(module_name: string, funcs: static openArray[ErlNifFunc]) {.compileTime.} =
  let out_dir =
    if nimlerWrapperRoot == "":
      querySetting(outDir)
    else:
      nimlerWrapperRoot

  doAssert(isAbsolute(out_dir), "Nimler root dir must be absolute")

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
    discard staticExec("mkdir -p " & out_dir)

    var elixir_module = ElixirModule()
    elixir_module.init(module_name, nif_filename, load_info)
    for fn in funcs:
      elixir_module.add_fn($fn.name, fn.arity.int)
      
    hint:
      "Generating wrapper module: " & module_filepath
  
    writeFile(module_filepath, $elixir_module)

