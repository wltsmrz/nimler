
defmodule NimlerWrapper do
    def load_nif, do: :erlang.load_nif(to_charlist(Path.join(Path.dirname(__ENV__.file), "nif")), 0)

    def test_consume_timeslice(_a, _b), do: raise "not implemented"
end
