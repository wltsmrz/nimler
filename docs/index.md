# nimler

Nimler is a library for authoring Erlang and Elixir NIFs in the [nim](https://nim-lang.org/) programming language.

It has mostly complete bindings for [Erlang NIF API](http://erlang.org/doc/man/erl_nif.html), and various codec functions to make writing NIFs easier.

!!! question "Why write an Elixir NIF in nim?"
    + tuneable garbage collection. It can be disabled entirely. It also has [automatic reference counting](https://forum.nim-lang.org/t/5734)
    + compiles to C, and has simple [FFI](https://nim-lang.org/docs/manual.html#foreign-function-interface)
    + minimal, python-inspired aesthetic

## Installation

```
$ nimble install nimler
```

## Usage

```nim tab="nif.nim"
import nimler

proc add_numbers(env: ptr ErlNifEnv, argc: cint, argv: ErlNifArgs): ErlNifTerm =
  let a1 = argv[0].decode(env, int32).get(0)
  let a2 = argv[1].decode(env, int32).get(0)
  let r = a1 + a2
  return r.encode(env)

export_nifs("Elixir.NumberAdder", @[
  ("add_numbers", 2, add_numbers)
])
```

```elixir tab="NumberAdder.exs"
defmodule NumberAdder do
  @on_load :load_nif

  def add_numbers(_a, _b), do: raise "not implemented"

  def load_nif, do
    :erlang.load_nif(to_charlist(Path.join(Path.dirname(__ENV__.file), "nif")), 0)
    IO.inspect(add_numbers(1, 2))
  end
end
```

```bash tab="run.sh"
# compile shared library
nim c --app:lib --noMain --gc:arc -o:nif.so ./nif.nim

# run elixir wrapper module
elixir ./NumberAdder.exs
```

