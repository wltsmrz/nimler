
defmodule NimlerWrapper do
    def load_nif, do: :erlang.load_nif(to_charlist(Path.join(Path.dirname(__ENV__.file), "nif")), 0)

    def new(), do: raise "not implemented"
    def set(_a, _b), do: raise "not implemented"
    def check(_a, _b), do: raise "not implemented"
end
