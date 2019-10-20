# Glossary

### ErlNifTerm

External representation of Erlang [data type](http://erlang.org/doc/reference_manual/data_types.html). All types that appear in Erlang appear to NIFs as an opaque `ErlNifTerm`, which can be decoded into native types using the NIF getter functions. Example:

```nim
var native_val: int
if enif_get_int(env, some_erlang_term, addr(native_val):
  # error getting int from term
  return 1
# native_val is now a native nim int type
```
Terms can be created from native types using the `enif_make_*` functions. Example:

```nim
let term = enif_make_int(env, 1)
```

Where `env` is a pointer to `ErlNifEnv`.

See [docs/TERM_GETTERS](TERM_GETTERS.md) for documentation on available getter functions.

See [docs/TERM_MAKERS](TERM_MAKERS.md) for documentation on available constructor functions.

### ErlNifEnv

All `ErlNifTerm` types belong to an `ErlNifEnv`. Most interactions with the NIF API involve an `ErlNifEnv` struct. From [documentation](http://erlang.org/doc/man/erl_nif.html):

```
All terms of type ERL_NIF_TERM belong to an environment of type ErlNifEnv. The lifetime of a term is controlled by the lifetime of its environment object. All API functions that read or write terms has the environment that the term belongs to as the first function argument.
```

### ErlNifArgs

An array of arguments to a NIF. Its type signature is: `UncheckedArray[ErlNifTerm]`. Example:

```nim
proc my_nif_func(env: ptr ErlNifEnv, argc: cint, argv: ErlNifArgs): ErlNifTerm =
    return argv[0]
```

As argv[0] is an ErlNifTerm it can be returned from NIF.


### NifSpec

A tuple containing required details to export a NIF. Its type signature is `tuple[name: string, arity: cint, fptr: proc (env: ptr ErlNifEnv; argc: cint; argv: ErlNifArgs): ErlNifTerm]`. Example:

```nim
export_nifs("Elixir.MyNif", [
    ("my_nif_function", 1, my_cool_nif)
])
```

Exports a NIF whose external name is "my_nif_function", arity is 1, and whose definition is the nim function my_cool_nif

### NifDirtySpec

Like `NifSpec` but includes a fourth element: flags: cint. This can be set to `ERL_NIF_DIRTY_CPU` or `ERL_NIF_DIRTY_IO` to inform Erlang that it should schedule this NIF in a manner such that it does not block work on normal schedulers. i.e. functions marked as dirty are likely to take more than 1ms to execute. Example:

```nim
export_nifs("Elixir.MyNif", [
    ("my_nif_function", 1, my_cool_nif, ERL_NIF_DIRTY_CPU)
])
```

