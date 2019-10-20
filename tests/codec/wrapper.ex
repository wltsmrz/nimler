
defmodule NimlerWrapper do
    def load_nif, do: :erlang.load_nif(to_charlist(Path.join(Path.dirname(__ENV__.file), "nif")), 0)

    def codec_int32(_a, _b), do: raise "not implemented"
    def codec_uint32(_a, _b), do: raise "not implemented"
    def codec_atom(_a), do: raise "not implemented"
    def codec_varargs_tuple(), do: raise "not implemented"
    def codec_result_ok(_a), do: raise "not implemented"
    def codec_result_error(_a), do: raise "not implemented"
    def codec_list(), do: raise "not implemented"
end
