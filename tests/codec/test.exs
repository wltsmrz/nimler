
ExUnit.start(trace: false, seed: 0)

defmodule NimlerTest do
    use ExUnit.Case, async: false

    setup_all do
        NimlerWrapper.load_nif()
    end

    describe "codec_numbers" do
        test "codec_int32(max)", do:
            assert(2147483647 == NimlerWrapper.codec_int32(2147483646, 1))
        test "codec_int32(max+1)", do:
            assert(-2147483648 == NimlerWrapper.codec_int32(2147483647, 1))
        test "codec_int32(min)", do:
            assert(-2147483648 == NimlerWrapper.codec_int32(-2147483647, -1))
        test "codec_int32(min-1)", do:
            assert(2147483647 == NimlerWrapper.codec_int32(-2147483648, -1))
        test "codec_uint32(max)", do:
            assert(4294967295 == NimlerWrapper.codec_uint32(4294967294, 1))
        test "codec_uint32(max+1)", do:
            assert(0 == NimlerWrapper.codec_uint32(4294967295, 1))
    end

    describe "codec_atoms" do
        test "codec_atom()", do:
            assert(:test == NimlerWrapper.codec_atom(:test))
    end

    describe "codec_tuples" do
        test "codec_result()", do:
            assert({:ok, 1} == NimlerWrapper.codec_result_ok(1))
        test "codec_result_err()", do:
            assert({:error, 1} == NimlerWrapper.codec_result_error(1))
    end
end

