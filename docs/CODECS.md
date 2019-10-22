# Available types for codec functions

See [codec tests](https://github.com/wltsmrz/nimler/tree/master/tests/codec) for example usage and potentially more up to date list.

* `int32`
* `uint32`
* `ErlAtom` represented in nim as `tuple[val: string]`
* `ErlTuple` represented in nim as either `array` or `varargs`
* `ErlResult` **encode only** represented in nim as tuple of arity=2 {`AtomOk` , `ErlNifTerm`}
* `ErlString` represented in nim as `string`
* `ErlBinary` represented in nim as `ptr UncheckedArray[byte]`
* `ErlList` **encode only** represented in nim as `seq`


