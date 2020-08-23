
ExUnit.start(trace: false, seed: 0)

defmodule NimlerPositionalArgs.Test do
    use ExUnit.Case, async: false
    alias NimlerPositionalArgs, as: NimlerWrapper

    describe "positional" do
        test "pos_int()", do:
            assert({:ok, 3} == NimlerWrapper.pos_int(1, 2))
        test "pos_bool()", do:
            assert({:ok, false, true} == NimlerWrapper.pos_bool(1, 2, false, true))
        test "pos_binary()", do:
            assert({:ok, "testing"} == NimlerWrapper.pos_bin("test"))
    end
end

