
ExUnit.start(trace: false, seed: 0)

defmodule NimlerTest do
    use ExUnit.Case, async: false

    setup_all do
        NimlerWrapper.load_nif()
    end

    describe "dirty_nifs" do
        test "dirty CPU", do:
            assert(1 == NimlerWrapper.dirty_cpu())
        test "dirty IO", do:
            assert(1 == NimlerWrapper.dirty_io())
    end
end

