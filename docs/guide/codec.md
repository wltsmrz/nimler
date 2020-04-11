# Reading and writing Erlang terms

Erlang terms are represented in nimler with the opaque type `ErlNifTerm`. nimler exposes a set of functions for reading and writing to and from `ErlNifTerm`.

## Reading

Produce nim type from `ErlNifTerm`. `from_term()` returns an [Option](https://nim-lang.org/docs/options.html).

```nim
let i_option = env.from_term(term, int32)

if i_option.isNone():
  # The term was not successfully read into an int32
else:
  let i = i_option.get()

# Default value of 0 if term is not read successfully
let ii = env.from_term(term, int32).get(0)
```

## Writing

Produce `ErlNifTerm` from nim type

```nim
let term = env.to_term(10)
let other_term = env.to_term(10'i32)
```

## Supported Types

| Erlang  	| Elixir   	| nimler                                  	| Write  	| Read  	|
|---------	|----------	|-----------------------------------------	|--------	|--------	|
| Integer 	| Integer  	| int, int32, int64, uint, uint32, uint64 	| ✓      	| ✓      	|
| Float   	| Float    	| float, float32, float64                 	| ✓      	| ✓      	|
| Atom    	| Atom     	| ErlAtom                                 	| ✓      	| ✓      	|
| String  	| Charlist 	| ErlCharlist                             	| ✓      	| ✓      	|
| Bitstring | String   	| string                                  	| ✓      	| ✓      	|
| Binary  	| Binary   	| ErlBinary                               	| ✓      	| ✓      	|
| List    	| List     	| seq                                     	| ✓      	| ✓      	|
| Tuple   	| Tuple    	| tuple                                   	| ✓      	| ✓      	|
| Map     	| Map      	| Table                                   	| ✓      	| ✓      	|

### Atoms

```nim
let term = env.to_term(ErlAtom(val: "test"))
# :test

let atom = env.from_term(term, ErlAtom).get()
# ErlAtom(val: "test")
```

!!! note
    The following atom constants are exported from nimler. Note that these are not yet written to Erlang terms.

    * `AtomOk`: `ErlAtom(val: "ok")`
    * `AtomError`: `ErlAtom(val: "error")`
    * `AtomTrue`: `ErlAtom(val: "true")`
    * `AtomFalse`: `ErlAtom(val: "false")`

### Strings

```nim
let term = env.to_term("test")
# "test"

let str = env.from_term(term, string).get()
# "test"
```

!!! note
    Strings follow the Elixir pattern of using Erlang bitstring rather than charlists

### Lists

```nim
let term = env.to_term(@[1,2,3])
# [1,2,3]

let lst = env.from_term(term, seq[int]).get()
# @[1,2,3]
```

!!! note
    Elements of `seq` must be of the same type.

### Tuples

```nim
let term = env.to_term(("test",1,3.14))
# {"test",1,3.14}

let (a,b,c) = env.from_term(term, (string, int, float)).get()
# a="test"
# b=1
# c=3.14
```

!!! note
    Tuples in nim may contain mixed types.

### Maps

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

### Results

```nim
let ok_term = env.ok(env.to_term(1), env.to_term(2))
# {:ok, 1, 2, 3}

let err_term = env.error(env.to_term(1))
# {:error, 1}
```

