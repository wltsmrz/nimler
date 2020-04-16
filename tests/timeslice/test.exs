
ExUnit.start(trace: false, seed: 0)

defmodule NimlerInitTimeslice.Test do
    use ExUnit.Case, async: false
    alias NimlerTimeslice, as: NimlerWrapper

    describe "test_consume_timeslice" do
        test "timeslice iter" do
            {:ok,it,invocations} = NimlerWrapper.test_consume_timeslice(0, 0)
            assert(it == 1000) # countup val
            assert(invocations == 1001) # invocations
        end
    end
end

