defmodule NimlerInitApi do
  @on_load :init
  def init(), do: :erlang.load_nif(to_charlist(Path.join(Path.dirname(__ENV__.file), 'nif')), 123)

  def test(), do: exit(:nif_library_not_loaded)
  def test_priv(), do: exit(:nif_library_not_loaded)
  def test_dirty(), do: exit(:nif_library_not_loaded)
end
