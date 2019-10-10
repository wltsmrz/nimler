# Automated test coverage:
# 
# Checkers
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
# [ ] get_uint64()
# [x] get_ulong()
# [ ] get_env()
#
# Constructors
# 
# [x] make_atom()
# [x] make_double()
# [x] make_int()
# [x] make_long()
# [x] make_int64()
# [x] make_list()
# [x] make_string()
# [ ] make_binary()
# [x] make_map()
# [x] make_tuple()
# [x] make_uint()
# [x] make_ulong()
# [x] make_map_put
# [x] make_map_remove
# [x] make_new_map
# [x] make_map_update

defmodule MySpecialError do
    defexception message: "Something special went wrong"

    def full_message(error) do
        "General failure: #{error.message}"
    end
end

defmodule NimNif do
    def load_nifs do
        :erlang.load_nif('./nif', 0)
        :timer.sleep(:timer.seconds(1))
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
    def make_atom(), do: "raise not implemented"
    def make_existing_atom(), do: "raise not implemented"
    def make_existing_atom_length(), do: "raise not implemented"
    def add_int(_a, _b), do: raise "not implemented"
    def add_double(_a, _b), do: raise "not implemented"
    def make_map_put(_a, _b, _c), do: raise "not implemented"
    def make_map_remove(_a, _b), do: raise "not implemented"
    def make_map_update(_a, _b, _c), do: raise "not implemented"
    def update_map(_a, _b, _c), do: raise "not implemented"

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
         IO.inspect(enif_is_pid_undefined(self()), label: "is_pid_undefined(1)")
        # IO.inspect(enif_is_port(:test), label: "is_port(1)")
        # IO.inspect(enif_is_port_alive(:test), label: "is_port(1)")
        IO.inspect(enif_is_process_alive(self()), label: "is_process_alive(self())")
        # IO.inspect(enif_is_ref(:test), label: "is_ref(1)")
        IO.inspect(enif_is_tuple({1, 2}), label: "is_tuple({1, 2})")
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
        # not working, reason unclear
        # IO.inspect(get_uint64(18446744073709551615), label: "get_uint64(18446744073709551615)")
        IO.inspect(get_double(123.4), label: "get_double(123.4)")
        IO.inspect(get_string('test'), label: "get_string('test')")

        IO.inspect(get_list_length([1, 2]), label: "get_list_length([1, 2])")
        IO.inspect(get_list_cell([1, 2, 3]), label: "get_list_cell([1, 2, 3])")
        IO.inspect(get_map_size(%{a: "test", b: "test2"}),
                label: "get_map_size(%{a: \"test\", b: \"test2\"})")
        IO.inspect(get_map_value(%{a: 1}, :a), label: "get_map_value(%{a: 1}, :a)")
        IO.inspect(
                make_map_put(%{}, "key", "value"),
                label: "make_map_put(%{}, \"key\", \"value\"")
        IO.inspect(make_map_update(%{a: 1}, :a, 2), label: "make_map_update(%{a: 1}, :a, 2)")
        IO.inspect(make_map_remove(%{a: 1}, :a), label: "make_map_remove(%{a: 1}, :a)")
    end

end


NimNif.load_nifs()
NimNif.test_check()
NimNif.test_get_and_make()
Process.exit(self(), :normal)
