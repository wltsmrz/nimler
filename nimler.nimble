mode = ScriptMode.Silent
version = "4.2.0"
author = "wltsmrz"
description = "Erlang/Elixir NIFs"
license = "MIT"
skipDirs = @["tests", "docs", "examples"]
skipFiles = @["README.md"]
installDirs = @["nimler", "scripts"]
installFiles = @["nimler.nim"]
requires "nim >= 1.2.0"

proc configTest() =
  if getEnv("NIMLER_BUILD_RELEASE") == "1":
    --define:release

  if getEnv("NIMLER_BUILD_ARM64") == "1":
    --gcc.exe:"aarch64-linux-gnu-gcc"
    --gcc.linkerexe:"aarch64-linux-gnu-ld"
    --cpu:arm64
    --os:linux

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
  exec("nimble build_message")
  exec("nimble build_positional")

task test_all, "run tests":
  exec("elixir test_all.exs")

task build_init_api, "build nif":
  configTest()
  switch("out", "tests/init_api/nif.so")
  switch("define", "nimlerWrapperLoadInfo=123")
  setCommand("compile", "tests/init_api/nif")

task test_init_api, "run test":
  exec("elixir -r tests/init_api/NimlerWrapper.ex tests/init_api/test.exs")

task build_integration, "build nif":
  configTest()
  switch("out", "tests/integration/nif.so")
  setCommand("compile", "tests/integration/nif")

task test_integration, "run test":
  exec("elixir -r tests/integration/NimlerWrapper.ex tests/integration/test.exs")

task build_codec, "build nif":
  configTest()
  switch("out", "tests/codec/nif.so")
  setCommand("compile", "tests/codec/nif")

task test_codec, "run test":
  exec("elixir -r tests/codec/NimlerWrapper.ex tests/codec/test.exs")

task build_resource, "build nif":
  configTest()
  switch("out", "tests/resource/nif.so")
  setCommand("compile", "tests/resource/nif")

task test_resource, "run test":
  exec("elixir -r tests/resource/NimlerWrapper.ex tests/resource/test.exs")

task build_init_resource, "build nif":
  configTest()
  switch("out", "tests/init_resource/nif.so")
  setCommand("compile", "tests/init_resource/nif")

task test_init_resource, "run test":
  exec("elixir -r tests/init_resource/NimlerWrapper.ex tests/init_resource/test.exs")

task build_dirty_nif, "build nif":
  configTest()
  switch("out", "tests/dirty_nif/nif.so")
  setCommand("compile", "tests/dirty_nif/nif")

task test_dirty_nif, "run test":
  exec("elixir -r tests/dirty_nif/NimlerWrapper.ex tests/dirty_nif/test.exs")

task build_timeslice, "build nif":
  configTest()
  switch("out", "tests/timeslice/nif.so")
  setCommand("compile", "tests/timeslice/nif")

task test_timeslice, "run test":
  exec("elixir -r tests/timeslice/NimlerWrapper.ex tests/timeslice/test.exs")

task build_message, "build nif":
  configTest()
  switch("out", "tests/message/nif.so")
  setCommand("compile", "tests/message/nif")

task test_message, "run test":
  exec("elixir -r tests/message/NimlerWrapper.ex tests/message/test.exs")

task build_positional, "build nif":
  configTest()
  switch("out", "tests/positional/nif.so")
  setCommand("compile", "tests/positional/nif")

task test_positional, "run test":
  exec("elixir -r tests/positional/NimlerWrapper.ex tests/positional/test.exs")

task run_init_api, "run test":
  exec("nimble build_init_api")
  exec("nimble test_init_api")
task run_integration, "run test":
  exec("nimble build_integration")
  exec("nimble test_integration")
task run_codec, "run test":
  exec("nimble build_codec")
  exec("nimble test_codec")
task run_dirty_nif, "run test":
  exec("nimble build_dirty_nif")
  exec("nimble test_dirty_nif")
task run_init_resource, "run test":
  exec("nimble build_init_resource")
  exec("nimble test_init_resource")
task run_resource, "run test":
  exec("nimble build_resource")
  exec("nimble test_resource")
task run_timeslice, "run test":
  exec("nimble build_timeslice")
  exec("nimble test_timeslice")
task run_message, "run test":
  exec("nimble build_message")
  exec("nimble test_message")
task run_positional, "run test":
  exec("nimble build_positional")
  exec("nimble test_positional")
