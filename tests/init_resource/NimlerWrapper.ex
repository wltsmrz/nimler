defmodule NimlerInitResource do
  @on_load :init
  def init(), do: :erlang.load_nif(to_charlist(Path.join(Path.dirname(__ENV__.file), 'nif')), 0)

  def new(), do: exit(:nif_library_not_loaded)
  def set(_, _), do: exit(:nif_library_not_loaded)
  def check(_, _), do: exit(:nif_library_not_loaded)
end
