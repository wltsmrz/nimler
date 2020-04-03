
# Getting started

This example will create a NIF for Elixir to add two signed 32-bit ints.

## Setup

Install [<ins>nim</ins>](https://nim-lang.org/install.html) and [<ins>elixir</ins>](https://elixir-lang.org/install.html])

```bash
$ nim --version
# Nim Compiler Version 1.0.6 [Linux: amd64]

$ elixir --version
# Elixir 1.10.2 (compiled with Erlang/OTP 22)
```


Install nimler

```bash
$ nimble install nimler
```


## Write NIF in nim

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

!!! note
    * `env: ptr ErlNifEnv` an untraced pointer to `ErlNifEnv` struct. This is used during most interactions with Erlang NIF API
    * `argc: cint` count of arguments
    * `argv: ErlNifArgs` array of arguments to the NIF. Each element in ErlNifArgs array is an `ErlNifTerm`
    * `export_nifs()` compile-time nim template that exports an `ErlNifEntry` to be loaded by Elixir

## Compile NIF to shared library

```bash
nim c --app:lib --noMain -o:nif.so ./nif.nim
```

## Load NIF from Elixir

```elixir tab="NumberAdder.exs"

defmodule NumberAdder do
  @on_load :load_nif

  def add_numbers(_a, _b), do: raise "not implemented"

  def load_nif, do: :erlang.load_nif('./nif', 0)
end
```

!!! note
    * `add_numbers(_a, _b)` Placeholder functions must exist when NIF is loaded. The arity of placeholder functions must also match the arity of functions exported from NIF
    * `'./nif'` path to shared library; in this case `nif.so`


## More examples

nimler tests are also nifs. For more examples, see:

* [init API](https://github.com/wltsmrz/nimler/blob/develop/tests/init_api/nif.nim)
* [codec](https://github.com/wltsmrz/nimler/blob/develop/tests/codec/nif.nim)
* [erl_nif API coverage](https://github.com/wltsmrz/nimler/blob/develop/tests/integration/nif.nim)
* [dirty NIFs](https://github.com/wltsmrz/nimler/blob/develop/tests/dirty_nif/nif.nim)
* [consume_timeslice() test](https://github.com/wltsmrz/nimler/blob/develop/tests/timeslice/nif.nim)
