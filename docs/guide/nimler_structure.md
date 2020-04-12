
Nimler is decomposed into modules that can be used independently.

| Name             | Description                                                                                                                                                                                                                  |
|------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| nimler           | Contains nim bindings for erl_nif.h and basic macros and pragmas, such as `export_nifs()` and the `.nif.` pragma. This is the only required import to use nimler                                                             |
| nimler/codec     | Contains `from_term()` and `to_term()` functions for converting between `ErlNifTerm` and nim types                                                                                                                           |
| nimler/resources | Contains simplifications for using resource objects. This module exports its own `export_nifs()` which adds load and unload handlers, and the functions `env.new_resource()`, `env.release_resource()`, `env.get_resource()` |


## Erlang/OTP versioning

Erlang/Elixir NIFs are shared libraries that depend on erl_nif.h. Nimler automatically detects installed Erlang/OTP, and tries to produce bindings that are compatible with the version detected.


