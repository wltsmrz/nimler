# Erlang term getters

See [integration tests](https://github.com/wltsmrz/nimler/tree/master/tests/integration) for example usage.

Every function has the signature: `(env: ptr ErlNifEnv, t: ErlNifTerm): bool`. The return value indicates whether decoding term succeeded.

### Available getter functions

* `enif_get_atom`
* `enif_get_atom_length`
* `enif_get_string`
* `enif_get_int`
* `enif_get_uint`
* `enif_get_long`
* `enif_get_ulong`
* `enif_get_int64`
* `enif_get_uint64`
* `enif_get_double`
* `enif_get_tuple`
* `enif_get_list_length`
* `enif_get_list_cell`
* `enif_get_map_size`
* `enif_get_map_value`
* `enif_get_local_pid`


