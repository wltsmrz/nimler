
ExUnit.start(trace: false, seed: 0)

defmodule NimlerTest do
    use ExUnit.Case, async: false

    setup_all do
        NimlerWrapper.load_nif()
    end

    describe "test_consume_timeslice" do
        test "timeslice iter" do
            {:ok,it,invocations} = NimlerWrapper.test_consume_timeslice(0, 0)
            assert(it == 1000) # countup val
            assert(invocations > 100) # invocations
        end
    end
end

