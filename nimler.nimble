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
  --verbosity:0
  --forceBuild
  --hints:off
  --warnings:off
  --stacktrace:on
  --linetrace:on
  --path:"."

proc configNif() =
  --checks:off
  --app:lib

task test, "build and run test":
  exec("nimble build_integration")
  exec("nimble build_codec")
  exec("nimble build_resource")
  exec("nimble build_dirty_nif")
  exec("nimble test_integration")
  exec("nimble test_codec")
  exec("nimble test_resource")
  exec("nimble test_dirty_nif")


# Kitchen skink tests
task build_integration, "build nif":
  configErlHeaders()
  configNif()
  configTest()
  switch("out", "tests/integration/nif.so")
  setCommand("compile", "tests/integration/nif")

task test_integration, "run test":
  exec("elixir -r tests/integration/wrapper.ex tests/integration/test.exs")

task build_codec, "build nif":
  configErlHeaders()
  configNif()
  configTest()
  switch("out", "tests/codec/nif.so")
  setCommand("compile", "tests/codec/nif")

task test_codec, "run test":
  exec("elixir -r tests/codec/wrapper.ex tests/codec/test.exs")

task build_resource, "build nif":
  configErlHeaders()
  configNif()
  configTest()
  switch("out", "tests/resource/nif.so")
  setCommand("compile", "tests/resource/nif")

task test_resource, "run test":
  exec("elixir -r tests/resource/wrapper.ex tests/resource/test.exs")

task build_dirty_nif, "build nif":
  configErlHeaders()
  configNif()
  configTest()
  switch("out", "tests/dirty_nif/nif.so")
  setCommand("compile", "tests/dirty_nif/nif")

task test_dirty_nif, "run test":
  exec("elixir -r tests/dirty_nif/wrapper.ex tests/dirty_nif/test.exs")

