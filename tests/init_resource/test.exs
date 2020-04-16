
ExUnit.start(trace: false, seed: 0)

defmodule NimlerInitResource.Test do
    use ExUnit.Case, async: false
    alias NimlerInitResource, as: NimlerWrapper

    test "resource wrapper" do
        {:ok, res} = NimlerWrapper.new()
        assert(is_reference(res))
        assert({:ok} == NimlerWrapper.check(res, 0))
        assert({:ok,0,123} == NimlerWrapper.set(res, 123))
        assert({:ok} == NimlerWrapper.check(res, 123))
        assert({:ok,123,124} == NimlerWrapper.set(res, 124))
        assert({:error} == NimlerWrapper.check(res, 125))
    end
end
