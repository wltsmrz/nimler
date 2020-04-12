
ExUnit.start(trace: false, seed: 0)

defmodule NimlerTest do
    use ExUnit.Case, async: false

    describe "init_nif" do
        test "test normal nif is properly exported", do:
            assert(1 == NimlerWrapper.test())
        test "test private data access", do:
            assert(1 == NimlerWrapper.test_priv())
        test "test dirty nif is properly exported", do:
            assert(1 == NimlerWrapper.test_dirty())
    end
end

