mode = ScriptMode.Verbose

version = "0.0.1"
author = "wltsmrz"
description = "Erlang/Elixir NIF wrapper"
license = "MIT"
srcDir = "src"
skipDirs = @["test"]
# installFiles = @["nif_interface.nim"]
requires "nim >= 1.0.0"

proc configErlHeaders() =
  switch("cincludes", staticExec("escript get_erl_lib_dir.erl"))

proc configTest() =
  --verbosity:1
  --forceBuild
  --hints:off
  --warnings:off
  --stacktrace:on
  --linetrace:on
  --threadAnalysis:off
  --debuginfo
  --path:"."

proc configNif() =
  --gc:none
  --noMain
  --app:lib

task test, "build and run test":
  exec("nimble build_integration")
  exec("nimble test_integration")
  exec("nimble build_codec")
  exec("nimble test_codec")


# Kitchen skink tests
task build_integration, "build nif":
  configErlHeaders()
  configNif()
  configTest()
  switch("out", "test/integration/nif.so")
  setCommand("compile", "test/integration/nif")

task test_integration, "run test":
  exec("elixir -r test/integration/wrapper.ex test/integration/test.exs")


# ErlNifTerm codec
task build_codec, "build nif":
  configErlHeaders()
  configNif()
  configTest()
  switch("out", "test/codec/nif.so")
  setCommand("compile", "test/codec/nif")

task test_codec, "run test":
  exec("elixir -r test/codec/wrapper.ex test/codec/test.exs")


