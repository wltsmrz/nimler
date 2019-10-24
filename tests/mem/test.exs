
defmodule NimlerWrapper do
    @on_load :load_nif

    def test_mem(_a), do: raise "not implemented"

    def iter(inp) do
        receive do
            after
                500 ->
                    {usec, _} = :timer.tc(fn -> test_mem(inp) end)
                    :erlang.garbage_collect()
                    IO.inspect(usec, label: "uSec")
                    IO.inspect(:erlang.memory()[:processes] / 1_000, label: "totalmem")
                    iter(inp)
        end
    end

    def load_nif do
        :erlang.load_nif(to_charlist(Path.join(Path.dirname(__ENV__.file), "nif")), 123)
        inp = Enum.reduce(1..10_000, '', fn _, acc -> acc ++ '.' end)
        iter(inp)
    end
end
