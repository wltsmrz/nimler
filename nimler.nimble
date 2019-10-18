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
  # --gc:none
  --noMain
  --app:lib

task test, "build and run test":
  exec("nimble build_integration")
  exec("nimble test_integration")

task build_integration, "build nif":
  configErlHeaders()
  configNif()
  configTest()
  switch("out", "test/integration/nif.so")
  setCommand("compile", "test/integration/nif")

task test_integration, "run integration test":
  exec("elixir -r test/integration/wrapper.ex test/integration/test.exs")

