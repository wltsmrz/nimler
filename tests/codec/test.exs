
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
        test "codec_double()", do:
            assert(1.7976931348623157e+308 == NimlerWrapper.codec_double(1.7976931348623157e+308))
        test "codec_uint64()", do:
            assert(0xFFFFFFFFFFFFFFFF == NimlerWrapper.codec_uint64(0xFFFFFFFFFFFFFFFF))
    end

    describe "codec_atoms" do
        test "codec_atom()", do:
            assert(:test == NimlerWrapper.codec_atom(:test))
    end

    describe "codec_strings" do
        test "codec_strings()", do:
            assert('test' == NimlerWrapper.codec_string('test'))
    end

    describe "codec_binary" do
        test "codec_binary()", do:
            assert(<<116, 101, 115, 116, 0>> == NimlerWrapper.codec_binary("test" <> <<0>>))
    end

    describe "codec_tuple" do
        test "codec_tuple()", do:
            assert({'test', 1, 1.2} == NimlerWrapper.codec_tuple({'test',1, 1.2}))
    end

    describe "codec_result" do
        test "codec_result()", do:
            assert({:ok, 1} == NimlerWrapper.codec_result_ok(1))
        test "codec_result_err()", do:
            assert({:error, 1} == NimlerWrapper.codec_result_error(1))
    end

    describe "codec_list" do
        test "codec_list()", do:
            assert([1,2,3] == NimlerWrapper.codec_list([1,2,3]))
    end

    describe "codec_fieldpairs" do
        test "codec_fieldpairs()", do:
            assert(%{:test => 1, :test_other => 2} == NimlerWrapper.codec_fieldpairs())
    end
end

