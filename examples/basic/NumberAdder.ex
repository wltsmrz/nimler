defmodule NumberAdder do
  @on_load :init
  def init(),
    do: :erlang.load_nif(to_charlist(Path.join(Path.dirname(__ENV__.file), 'libnif')), 0)

  def add_numbers(_, _), do: :erlang.nif_error(:nif_library_not_loaded)
  def sub_numbers(_, _), do: :erlang.nif_error(:nif_library_not_loaded)
end
