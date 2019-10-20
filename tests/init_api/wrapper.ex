
defmodule NimlerWrapper do
    def load_nif, do: :erlang.load_nif(to_charlist(Path.join(Path.dirname(__ENV__.file), "nif")), 123)

    def test(), do: raise "not implemented"
    def test_priv(), do: raise "not implemented"
    def test_dirty(), do: raise "not implemented"
end
