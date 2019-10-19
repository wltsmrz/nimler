mode = ScriptMode.Verbose

version = "0.0.1"
author = "wltsmrz"
description = "Erlang/Elixir NIF wrapper"
license = "MIT"
srcDir = "src"
skipDirs = @["tests"]
# installFiles = @["nimler.nim"]
requires "nim >= 1.0.0"

proc configErlHeaders() =
  switch("cincludes", staticExec("escript scripts/get_erl_lib_dir.erl"))

proc configTest() =
  --verbosity:1
  --forceBuild
  --hints:off
  --warnings:off
  --stacktrace:on
  --linetrace:on
  --debuginfo
  --path:"."

proc configNif() =
  --checks:off
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
  switch("out", "tests/integration/nif.so")
  setCommand("compile", "tests/integration/nif")

task test_integration, "run test":
  exec("elixir -r tests/integration/wrapper.ex tests/integration/test.exs")


# ErlNifTerm codec
task build_codec, "build nif":
  configErlHeaders()
  configNif()
  configTest()
  switch("out", "tests/codec/nif.so")
  setCommand("compile", "tests/codec/nif")

task test_codec, "run test":
  exec("elixir -r tests/codec/wrapper.ex tests/codec/test.exs")

