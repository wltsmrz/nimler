
ExUnit.start(trace: false, seed: 0)

defmodule NimlerTest do
    use ExUnit.Case, async: false

    setup_all do
        NimlerWrapper.load_nif()
    end

    describe "test_consume_timeslice" do
        test "timeslice iter" do
            res = NimlerWrapper.test_consume_timeslice(0, 0)
            assert(elem(res, 0) == :ok)
            assert(elem(res, 1) == 1000) # countup val
            assert(elem(res, 2) > 10) # invocations
        end
    end
end

