# nimler

nim bindings for [Erlang NIF API](http://erlang.org/doc/man/erl_nif.html).  For example usage, see [example](example/) NIF and the [integration](https://github.com/wltsmrz/nimler/blob/master/tests/integration/nif.nim) tests with Elixir.

### Features

* Nearly complete binding of NIF API
* Decoding/encoding of basic Erlang terms
* Resource tracking allows references to nim objects from Erlang/Elixir
* Support for potentially long-running NIFs with `enif_consume_timeslice`

### Documentation

* [Creating a NIF](docs/CREATE_NIF.md)
* [Encoding and decoding NIF terms](docs/TERM_CODEC.md)
* [Creating resources to share between NIF calls](docs/RESOURCES.md)
* [Cooperating with Erlang scheduler](docs/TIMESLICE.md)
* [Glossary](docs/GLOSSARY.md)
* [Tests](docs/TESTS.md)

