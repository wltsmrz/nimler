mode = ScriptMode.Silent

version = "2.0.0"
author = "wltsmrz"
description = "Erlang/Elixir NIFs"
license = "MIT"
skipDirs = @["tests", "docs", "examples"]
skipFiles = @["README.md"]
installDirs = @["nimler", "scripts"]
installFiles = @["nimler.nim"]

requires "nim >= 1.2.0"

proc configNif() =
  --app:lib
  --noMain
  --gc:arc

proc configTest() =
  --verbosity:2
  --hint[Conf]:off
  --hint[Processing]:off
  --hint[Exec]:off
  --hint[Link]:off
  --hint[GCStats]:off
  --hint[GlobalVar]:off
  --hint[SuccessX]:off
  --checks:off
  --path:"."
  configNif()

task test, "dummy":
  quit(0)

task build_all, "build":
  exec("nimble build_init_api")
  exec("nimble build_dirty_nif")
  exec("nimble build_integration")
  exec("nimble build_codec")
  exec("nimble build_resource")
  exec("nimble build_init_resource")
  exec("nimble build_timeslice")

task test_all, "run tests":
  exec("nimble test_init_api")
  exec("nimble test_dirty_nif")
  exec("nimble test_integration")
  exec("nimble test_codec")
  exec("nimble test_resource")
  exec("nimble test_init_resource")
  exec("nimble test_timeslice")

task build_init_api, "build nif":
  configTest()
  switch("out", "tests/init_api/nif.so")
  setCommand("compile", "tests/init_api/nif")

task test_init_api, "run test":
  exec("elixir -r tests/init_api/wrapper.ex tests/init_api/test.exs")

task build_integration, "build nif":
  configTest()
  switch("out", "tests/integration/nif.so")
  setCommand("compile", "tests/integration/nif")

task test_integration, "run test":
  exec("elixir -r tests/integration/wrapper.ex tests/integration/test.exs")

task build_codec, "build nif":
  configTest()
  switch("out", "tests/codec/nif.so")
  setCommand("compile", "tests/codec/nif")

task test_codec, "run test":
  exec("elixir -r tests/codec/wrapper.ex tests/codec/test.exs")

task build_resource, "build nif":
  configTest()
  switch("out", "tests/resource/nif.so")
  setCommand("compile", "tests/resource/nif")

task test_resource, "run test":
  exec("elixir -r tests/resource/wrapper.ex tests/resource/test.exs")

task build_init_resource, "build nif":
  configTest()
  switch("out", "tests/init_resource/nif.so")
  setCommand("compile", "tests/init_resource/nif")

task test_init_resource, "run test":
  exec("elixir -r tests/init_resource/wrapper.ex tests/init_resource/test.exs")

task build_dirty_nif, "build nif":
  configTest()
  switch("out", "tests/dirty_nif/nif.so")
  setCommand("compile", "tests/dirty_nif/nif")

task test_dirty_nif, "run test":
  exec("elixir -r tests/dirty_nif/wrapper.ex tests/dirty_nif/test.exs")

task build_timeslice, "build nif":
  configTest()
  switch("out", "tests/timeslice/nif.so")
  setCommand("compile", "tests/timeslice/nif")

task test_timeslice, "run test":
  exec("elixir -r tests/timeslice/wrapper.ex tests/timeslice/test.exs")

task run_init_api, "run test":
  exec("nimble build_init_api")
  exec("elixir -r tests/init_api/wrapper.ex tests/init_api/test.exs")
task run_integration, "run test":
  exec("nimble build_integration")
  exec("elixir -r tests/integration/wrapper.ex tests/integration/test.exs")
task run_codec, "run test":
  exec("nimble build_codec")
  exec("elixir -r tests/codec/wrapper.ex tests/codec/test.exs")
task run_dirty_nif, "run test":
  exec("nimble build_dirty_nif")
  exec("elixir -r tests/dirty_nif/wrapper.ex tests/dirty_nif/test.exs")
task run_init_resource, "run test":
  exec("nimble build_init_resource")
  exec("elixir -r tests/init_resource/wrapper.ex tests/init_resource/test.exs")
task run_resource, "run test":
  exec("nimble build_resource")
  exec("elixir -r tests/resource/wrapper.ex tests/resource/test.exs")
task run_timeslice, "run test":
  exec("nimble build_timeslice")
  exec("elixir -r tests/timeslice/wrapper.ex tests/timeslice/test.exs")

