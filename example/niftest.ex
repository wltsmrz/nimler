
defmodule NimNif do
    @on_load :load_nifs

    def load_nifs do
        :erlang.load_nif('./nif', 0)

        IO.inspect(add_int(1, 2), label: "add_int(1, 2)")
        IO.inspect(add_double(1.1, 2.2), label: "add_double(1.1, 2.2)")
        IO.inspect(update_map(%{a: 1}), label: "update_map()")
    end

    def add_int(_a, _b), do: raise "not implemented"
    def add_double(_a, _b), do: raise "not implemented"
    def update_map(_a), do: raise "not implemented"
end

