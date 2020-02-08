# Available types for codec functions

See [codec tests](https://github.com/wltsmrz/nimler/tree/master/tests/codec) for example usage and potentially more up to date list.

* `int`
* `float`
* `int32`
* `uint32`
* `uint64`
* `float64`
* `string`
* `ErlAtom` represented in nim as `tuple[val: string]`
* `ErlResult` **encode only** represented in nim as tuple of arity=2 {`ErlAtom` , `ErlNifTerm`}
* `ErlList` represented in nim as `seq[ErlNifTerm]`
* `ErlBinary` represented in nim using Erlang's ErlNifBinary struct. Use `enif_make_new_binary()` to make new binary type
* `fieldPairs(object)` object fieldpairs are encoded as map of atom => ErlNifTerm

