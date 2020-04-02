
defmodule NimlerWrapper do
    def load_nif, do: :erlang.load_nif(to_charlist(Path.join(Path.dirname(__ENV__.file), "nif")), 0)

    def codec_int32(_a, _b), do: raise "not implemented"
    def codec_uint32(_a, _b), do: raise "not implemented"
    def codec_double(_a), do: raise "not implemented"
    def codec_uint64(_a), do: raise "not implemented"
    def codec_atom(_a), do: raise "not implemented"
    def codec_string(_a), do: raise "not implemented"
    def codec_charlist(_a), do: raise "not implemented"
    def codec_tuple(_a), do: raise "not implemented"
    def codec_result_ok(_a), do: raise "not implemented"
    def codec_result_error(_a), do: raise "not implemented"
    def codec_list(_a), do: raise "not implemented"
    def codec_binary(_a), do: raise "not implemented"
    def codec_map(_a, _b, _c), do: raise "not implemented"
end
