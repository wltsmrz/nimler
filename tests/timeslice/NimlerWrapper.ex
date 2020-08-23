defmodule NimlerTimeslice do
  @on_load :init
  def init(), do: :erlang.load_nif(to_charlist(Path.join(Path.dirname(__ENV__.file), 'nif')), 0)

  def test_consume_timeslice(_, _), do: exit(:nif_library_not_loaded)
end
