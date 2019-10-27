# Available types for codec functions

See [codec tests](https://github.com/wltsmrz/nimler/tree/master/tests/codec) for example usage and potentially more up to date list.

* `int`
* `float`
* `int32`
* `uint32`
* `uint64`
* `float64`
* `ErlAtom` represented in nim as `tuple[val: string]`
* `ErlTuple` **encode only** represented in nim as either `array` or `varargs`
* `ErlResult` **encode only** represented in nim as tuple of arity=2 {`AtomOk` , `ErlNifTerm`}
* `ErlString` represented in nim as `string`
* `ErlBinary` represented in nim using Erlang's ErlNifBinary struct. Use `enif_make_new_binary()` if necessary
* `ErlList` **encode only** represented in nim as `seq`
* `ErlTable` **encode only** represented in nim as `Table[ErlNifTerm, ErlNifTerm]`
* `fieldPairs(object)` object fieldpairs are encoded as map of atom => ErlNifTerm

