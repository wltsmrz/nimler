defmodule NimlerWrapper do
  @on_load :init
  def init(), do: :erlang.load_nif(to_charlist(Path.join(Path.dirname(__ENV__.file), 'nif')), 0)

  def create_resource(), do: exit(:nif_library_not_loaded)
  def update_resource(_), do: exit(:nif_library_not_loaded)
  def check_resource(_), do: exit(:nif_library_not_loaded)
end
