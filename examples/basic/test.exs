
defmodule NumberAdderTest do
    @on_load :init

    def init() do
        IO.inspect(NumberAdder.add_numbers(1, 2), label: "1 + 2")
        IO.inspect(NumberAdder.sub_numbers(2, 1), label: "2 - 1")
        :ok
    end
end
