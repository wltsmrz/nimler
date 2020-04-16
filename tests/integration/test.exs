
ExUnit.start(trace: false, seed: 0)

defmodule NimlerIntegration.Test do
    use ExUnit.Case, async: false
    alias NimlerIntegration, as: NimlerWrapper

    describe "type_checkers" do
        test "is_atom(:test)", do:
            assert(1 == NimlerWrapper.enif_is_atom(:test))
        test "is_atom(1)", do:
            assert(0 == NimlerWrapper.enif_is_atom(1))
        test "is_binary(\"test\")", do:
            assert(1 == NimlerWrapper.enif_is_binary("test"))
        test "is_binary(1)", do:
            assert(0 == NimlerWrapper.enif_is_binary(1))
        test "is_current_process_alive()", do:
            assert(1 == NimlerWrapper.enif_is_current_process_alive())
        test "is_empty_list([])", do:
            assert(1 == NimlerWrapper.enif_is_empty_list([]))
        test "is_empty_list([1])", do:
            assert(0 == NimlerWrapper.enif_is_empty_list([1]))
        test "is_identical(:test, :test)", do:
            assert(1 == NimlerWrapper.enif_is_identical(:test, :test))
        test "is_identical(:test, :testx)", do:
            assert(0 == NimlerWrapper.enif_is_identical(:test, :testx))
        test "is_list([1])", do:
            assert(1 == NimlerWrapper.enif_is_list([1]))
        test "is_list(1)", do:
            assert(0 == NimlerWrapper.enif_is_list(1))
        test "is_map(%{a: 1})", do:
            assert(1 == NimlerWrapper.enif_is_map(%{a: 1}))
        test "is_map(1)", do:
            assert(0 == NimlerWrapper.enif_is_map(1))
        test "is_number(1)", do:
            assert(1 == NimlerWrapper.enif_is_number(1))
        test "is_number([])", do:
            assert(0 == NimlerWrapper.enif_is_number([]))
        test "is_pid(self())", do:
            assert(1 == NimlerWrapper.enif_is_pid(self()))
        test "is_pid(1))", do:
            assert(0 == NimlerWrapper.enif_is_pid(1))
        test "is_pid_undefined(self())", do:
            assert(0 == NimlerWrapper.enif_is_pid_undefined(self()))
#         @tag :skip
#         test "is_port()", do:
#             assert(1 == NimlerWrapper.enif_is_port(:test))
#         @tag :skip
#         test "is_port_alive()", do:
#             assert(1 == NimlerWrapper.enif_is_port_alive(:test))
        test "is_process_alive()", do:
            assert(1 == NimlerWrapper.enif_is_process_alive(self()))
        test "is_tuple({1, 2})", do:
            assert(1 == NimlerWrapper.enif_is_tuple({1, 2}))
        @tag :skip
        test "is_ref()", do:
            assert(1 == NimlerWrapper.enif_is_ref(:test))
        @tag :skip
        test "is_exception()", do:
            assert(1 == NimlerWrapper.enif_is_exception(1))
        @tag :skip
        test "is_fun(fn)", do:
            assert(1 == NimlerWrapper.enif_is_ref(&round/1))
    end # term_type_checkers

    describe "constructors" do
        test "make_atom()", do:
            assert(:test == NimlerWrapper.enif_make_atom())
        test "make_existing_atom()", do:
            assert(:test == NimlerWrapper.enif_make_existing_atom())
        test "make_existing_atom_en()", do:
            assert(:test == NimlerWrapper.enif_make_existing_atom_len())
        test "make_tuple()", do:
            assert({1,2,3} == NimlerWrapper.enif_make_tuple())
        test "make_tuple_from_array()", do:
            assert({1,2,3} == NimlerWrapper.enif_make_tuple())
        test "make_int()", do:
            assert(1 == NimlerWrapper.enif_make_int())
        test "make_long()", do:
            assert(1 == NimlerWrapper.enif_make_long())
        test "make_int64()", do:
            assert(1 == NimlerWrapper.enif_make_int64())
        test "make_uint()", do:
            assert(1 == NimlerWrapper.enif_make_uint())
        test "make_ulong()", do:
            assert(1 == NimlerWrapper.enif_make_ulong())
        test "make_uint64()", do:
            assert(1 == NimlerWrapper.enif_make_uint64())
        test "make_double()", do:
            assert(1.1 == NimlerWrapper.enif_make_double())
        test "make_string()", do:
            assert('test' == NimlerWrapper.enif_make_string())
        test "make_string_len()", do:
            assert('test' == NimlerWrapper.enif_make_string_len())
        test "make_list()", do:
            assert([1,2,3] == NimlerWrapper.enif_make_list())
        test "make_list_cell()", do:
            assert([1|2] == NimlerWrapper.enif_make_list_cell())
        test "make_list_from_aray()", do:
            assert([1,2] == NimlerWrapper.enif_make_list_from_array())
        test "make_reverse_list()", do:
            assert([3,2,1] == NimlerWrapper.enif_make_reverse_list())
        test "make_new_binary()", do:
            assert("test" == NimlerWrapper.enif_make_new_binary())
        test "make_map_from_arrays()", do:
            assert(%{a: 1, b: 2} == NimlerWrapper.enif_make_map_from_arrays())
        test "make_new_map()", do:
            assert(%{} == NimlerWrapper.enif_make_new_map())
        test "make_map_update()", do:
            assert(%{a: 2} == NimlerWrapper.enif_make_map_update(%{a: 1}, :a, 2))
        test "make_map_put()", do:
            assert(%{a: 1} == NimlerWrapper.enif_make_map_put(%{}, :a, 1))
        test "make_map_remove()", do:
            assert(%{} == NimlerWrapper.enif_make_map_remove(%{a: 1}, :a))
        test "make_copy()", do:
            assert(1 == NimlerWrapper.enif_make_copy())
        @tag :skip
        test "make_pid()", do:
            assert(:erlang.is_pid(NimlerWrapper.enif_make_pid()))
        test "make_ref()", do:
            assert(:erlang.is_reference(NimlerWrapper.enif_make_ref()))
    end

    describe "getters" do
        test "get_atom()", do:
            assert(:test == NimlerWrapper.enif_get_atom(:test))
        test "get_atom_length()", do:
            assert(4 == NimlerWrapper.enif_get_atom_length(:test))
        test "get_local_pid()", do:
            assert(self() == NimlerWrapper.enif_get_local_pid(self()))
        test "get_int()", do:
            assert(123 == NimlerWrapper.enif_get_int(123))
        test "get_long()", do:
            assert(2147483647 == NimlerWrapper.enif_get_long(2147483647))
        test "get_int64()", do:
            assert(9223372036854775807 == NimlerWrapper.enif_get_int64(9223372036854775807))
        test "get_uint()", do:
            assert(123 == NimlerWrapper.enif_get_uint(123))
        test "get_ulong()", do:
            assert(4294967295 == NimlerWrapper.enif_get_ulong(4294967295))
        test "get_uint64()", do:
            assert(18446744073709551615 == NimlerWrapper.enif_get_uint64(18446744073709551615))
        test "get_double()", do:
            assert(123.4 == NimlerWrapper.enif_get_double(123.4))
        test "get_string()", do:
            assert('test' == NimlerWrapper.enif_get_string('test'))
        test "get_tuple()", do:
            assert({1,2} == NimlerWrapper.enif_get_tuple({1,2}))
        test "get_list_length()", do:
            assert(2 == NimlerWrapper.enif_get_list_length([1, 2]))
        test "get_list_cell()", do:
             assert([2,3] == NimlerWrapper.enif_get_list_cell([1, 2, 3]))
         test "get_map_size()", do:
            assert(2 == NimlerWrapper.enif_get_map_size(%{a: "test", b: "test2"}))
       test "get_map_value()", do:
           assert(1 == NimlerWrapper.enif_get_map_value(%{a: 1}, :a))
    end

    describe "compare" do
        test "enif_compare(<)", do:
            assert(-1 == NimlerWrapper.enif_compare(1, 2))
        test "enif_compare(>)", do:
            assert(1 == NimlerWrapper.enif_compare(2, 1))
        test "enif_compare(=)", do:
            assert(0 == NimlerWrapper.enif_compare(2, 2))
        test "enif_compare(char)", do:
            assert(1 == NimlerWrapper.enif_compare('x', 'b'))
    end

    describe "term_type" do
        test "term_type()", do:
            NimlerWrapper.enif_term_type( 1, 'test', {1}, "test", %{}, self())
    end

    describe "system_info" do
        test "system_info()", do:
            NimlerWrapper.enif_system_info()
    end

    describe "snprintf" do
        test "snprintf()", do:
            NimlerWrapper.enif_snprintf('test')
    end

    describe "raise_exception" do
        test "raise_exception()", do:
            assert_raise(ErlangError, ~s(Erlang error: "test"), fn -> NimlerWrapper.enif_raise_exception("test") end)
    end

end

