
ExUnit.start(trace: false, seed: 0)

defmodule NimlerTest do
    use ExUnit.Case, async: false

    setup_all do
        NimlerWrapper.load_nif()
    end

    test "resource wrapper" do
        {:ok, res} = NimlerWrapper.new()
        assert(is_reference(res))
        assert({:ok} == NimlerWrapper.check(res, 0))
        assert({:ok,0,123} == NimlerWrapper.set(res, 123))
        assert({:ok} == NimlerWrapper.check(res, 123))
        assert({:error} == NimlerWrapper.check(res, 124))
    end
end
