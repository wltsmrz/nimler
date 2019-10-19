
defmodule NimlerWrapper do
    def load_nif, do: :erlang.load_nif(to_charlist(Path.join(Path.dirname(__ENV__.file), "nif")), 0)

    def dirty_cpu(), do: raise "not implemented"
    def dirty_io(), do: raise "not implemented"
end
