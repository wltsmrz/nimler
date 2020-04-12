
Add two signed 32-bit ints.

```nim tab="NumberAdder.nim"
import nimler
import nimler/codec

using
  env: ptr ErlNifEnv
  argc: cint
  argv: ErlNifArgs

func add_numbers(env; argc; argv): ErlNifTerm {.nif(arity=2), raises: [].} =
  let a1 = env.from_term(argv[0], int32).get(0)
  let a2 = env.from_term(argv[1], int32).get(0)
  let r = a1 + a2
  return env.to_term(r)

export_nifs("Elixir.NumberAdder", [add_numbers])
```

```elixir tab="NumberAdder.exs"
defmodule NumberAdder do
  @on_load :load_nif

  def add_numbers(_a, _b), do: raise "not implemented"

  def load_nif, do: :erlang.load_nif('./nif', 0)
end
```

```bash tab="compile_and_run.sh"
nim c --app:lib --noMain --gc:arc -o:nif.so NumberAdder.nim

elixir NumberAdder.exs
```

!!! info "NumberAdder.nim"
		* `env: ptr ErlNifEnv` an untraced pointer to `ErlNifEnv` struct. This is used during most interactions with Erlang NIF API
		* `argc: cint` count of arguments
		* `argv: ErlNifArgs` array of arguments to the NIF. Each element in ErlNifArgs array is an `ErlNifTerm`
		* `export_nifs()` compile-time nim template that exports an `ErlNifEntry` to be loaded by Erlang or Elixir
		* `.get(0)` Nimler `from_term()` returns an [Option](https://nim-lang.org/docs/options.html). In this case if the term cannot be read as an int32, the default value is `0`
		* `{.nif(arity=2), raises: [].}` Nimler exports a `nif(arity=x, name=y)` macro pragma to transform function into a useable `ErlNifFunc`. The optional `raises: []` pragma is part of nim's [effect system](https://nim-lang.org/docs/manual.html#effect-system). It can be used to validate that the function does not raise an exception, which is particularly useful in the context of an Erlang NIF

!!! info "NumberAdder.exs"
		* `add_numbers(_a, _b)` Placeholder functions must exist when NIF is loaded. The arity of placeholder functions must also match the arity of functions exported from NIF
		* `'./nif'` path to shared library; in this case `nif.so`

