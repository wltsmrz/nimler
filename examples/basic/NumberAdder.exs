
defmodule NumberAdder do
    @on_load :load_nif

    def add_numbers(_a, _b), do: raise "not implemented"

    def load_nif do
        :erlang.load_nif(to_charlist(Path.join(Path.dirname(__ENV__.file), "nif")), 0)

        IO.inspect(add_numbers(1, 2), label: "1 + 2")

        :ok
    end
end
