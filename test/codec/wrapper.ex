
defmodule NimlerWrapper do
    def load_nif, do: :erlang.load_nif(to_charlist(Path.join(Path.dirname(__ENV__.file), "nif")), 0)

    def codec_int(_a, _b), do: raise "not implemented"
    def codec_uint(_a, _b), do: raise "not implemented"
    def codec_atom(_a), do: raise "not implemented"
end
