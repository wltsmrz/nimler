
defmodule NimlerWrapper do
    def load_nif, do: :erlang.load_nif(to_charlist(Path.join(Path.dirname(__ENV__.file), "nif")), 0)

    def create_resource(), do: raise "not implemented"
    def update_resource(_a), do: raise "not implemented"
    def check_resource(_a), do: raise "not implemented"
end
