
ExUnit.start(trace: false, seed: 0)

defmodule NimlerTest do
    use ExUnit.Case, async: false

    setup_all do
        NimlerWrapper.load_nif()
    end

    describe "codec" do
        test "codec_int()", do:
            assert(3 == NimlerWrapper.codec_int(1, 2))
        test "codec_uint()", do:
            assert(18446744073709551611 == NimlerWrapper.codec_uint(18446744073709551610, 1))
        test "codec_atom()", do:
            assert(:test == NimlerWrapper.codec_atom(:test))
    end
end

