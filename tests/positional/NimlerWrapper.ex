defmodule NimlerPositionalArgs do
  @on_load :init

  def init(), do: :erlang.load_nif(to_charlist(
      Path.join(Path.dirname(__ENV__.file), 'nif')), 0)

  def pos_int(_, _), do: exit(:nif_library_not_loaded)
  def pos_bool(_, _, _, _), do: exit(:nif_library_not_loaded)
  def pos_bin(_), do: exit(:nif_library_not_loaded)
  def pos_str(_), do: exit(:nif_library_not_loaded)
  def pos_charlist(_), do: exit(:nif_library_not_loaded)
  def pos_seq(_), do: exit(:nif_library_not_loaded)
  def pos_map(_), do: exit(:nif_library_not_loaded)
  def pos_tup_map(_), do: exit(:nif_library_not_loaded)
  def pos_pid(_, _), do: exit(:nif_library_not_loaded)
  def pos_ok?(_), do: exit(:nif_library_not_loaded)
  def pos_keywords(_), do: exit(:nif_library_not_loaded)
  def pos_result(_, _), do: exit(:nif_library_not_loaded)
  
end
