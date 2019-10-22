# Tests

All [tests](../tests) are written in integration-fashion with Elixir. They also serve as a reasonable implementation reference as all tests are also NIFs.

* [integration](../tests/integration) Tests all type-checkers (ex: `enif_is_atom()`), getters (ex: `enif_get_atom()`, and makers (ex: `enif_make_atom()`). This covers most of the raw bindings exported from nimler.
* [codec](../tests/codec) Tests added nimler convenience for encoding and decoding terms.
* [init_api](../tests/init_api) Tests `priv_data` storage (exposing data from the Erlang side when the NIF is loaded) and more complex NIF-export API.
* [resource](../tests/resource) Tests resource creation/update/release/allocation.
* [timeslice](../tests/timeslice) Tests using NIF rescheduling and use of `enif_consume_timeslice()`.
* [dirty_nif](../tests/dirty_nif) Tests dirty CPU and dirty IO NIF export.


