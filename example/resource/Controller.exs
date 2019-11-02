
defmodule PIController do
    @on_load :load_nif

    def create_resource(_a, _b, _c, _d, _e, _f), do: raise "not implemented"
    def update_resource(_a, _b, _c), do: raise "not implemented"

    def load_nif do
        IO.inspect(:erlang.load_nif(to_charlist(Path.join(Path.dirname(__ENV__.file), "nif")), 0))
        ctrl = create_resource(100.0, -10.0, 10.0, 0.5, 0.25, 1.0)
        IO.inspect(update_resource(ctrl, 10.0, 1.0), label: 'PIControl update')
        IO.inspect(update_resource(ctrl, 10.0, 5.0), label: 'PIControl update')
        IO.inspect(update_resource(ctrl, 10.0, 8.0), label: 'PIControl update')
    end
end
