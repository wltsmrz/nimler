defmodule NimlerDirtyNif do
  @on_load :init
  def init(), do: :erlang.load_nif(to_charlist(Path.join(Path.dirname(__ENV__.file), 'nif')), 0)

  def dirty_cpu(), do: exit(:nif_library_not_loaded)
  def dirty_io(), do: exit(:nif_library_not_loaded)
end
