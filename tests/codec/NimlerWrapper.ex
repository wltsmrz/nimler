defmodule NimlerCodec do
  @on_load :init
  def init(), do: :erlang.load_nif(to_charlist(Path.join(Path.dirname(__ENV__.file), 'nif')), 0)

  def codec_options(_, _), do: exit(:nif_library_not_loaded)
  def codec_int(_, _), do: exit(:nif_library_not_loaded)
  def codec_int32(_, _), do: exit(:nif_library_not_loaded)
  def codec_uint32(_, _), do: exit(:nif_library_not_loaded)
  def codec_uint64(_), do: exit(:nif_library_not_loaded)
  def codec_double(_), do: exit(:nif_library_not_loaded)
  def codec_atom(_), do: exit(:nif_library_not_loaded)
  def codec_charlist(_), do: exit(:nif_library_not_loaded)
  def codec_string(_), do: exit(:nif_library_not_loaded)
  def codec_binary(_), do: exit(:nif_library_not_loaded)
  def codec_list_int(_), do: exit(:nif_library_not_loaded)
  def codec_list_string(_), do: exit(:nif_library_not_loaded)
  def codec_tuple(_), do: exit(:nif_library_not_loaded)
  def codec_map(_, _, _), do: exit(:nif_library_not_loaded)
  def codec_result_ok(_, _), do: exit(:nif_library_not_loaded)
  def codec_result_error(_, _), do: exit(:nif_library_not_loaded)
end
