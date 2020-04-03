# nimler

Nimler is a library for authoring Erlang and Elixir NIFs in the nim programming language.

It has mostly complete [<ins>bindings</ins>](https://wltsmrz.github.io/nimler/bindings/) for Erlang [<ins>NIF API</ins>](http://erlang.org/doc/man/erl_nif.html), and functions for [<ins>encoding and decoding<ins>](https://wltsmrz.github.io/nimler/codec/) Erlang terms.

!!! question "Why write an Elixir NIF in nim?"
    + compiles to C, and has simple [FFI](https://nim-lang.org/docs/manual.html#foreign-function-interface)
    + tuneable garbage collection, and [automatic reference counting](https://forum.nim-lang.org/t/5734)
    + minimal, python-inspired aesthetic
