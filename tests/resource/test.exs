
ExUnit.start(trace: false, seed: 0)

defmodule NimlerTest do
    use ExUnit.Case, async: false

    setup_all do
        NimlerWrapper.load_nif()
    end

    test "resource" do
        res = NimlerWrapper.create_resource()
        assert(is_reference(res))
        assert(is_reference(NimlerWrapper.update_resource(res)))
        assert(is_reference(NimlerWrapper.check_resource(res)))
        assert(1 == NimlerWrapper.release_resource(res))
    end
end
