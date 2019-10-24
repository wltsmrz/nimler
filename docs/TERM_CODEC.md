# Encoding/decoding Erlang terms

Erlang terms are represented in nimler with the type `ErlNifTerm`. All Erlang types appear to NIFs as an opaque "term", which can be decoded into native types using the NIF getter functions. See [codec tests](https://github.com/wltsmrz/nimler/tree/master/tests/codec) for example usage.

See [docs/CODECS](CODECS.md) for available codec types.

See [docs/TERM_GETTERS](TERM_GETTERS.md) for the raw bindings to read terms.

See [docs/TERM_MAKERS](TERM_MAKERS.md) for the raw bindings to write terms.

# Encode

nimler exposes functions for encoding some basic types. Example:

```nim
let my_val = int32(10)
let term = encode(my_val, env)
# ErlNifTerm(10)
```

The following is equivalent thanks to [UFCS](https://en.wikipedia.org/wiki/Uniform_Function_Call_Syntax).

```nim
let my_val = int32(10)
let term = my_val.encode(env)
# ErlNifTerm(10)
```

### Atom types

nimler ErlAtom become Erlang atoms. They are represented as a 1-arity tuple of string. Nimler exports the following atoms for convenience:

* `AtomOk` ErlAtom((val: "ok"))
* `AtomErr` ErlAtom((val: "error"))
* `Atomtrue` ErlAtom((val: "true"))
* `AtomFalse` ErlAtom((val: "false"))

```nim
let my_atom = encode(ErlAtom((val: "test")), env)
# ErlNifTerm(:test)

let s = ErlAtom((val: "test"))
s.encode(env)
# ErlNifTerm(:test)
```

### String types

nimler ErlString become Erlang strings.

```nim
let my_str = encode(ErlString("test"), env)
# ErlNifTerm('test')

let s = ErlString("test")
s.encode(env)
# ErlNifTerm('test')
```

### Tuple types

nim arrays become Erlang tuples.

```nim
let my_tuple = encode([
    enif_make_int(env, 1),
    enif_make_int(env, 2),
    enif_make_int(env, 3)
], env)
# ErlNifTerm({1,2,3})
```

varargs are also tuples.

```nim
let my_tuple = encode(
    enif_make_int(env, 1),
    enif_make_int(env, 2),
    enif_make_int(env, 3),
    env
)
# ErlNifTerm({1,2,3})
```

### Result types

The `ErlResult` codec type represents a tuple of arity=2 whose first element is either an atom `:ok` or `:error`. nimler also exposes `ResultOk` and `ResultErr` functions for creating either.

```nim
let my_good_result = ResultOk(enif_make_int(env, 1)).encode(env)
# ErlNifTerm({:ok, 1})

let my_bad_result = ResultErr(enif_make_int(env, 1)).encode(env)
# ErlNifTerm({:error, 1})

let my_map = enif_make_new_map(env)
let k = enif_make_string(env, "a")
let v = enif_make_int(env, 1)
discard enif_make_map_put(env, my_map, k, v, unsafeAddr(my_map))

let my_result = ResultOk(my_map).encode(env)

# ErlNifTerm({:ok, %{"a": 1}})
```

Example proxying first argument within a result tuple

```nim
proc test_nif(env: ptr ErlNifEnv, argc: cint, argv: ErlNifArgs): ErlNifTerm =
  return ResultOk(argv[0]) # {:ok, <whatever>}
```

### List types

nim seq types become Erlang list.

```nim
let my_list = encode(@[
    enif_make_int(env, 1),
    enif_make_int(env, 2),
    enif_make_int(env, 1),
], env)
# ErlNifTerm([1,2,3])

let s = @[
    enif_make_int(env, 1),
    enif_make_int(env, 2),
    enif_make_int(env, 1)
]

s.encode(env)
# ErlNifTerm([1,2,3])
```

# Decode

Decoders return a nim [Option](https://nim-lang.org/docs/options.html) so default values can be easily expressed, or further logic made simpler, if decoding fails.

```nim
let my_val = decode(term, env, int32).get(0) # default=0

let my_other_val_option = decode(another_term, env, int32)

if my_other_val_option.isNone:
    # The term was not successfully decoded into an int32
    return do_something()

let my_val_2 = my_other_val_option.get() # get the decoded val without default

# strings
let str = term.decode(env, ErlString).get()
# str == "test"

# atoms
let atm = term.decode(env, ErlAtom).get()
# atm.val == "test"

# binaries
let bin = term.decode(env, ErlBinary).get()
# cast[ptr UncheckedArray[byte]](bin.data)
```

This NIF proxies the first argument back to the implementing module, if decoding into uint32 succeeds. Otherwise it sends an ErlNifTerm representing the value 0.

```nim
proc test_nif(env: ptr ErlNifEnv, argc: cint, argv: ErlNifArgs): ErlNifTerm =
  let a1 = argv[0].decode(env, uint32).get(0)
  return a1.encode(env)
```
