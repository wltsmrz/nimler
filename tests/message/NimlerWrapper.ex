defmodule NimlerMessage do
  @on_load :init

  def init(), do: :erlang.load_nif(to_charlist(Path.join(Path.dirname(__ENV__.file), 'nif')), 0)

  def send_message(_, _), do: exit(:nif_library_not_loaded)
  def send_message_caller(_), do: exit(:nif_library_not_loaded)
  
end
