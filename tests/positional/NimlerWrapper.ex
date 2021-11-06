defmodule NimlerPositionalArgs do
  @on_load :init

  def init(),
    do:
      :erlang.load_nif(
        to_charlist(Path.join(Path.dirname(__ENV__.file), 'nif')),
        0
      )

  def pos_int(_, _), do: :erlang.nif_error(:nif_library_not_loaded)
  def pos_bool(_, _, _, _), do: :erlang.nif_error(:nif_library_not_loaded)
  def pos_bin(_), do: :erlang.nif_error(:nif_library_not_loaded)
  def pos_str(_), do: :erlang.nif_error(:nif_library_not_loaded)
  def pos_charlist(_), do: :erlang.nif_error(:nif_library_not_loaded)
  def pos_seq(_), do: :erlang.nif_error(:nif_library_not_loaded)
  def pos_map(_), do: :erlang.nif_error(:nif_library_not_loaded)
  def pos_tup_map(_), do: :erlang.nif_error(:nif_library_not_loaded)
  def pos_pid(_, _), do: :erlang.nif_error(:nif_library_not_loaded)
  def pos_ok?(_), do: :erlang.nif_error(:nif_library_not_loaded)
  def pos_keywords(_), do: :erlang.nif_error(:nif_library_not_loaded)
  def pos_result(_, _), do: :erlang.nif_error(:nif_library_not_loaded)
end
