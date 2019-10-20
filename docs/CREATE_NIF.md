# Creating a NIF

This example will create a NIF for adding two signed 32-bit integers. See [docs/GLOSSARY](GLOSSARY.md) for unknown terms.

### 1. Write NIF in nim

*nif.nim*
```nim
proc add_numbers(env: ptr ErlNifEnv, argc: cint, argv: ErlNifArgs): ErlNifTerm =
    let a1 = argv[0].decode(env, int32).get(0)
    let a2 = argv[1].decode(env, int32).get(0)
    let r = a1 + a2
    return r.encode(env)

export_nifs("Elixir.NumberAdder", @[
  ("add_numbers", 2, add_numbers)
])
```

* `env: ptr ErlNifEnv` is an untraced pointer to ErlNifEnv struct. This is used during most interactions with Erlang NIF API
* `argc: cint` count of arguments
* `argv: ErlNifArgs` unchecked array of arguments to the NIF. Each element in ErlNifArgs array is an `ErlNifTerm`
* `export_nifs()` is a compile-time nim template that accepts:
* `Elixir.NimlerWrapper` name of the destination module for export
* `[ ( "add_numbers", 2, add_numbers ) ]` is an openArray of NIF specs
* `"add_numbers"` is the name of the function to export. The corresponding Erlang/Elixir module must have a placeholder function matching this name
* `2` is the arity of the function
* `add_numbers` is a reference to the nim function that contains NIF signature
* `return r.encode(env)` the return value from NIFs must be an ErlNifTerm. In this case, an ErlNifTerm of int32

### 2. Compile shared library

Compile with `--app:lib` to produce `nif.so` shared library to be loaded in Erlang/Elixir.

### 3. Wrap library with Elixir module

*NumberAdder.ex*

```elxir
defmodule NumberAdder do
    @on_load :load_nif

    def load_nif, do: :erlang.load_nif('./nif', 0)

    def add_numbers(_a, _b), do: raise "not implemented"
end
```

Note:

* Placeholder functions (in this case `add_numbers(_a, _b)` must exist when NIF is loaded
* Placeholder arguments (_a, _b) must also exist, and must match the arity of the exported NIF from step 1 (in our case, arity=2)


