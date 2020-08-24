
ExUnit.start(trace: false, seed: 0)

defmodule NimlerPositionalArgs.Test do
    use ExUnit.Case, async: false
    alias NimlerPositionalArgs, as: NimlerWrapper

    test "pos_rename()", do:
        assert({:ok, 1} == NimlerWrapper.pos_ok?(1))
    test "pos_int()", do:
        assert({:ok, 3} == NimlerWrapper.pos_int(1, 2))
    test "pos_bool()", do:
        assert({:ok, false, true} == NimlerWrapper.pos_bool(1, 2, false, true))
    test "pos_bin()", do:
        assert({:ok, "testing"} == NimlerWrapper.pos_bin("test"))
    test "pos_str()", do:
        assert({:ok, "testing"} == NimlerWrapper.pos_str("test"))
    test "pos_charlist()", do:
        assert({:ok, 'testing'} == NimlerWrapper.pos_charlist('test'))
    test "pos_seq()", do:
        assert({:ok, [1,2,3,4,5,6]} == NimlerWrapper.pos_seq([1,2,3]))
    test "pos_map()", do:
        assert({:ok, %{a1: 1, a2: 2, a3: 3, a4: 4}} == NimlerWrapper.pos_map(%{:a1 => 1, :a2 => 2, :a3 => 3}))
    test "pos_tup_map()", do:
        assert({:ok, %{:c => {"d", 5}}} == NimlerWrapper.pos_tup_map(%{:asdf => {"a", 1}}))
    test "pos_pid()" do
      mymsg = 123
      assert(:ok == NimlerWrapper.pos_pid(self(), mymsg))
      receive do msg -> assert(msg == mymsg) end
    end
end

