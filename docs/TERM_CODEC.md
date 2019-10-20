# Encoding/decoding Erlang terms

Erlang terms are represented in nimler with the type `ErlNifTerm`. All types that appear in Erlang appear to NIFs as an opaque "term", which can be decoded into native types using the NIF getter functions. See [codec tests](https://github.com/wltsmrz/nimler/tree/master/tests/codec) for example usage.

### Available codecs

See [docs/CODECS](CODECS.md) for available codec types.

### nimler convenience encode/decode

**encoding**

nimler exposes convenience functions for encoding and decoding some basic types--more to come in the future. Example:

```nim
let my_val = int32(10)
let term = encode(my_val, env)
```

The following example also works for creating an ErlNifTerm:

```nim
let my_val = int32(10)
let term = my_val.encode(env)
```

**decoding**

Decoders return a nim `Option`(https://nim-lang.org/docs/options.html) so default values can be easily expressed, or further logic made simpler, if decoding fails.

```nim
let my_val = decode(term, env, int32).get(0)

let my_other_val_option = decode(another_term, env, int32)

if my_other_val_option.isNone:
    return doSomething()

let my_val_2 = my_other_val_option.get()
```

### Example of within a NIF

This NIF proxies the first argument back to the implementing module, if decoding into int32 succeeds. Otherwise it sends an ErlNifTerm representing the value 0.

```nim
proc add_numbers(env: ptr ErlNifEnv, argc: cint, argv: ErlNifArgs): ErlNifTerm =
  let a1 = argv[0].decode(env, uint32).get(0)
  return a1.encode(env)
```

### Result types

The `ErlResult` codec type represents a tuple of arity=2 whose first element is either an atom `:ok` or `:error`. nimler also exposes `ResultOk` and `ResultErr` functions for creating either.

```nim
proc ResultOk*(rval: ErlNifTerm): ErlResult = (AtomOk, rval)

proc ResultErr*(rval: ErlNifTerm): ErlResult = (AtomErr, rval)
```

Example:

```nim
proc add_numbers(env: ptr ErlNifEnv, argc: cint, argv: ErlNifArgs): ErlNifTerm =
  return ResultOk(argv[0])
```

Proxies the first argument as an `ErlResult` tuple such as `{:ok, 1}`.

### See also

See [docs/TERM_GETTERS](TERM_GETTERS.md) for reading terms the inconvenient way.

See [docs/TERM_MAKERS](TERM_MAKERS.md) for writing terms the inconvenient way.

