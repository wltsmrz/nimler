
ExUnit.start(trace: false, seed: 0)

defmodule NimlerPositionalArgs.Test do
    use ExUnit.Case, async: false
    alias NimlerPositionalArgs, as: NimlerWrapper

    test "pos_int()", do:
        assert({:ok, 3} == NimlerWrapper.pos_int(1, 2))
    test "pos_int_badarg()", do:
        assert_raise(ArgumentError, fn -> NimlerWrapper.pos_int("a", 2) end)
        assert_raise(ArgumentError, fn -> NimlerWrapper.pos_int(1, :a) end)
    test "pos_bool()", do:
        assert({:ok, false, true} == NimlerWrapper.pos_bool(1, 2, false, true))
    test "pos_bool_badarg()", do:
        assert_raise(ArgumentError, fn -> NimlerWrapper.pos_bool(1, true, false, true) end)
    test "pos_bin()", do:
        assert({:ok, "testing"} == NimlerWrapper.pos_bin("test"))
        assert({:ok, "testing"} == NimlerWrapper.pos_bin(<<116, 101, 115, 116>>))
    test "pos_bin_badarg()", do:
        assert_raise(ArgumentError, fn -> NimlerWrapper.pos_bin(1) end)
        assert_raise(ArgumentError, fn -> NimlerWrapper.pos_bin(:test) end)
        assert_raise(ArgumentError, fn -> NimlerWrapper.pos_bin('test') end)
    test "pos_str()", do:
        assert({:ok, "testing"} == NimlerWrapper.pos_str("test"))
        assert({:ok, "testing"} == NimlerWrapper.pos_bin(<<116, 101, 115, 116>>))
    test "pos_str_badarg()", do:
        assert_raise(ArgumentError, fn -> NimlerWrapper.pos_str(:test) end)
        assert_raise(ArgumentError, fn -> NimlerWrapper.pos_bin('test') end)
    test "pos_charlist()", do:
        assert({:ok, 'testing'} == NimlerWrapper.pos_charlist('test'))
    test "pos_charlist_badarg()", do:
        assert_raise(ArgumentError, fn -> NimlerWrapper.pos_charlist(:test) end)
        assert_raise(ArgumentError, fn -> NimlerWrapper.pos_charlist("test") end)
    test "pos_seq()", do:
        assert({:ok, [1,2,3,4,5,6]} == NimlerWrapper.pos_seq([1,2,3]))
        assert({:ok, [4,5,6]} == NimlerWrapper.pos_seq([]))
    test "pos_seq_badarg()", do:
        assert_raise(ArgumentError, fn -> NimlerWrapper.pos_seq([1.0, 2, 3]) end)
        assert_raise(ArgumentError, fn -> NimlerWrapper.pos_seq(:test) end)
        assert_raise(ArgumentError, fn -> NimlerWrapper.pos_seq("test") end)
        assert_raise(ArgumentError, fn -> NimlerWrapper.pos_seq([:a, :b, :c]) end)
    test "pos_map()", do:
        assert({:ok, %{a1: 1, a2: 2, a3: 3, a4: 4}} == NimlerWrapper.pos_map(%{:a1 => 1, :a2 => 2, :a3 => 3}))
    test "pos_map_badarg()", do:
        assert_raise(ArgumentError, fn -> NimlerWrapper.pos_map(%{:a1 => 1.0}) end)
        assert_raise(ArgumentError, fn -> NimlerWrapper.pos_map(%{:a1 => :a2}) end)
        assert_raise(ArgumentError, fn -> NimlerWrapper.pos_map([]) end)
    test "pos_tup_map()", do:
        assert({:ok, %{:c => {"d", 5}}} == NimlerWrapper.pos_tup_map(%{:asdf => {"a", 1}}))
    test "pos_pid()" do
        mymsg = 123
        assert(:ok == NimlerWrapper.pos_pid(self(), mymsg))
        assert_received(mymsg)
    end
    test "pos_rename()", do:
        assert({:ok, 1} == NimlerWrapper.pos_ok?(1))
    test "pos_keywords()", do:
        assert(:ok == NimlerWrapper.pos_keywords([a: 1, b: "test", c: 3.1]))
    test "pos_keywords_badarg()", do:
        assert_raise(ArgumentError, fn -> NimlerWrapper.pos_keywords([a: 1]) end)
        assert_raise(ArgumentError, fn -> NimlerWrapper.pos_keywords([a: 1, b: "a"]) end)
        assert_raise(ArgumentError, fn -> NimlerWrapper.pos_keywords([a: 1, b: "a", c: :t]) end)
        assert_raise(ArgumentError, fn -> NimlerWrapper.pos_keywords(1) end)
    test "pos_result()", do:
        assert({:ok, 3} == NimlerWrapper.pos_result(1, 2))
    test "pos_result_badarg()", do:
        assert_raise(ArgumentError, fn -> NimlerWrapper.pos_result("a", 2) end)
        assert_raise(ArgumentError, fn -> NimlerWrapper.pos_result(1, :a) end)
end

