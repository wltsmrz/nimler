# Test coverage
# 
# Type checkers
# 
# [x] is_atom()
# [x] is_binary()
# [x] is_current_process_alive()
# [x] is_empty_list()
# [ ] is_exception()
# [ ] is_fun()
# [x] is_identical()
# [x] is_list()
# [x] is_map()
# [x] is_number()
# [x] is_pid()
# [x] is_pid_undefined()
# [ ] is_port()
# [ ] is_port_alive()
# [x] is_process_alive()
# [ ] is_ref()
# [x] is_tuple()
# 
# Getters
# 
# [x] get_atom()
# [x] get_atom_length()
# [x] get_double()
# [x] get_int()
# [x] get_int64()
# [x] get_list_cell()
# [x] get_list_length()
# [ ] get_local_pid()
# [ ] get_local_port()
# [x] get_long()
# [x] get_map_size()
# [x] get_map_value()
# [ ] get_resource()
# [x] get_string()
# [ ] get_tuple()
# [x] get_uint()
# [x] get_uint64()
# [x] get_ulong()
# [ ] get_env()
#
# Constructors
# 
# [x] make_badarg()
# [x] make_atom()
# [x] make_existing_atom()
# [x] make_existing_atom_len()
# [x] make_double()
# [x] make_int()
# [x] make_long()
# [x] make_int64()
# [x] make_uint()
# [x] make_ulong()
# [x] make_uint64()
# [x] make_list()
# [x] make_list_cell()
# [x] make_list_from_array()
# [x] make_string()
# [x] make_string_len()
# [ ] make_binary()
# [x] make_new_binary()
# [x] make_tuple()
# [x] make_uint()
# [x] make_ulong()
# [x] make_new_map()
# [x] make_map_from_arrays()
# [x] make_map_put()
# [x] make_map_remove()
# [x] make_map_update()
# [x] make_copy()
# [x] make_pid()
# [x] make_ref()
# [x] make_resource()
# [x] make_reverse_list()
# [ ] make_sub_binary()
# [x] make_unique_integer()

# Resources
# [ ] make_resource_binary()

defmodule NimNif do

    def load_nifs do
        IO.inspect(:erlang.load_nif('./nif', 0))
    end

    def enif_is_atom(_a), do: raise "not implemented"
    def enif_is_binary(_a), do: raise "not implemented"
    def enif_is_current_process_alive(), do: raise "not implemented"
    def enif_is_empty_list(_a), do: raise "not implemented"
    def enif_is_exception(_a), do: raise "not implemented"
    def enif_is_fun(_a), do: raise "not implemented"
    def enif_is_identical(_a, _b), do: raise "not implemented"
    def enif_is_list(_a), do: raise "not implemented"
    def enif_is_map(_a), do: raise "not implemented"
    def enif_is_number(_a), do: raise "not implemented"
    def enif_is_pid(_a), do: raise "not implemented"
    def enif_is_pid_undefined(_a), do: raise "not implemented"
    def enif_is_port(_a), do: raise "not implemented"
    def enif_is_port_alive(_a), do: raise "not implemented"
    def enif_is_process_alive(_a), do: raise "not implemented"
    def enif_is_ref(_a), do: raise "not implemented"
    def enif_is_tuple(_a), do: raise "not implemented"

    def get_map_value(_a, _b), do: "raise not implemented"
    def get_map_size(_a), do: "raise not implemented"
    def get_list_length(_a), do: "raise not implemented"
    def get_list_cell(_a), do: "raise not implemented"
    def get_string(_a), do: "raise not implemented"
    def get_int(_a), do: "raise not implemented"
    def get_long(_a), do: "raise not implemented"
    def get_int64(_a), do: "raise not implemented"
    def get_uint(_a), do: "raise not implemented"
    def get_ulong(_a), do: "raise not implemented"
    def get_uint64(_a), do: "raise not implemented"
    def get_double(_a), do: "raise not implemented"
    def get_atom(_a), do: "raise not implemented"
    def get_atom_length(_a), do: "raise not implemented"

    def enif_make_atom(), do: "raise not implemented"
    def enif_make_existing_atom(), do: "raise not implemented"
    def enif_make_existing_atom_len(), do: "raise not implemented"
    def enif_make_int(), do: raise "not implemented"
    def enif_make_long(), do: raise "not implemented"
    def enif_make_int64(), do: raise "not implemented"
    def enif_make_uint(), do: raise "not implemented"
    def enif_make_ulong(), do: raise "not implemented"
    def enif_make_uint64(), do: raise "not implemented"
    def enif_make_double(), do: raise "not implemented"
    def enif_make_string(), do: raise "not implemented"
    def enif_make_string_len(), do: raise "not implemented"
    def enif_make_list(), do: raise "not implemented"
    def enif_make_list_cell(), do: raise "not implemented"
    def enif_make_list_from_array(), do: raise "not implemented"
    def enif_make_tuple(), do: raise "not implemented"
    def enif_make_new_binary(), do: raise "not implemented"
    def enif_make_new_map(), do: raise "not implemented"
    def enif_make_map_from_arrays(), do: raise "not implemented"
    def make_map_put(_a, _b, _c), do: raise "not implemented"
    def make_map_remove(_a, _b), do: raise "not implemented"
    def make_map_update(_a, _b, _c), do: raise "not implemented"

    def enif_make_copy(), do: raise "not implemented"
    def enif_make_pid(), do: raise "not implemented"
    def enif_make_ref(), do: raise "not implemented"
    def enif_make_reverse_list(), do: raise "not implemented"
    def enif_make_unique_integer(), do: "raise not implemented"

    def test_check do
         IO.inspect(enif_is_atom(:test), label: "is_atom(1)")
         IO.inspect(enif_is_binary("test"), label: "is_binary(\"test\")")
         IO.inspect(enif_is_current_process_alive(), label: "is_current_process_alive()")
         IO.inspect(enif_is_empty_list([]), label: "is_empty_list([])")
         # IO.inspect(enif_is_exception(MySpecialError), label: "is_exception(TestException)")
         # IO.inspect(enif_is_fun(fnref), label: "is_fun(fnref)")
         IO.inspect(enif_is_identical(:test, :test), label: "is_identical(1)")
         IO.inspect(enif_is_list([1]), label: "is_list([1])")
         IO.inspect(enif_is_map(%{a: 1}), label: "is_map(%{a:1})")
         IO.inspect(enif_is_number(1), label: "is_number(1)")
         IO.inspect(enif_is_pid(self()), label: "is_pid(self())")
         IO.inspect(enif_is_pid_undefined(self()), label: "is_pid_undefined(self())")
        # IO.inspect(enif_is_port(:test), label: "is_port(1)")
        # IO.inspect(enif_is_port_alive(:test), label: "is_port(1)")
        IO.inspect(enif_is_process_alive(self()), label: "is_process_alive(self())")
        # IO.inspect(enif_is_ref(:test), label: "is_ref(1)")
        IO.inspect(enif_is_tuple({1, 2}), label: "is_tuple({1, 2})")
    end

    def test_make() do
        IO.inspect(enif_make_atom(), label: "enif_make_atom()")
        IO.inspect(enif_make_existing_atom(), label: "enif_make_existing_atom()")
        IO.inspect(enif_make_existing_atom_len(), label: "enif_make_existing_atom_len()")
        IO.inspect(enif_make_tuple(), label: "enif_make_tuple()")
        IO.inspect(enif_make_int(), label: "enif_make_int()")
        IO.inspect(enif_make_long(), label: "enif_make_long()")
        IO.inspect(enif_make_int64(), label: "enif_make_int64()")
        IO.inspect(enif_make_uint(), label: "enif_make_uint()")
        IO.inspect(enif_make_ulong(), label: "enif_make_ulong()")
        IO.inspect(enif_make_uint64(), label: "enif_make_uint64()")
        IO.inspect(enif_make_double(), label: "enif_make_double()")
        IO.inspect(enif_make_string(), label: "enif_make_string()")
        IO.inspect(enif_make_string_len(), label: "enif_make_string_len()")
        IO.inspect(enif_make_list(), label: "enif_make_list()")
        IO.inspect(enif_make_list_cell(), label: "enif_make_list_cell()")
        IO.inspect(enif_make_list_from_array(), label: "enif_make_list_from_array()")
        IO.inspect(enif_make_reverse_list(), label: "enif_make_reverse_list()")
        IO.inspect(enif_make_new_binary(), label: "enif_make_new_binary())")
        IO.inspect(enif_make_map_from_arrays(), label: "enif_make_map_from_arrays()")
        IO.inspect(enif_make_new_map(), label: "enif_make_new_map())")
        IO.inspect(make_map_update(%{a: 1}, :a, 2), label: "make_map_update(%{a: 1}, :a, 2)")
        IO.inspect(make_map_put(%{}, "key", "value"),
                label: "make_map_put(%{}, \"key\", \"value\"")
        IO.inspect(make_map_remove(%{a: 1}, :a), label: "make_map_remove(%{a: 1}, :a)")
        IO.inspect(enif_make_copy(), label: "enif_make_copy()")
        IO.inspect(enif_make_pid(), label: "enif_make_pid()")
        IO.inspect(enif_make_ref(), label: "enif_make_ref()")
    end

    def test_get_and_make do
        IO.inspect(get_atom(:test), label: "get_atom(:test)")
        IO.inspect(get_int(123), label: "get_int(123)")
        IO.inspect(get_int(-123), label: "get_int(-123)")
        IO.inspect(get_long(2147483647), label: "get_long(2147483647)")
        IO.inspect(get_long(-2147483647), label: "get_long(-2147483647)")
        IO.inspect(get_int64(9223372036854775807), label: "get_int64(9223372036854775807)")
        IO.inspect(get_int64(-9223372036854775807), label: "get_int64(-9223372036854775807)")
        IO.inspect(get_uint(123), label: "get_uint(123)")
        IO.inspect(get_ulong(4294967295), label: "get_ulong(4294967295)")
        IO.inspect(get_uint64(18446744073709551615), label: "get_uint64(18446744073709551615)")
        IO.inspect(get_double(123.4), label: "get_double(123.4)")
        IO.inspect(get_string('test'), label: "get_string('test')")
        IO.inspect(get_list_length([1, 2]), label: "get_list_length([1, 2])")
        IO.inspect(get_list_cell([1, 2, 3]), label: "get_list_cell([1, 2, 3])")
        IO.inspect(get_map_size(%{a: "test", b: "test2"}),
                label: "get_map_size(%{a: \"test\", b: \"test2\"})")
        IO.inspect(get_map_value(%{a: 1}, :a), label: "get_map_value(%{a: 1}, :a)")
    end


end

NimNif.load_nifs()
# NimNif.test_check()
NimNif.test_make()
# NimNif.test_get_and_make()
Process.exit(self(), :normal)
