# Available types for codec functions

See [codec tests](https://github.com/wltsmrz/nimler/tree/master/tests/codec) for example usage and potentially more up to date list.

| Erlang/Elixir     | nim                                       | Encode    | Decode    |
|---------------    |-----------------------------------------  |--------   |--------   |
| Integer           | int, int32, int64, uint, uint32, uint64   | Y         | Y         |
| Float             | float                                     | Y         | Y         |
| Atom              | type ErlAtom = object<br>  val: string    | Y         | Y         |
| List              | seq                                       | Y         | Y         |
| Tuple             | tuple                                     | Y         | Y         |
| Charlist          | string                                    | Y         | Y         |
