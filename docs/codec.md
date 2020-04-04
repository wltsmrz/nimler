# Encoding and decoding Erlang terms

nimler exposes a set of functions for encoding and decoding Erlang terms. Erlang terms are represented in nimler with the opaque type `ErlNifTerm`.

## Available types for codec functions

| Erlang  	| Elixir   	| nim                                     	| Encode 	| Decode 	|
|---------	|----------	|-----------------------------------------	|--------	|--------	|
| Integer 	| Integer  	| int, int32, int64, uint, uint32, uint64 	| ✓      	| ✓      	|
| Float   	| Float    	| float, float32, float64                 	| ✓      	| ✓      	|
| Atom    	| Atom     	| ErlAtom                                 	| ✓      	| ✓      	|
| String  	| Charlist 	| ErlCharlist                             	| ✓      	| ✓      	|
| Binary  	| String   	| string                                  	| ✓      	| ✓      	|
| Binary  	| Binary   	| ErlBinary                               	| ✓      	| ✓      	|
| List    	| List     	| seq                                     	| ✓      	| ✓      	|
| Tuple   	| Tuple    	| tuple                                   	| ✓      	| ✓      	|
| Map     	| Map      	| Table                                   	| ✓      	| ✓      	|

## Encoding

Encode nim type to `ErlNifTerm`

```nim
let i = 10
var encoded = val.encode(env)

encoded = 10'i32.encode(env)
# ErlNifTerm(10)
```

## Decoding

Decode `ErlNifTerm` to nim type.

```nim
let i_option = encoded.decode(env, int32)

if i_option.isNone():
  # The term was not successfully decoded into an int32
else:
  let i = i_option.get() # i == 10
```

!!! note
    Decoders return a nim [Option](https://nim-lang.org/docs/options.html).

## Atoms

```nim
let encoded = ErlAtom(val: "test").encode(env)
# :test

let decoded = encoded.decode(env, ErlAtom).get()
# ErlAtom(val: "test")
```

!!! note
    The following atom constants are exported from nimler. Note that these are not yet encoded into Erlang terms.

    * `AtomOk`: `ErlAtom(val: "ok")`
    * `AtomErr`: `ErlAtom(val: "error")`
    * `AtomTrue`: `ErlAtom(val: "true")`
    * `AtomFalse`: `ErlAtom(val: "false")`

## Strings

```nim
let encoded = "test".encode(env)
# 'test'

let decoded = encoded.decode(env, string).get()
# "test"
```

!!! note
    Strings are encoded to Erlang charlists

## Lists

```nim
let encoded = @[1,2,3].encode(env)
# [1,2,3]

let decoded = encoded.decode(env, seq[int]).get()
# @[1,2,3]
```

!!! note
    Erlang lists are decoded to nim `seq`. In nim, elements of `seq` must be of the same type.

## Tuples

```nim
let encoded = ("test",1,3.14).encode(env)
# {'test',1,3.14}

let decoded = encoded.decode(env, tuple[a: string, b: int, c: float]).get()
# ("test",1,3.14)
```

!!! note
    tuples in nim may contain mixed types.

## Maps

```nim
import tables

var t = initTable[string, int](4)

t["a"] = 1
t["b"] = 2

let encoded = t.encode(env)
# %{'a' => 1, 'b' => 2}

let decoded = encoded.decode(env, Table[string, int]).get()
# {"a": 1, "b": 2}
```

## Results

The `ErlResult` codec type represents a tuple of arity=2 whose first element is either an atom `:ok` or `:error`. nimler also exposes `ok()` and `error()` functions for creating terms from either.

```nim
let term = 1.encode(env)
let ok_term = term.ok(env)
# {:ok, 1}

let err_term = term.error(env)
# {:error, 2}
```

Example proxying first argument within a result tuple

```nim
proc test_nif(env: ptr ErlNifEnv, argc: cint, argv: ErlNifArgs): ErlNifTerm =
  argv[0].ok(env)
```

