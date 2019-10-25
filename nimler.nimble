mode = ScriptMode.Verbose

version = "1.0.0"
author = "wltsmrz"
description = "Erlang/Elixir NIF wrapper"
license = "MIT"
skipDirs = @["tests", "docs", "example"]
skipFiles = @["README.md"]
requires "nim >= 1.0.0"

proc configErlHeaders() =
  switch("cincludes", staticExec("escript scripts/get_erl_lib_dir.erl"))

proc configTest() =
  --verbosity:0
  --forceBuild
  --hints:off
  --warnings:on
  --checks:off
  --stacktrace:on
  --linetrace:on
  --define:useSysAssert
  --path:"."

proc configNif() =
  --app:lib
  --noMain

task test, "dummy":
  quit(0)

task test_all, "build and run test":
  exec("nimble build_init_api")
  exec("nimble build_integration")
  exec("nimble build_codec")
  exec("nimble build_resource")
  exec("nimble build_dirty_nif")
  exec("nimble build_timeslice")
  exec("nimble test_init_api")
  exec("nimble test_integration")
  exec("nimble test_codec")
  exec("nimble test_resource")
  exec("nimble test_dirty_nif")
  exec("nimble test_timeslice")

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

task build_timeslice, "build nif":
  configErlHeaders()
  configNif()
  configTest()
  switch("out", "tests/timeslice/nif.so")
  setCommand("compile", "tests/timeslice/nif")

task test_timeslice, "run test":
  exec("elixir -r tests/timeslice/wrapper.ex tests/timeslice/test.exs")

task build_init_api, "build nif":
  configErlHeaders()
  configNif()
  configTest()
  switch("out", "tests/init_api/nif.so")
  setCommand("compile", "tests/init_api/nif")

task test_init_api, "run test":
  exec("elixir -r tests/init_api/wrapper.ex tests/init_api/test.exs")

task build_mem, "build nif":
  configErlHeaders()
  configNif()
  configTest()
  switch("out", "tests/mem/nif.so")
  setCommand("compile", "tests/mem/nif")

task test_mem, "run test":
  exec("elixir tests/mem/test.exs")
