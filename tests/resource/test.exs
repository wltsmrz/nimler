
ExUnit.start(trace: false, seed: 0)

defmodule NimlerTest do
    use ExUnit.Case, async: false

    test "resource" do
        res = NimlerWrapper.create_resource()
        assert(is_reference(res))
        assert(is_reference(NimlerWrapper.update_resource(res)))
        assert(is_reference(NimlerWrapper.check_resource(res)))
    end
end
