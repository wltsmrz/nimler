ExUnit.start(autorun: false)

tests = Path.wildcard("tests/**/test.exs")
test_wrappers = Path.wildcard("tests/**/NimlerWrapper.ex")

Enum.each(test_wrappers, fn t -> Code.require_file(t) end)
Enum.each(tests, fn t -> Code.require_file(t) end)

Mix.Compilers.Test.require_and_run(tests, [], formatters: [ExUnit.CLIFormatter])

