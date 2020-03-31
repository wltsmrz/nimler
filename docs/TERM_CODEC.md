# Encoding/decoding Erlang terms

nimler exposes a set of convenience functions for encoding and decoding Erlang terms. Erlang terms are represented in nimler with the type `ErlNifTerm`. All Erlang types appear to NIFs as an opaque "term", which can be decoded into native types using the NIF getter functions. See [codec tests](https://github.com/wltsmrz/nimler/tree/master/tests/codec) for example usage.

See [docs/CODECS](CODECS.md) for available codec types.

See [docs/TERM_GETTERS](TERM_GETTERS.md) for the raw bindings to read terms.

See [docs/TERM_MAKERS](TERM_MAKERS.md) for the raw bindings to write terms.

# Encode

```nim
let my_val = 10
let term = encode(my_val, env)
# ErlNifTerm(10)
```

The following is equivalent thanks to [UFCS](https://en.wikipedia.org/wiki/Uniform_Function_Call_Syntax).

```nim
let my_val = 10
let term = my_val.encode(env)
# ErlNifTerm(10)

let my_val = 10'i32.encode(env)
# ErlNifTerm(10)
```

### Atom types

* `AtomOk`: `ErlAtom(val: "ok")`
* `AtomErr`: `ErlAtom(val: "error")`
* `Atomtrue`: `ErlAtom(val: "true")`
* `AtomFalse`: `ErlAtom(val: "false")`

```nim
let my_atom = encode(ErlAtom(val: "test"), env)
# ErlNifTerm(:test)

let s = ErlAtom(val: "test")
s.encode(env)
# ErlNifTerm(:test)
```

### String types

```nim
let my_str = encode("test", env)
# ErlNifTerm('test')

let s = "test"
s.encode(env)
# ErlNifTerm('test')

"test".encode(env)
# ErlNifTerm('test')
```

### List types

```nim
let l = @[
    1'i32.encode(env),
    2'i32.encode(env),
    3'i32.encode(env)
]

l.encode(env)
# ErlNifTerm([1,2,3])
```

### Tuple types

**Encode**

```nim
let t = ("test", 1, 3.14)

t.encode(env)

# ErlNifTerm([1,2,3])
```

**Decode**

```nim

term.decode(env, tuple[a: string, b: int, c: float]).get()
# ("test", 1, 3.14)
```

### Object field pairs

nim object fieldpairs become special form of Erlang map where keys are always atom. Erlang error is thrown if encoding fails. The implication of this is that the NIF will always return an Erlang error, no matter what is ostensibly returned, after this point.

```nim
type MyObject = object
    test: int
    test_other: int

var obj = MyObject(test: 1, test_other: 2)
obj.encode(env)
# {:test => 1, :test_other => 2}
```

### Result types

The `ErlResult` codec type represents a tuple of arity=2 whose first element is either an atom `:ok` or `:error`. nimler also exposes `ResultOk` and `ResultErr` functions for creating either.

```nim
let my_good_result = ResultOk(1.encode(env)).encode(env)

let my_good_result = ResultOk(1.encode(env)).encode(env)
# ErlNifTerm({:ok, 1})

let my_bad_result = ResultErr(1.encode(env)).encode(env)
# ErlNifTerm({:error, 1})

type MyThing = object
    prop: int

let thing = MyThing(prop: 1)
let res = ResultOk(thing.encode(env)).encode(env)

# ErlNifTerm({:ok, %{ :prop => 1 } })
```

Example proxying first argument within a result tuple

```nim
proc test_nif(env: ptr ErlNifEnv, argc: cint, argv: ErlNifArgs): ErlNifTerm =
  return ResultOk(argv[0]).encode(env) # {:ok, <whatever>}
```

# Decode

Decoders return a nim [Option](https://nim-lang.org/docs/options.html) so default values can be easily expressed, or further logic made simpler, if decoding fails.

```nim
let my_val = term.decode(env, int32)

if isNone(my_val):
    # The term was not successfully decoded into an int32
    return do_something()

let v = my_val.get()
# v == 10

# strings
let str = term.decode(env, string).get()
# str == "test"

# atoms
let atm = term.decode(env, ErlAtom).get()
# atm.val == "test"

# binaries
let bin = term.decode(env, ErlBinary).get()
cast[ptr UncheckedArray[char]](bin.data)
```

This NIF proxies the first argument back to the implementing module, if decoding into uint32 succeeds. Otherwise it sends an ErlNifTerm representing the value 0.

```nim
proc test_nif(env: ptr ErlNifEnv, argc: cint, argv: ErlNifArgs): ErlNifTerm =
  let a1 = argv[0].decode(env, uint32).get(0)
  return a1.encode(env)
```
