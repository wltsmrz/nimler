
# Using resource objects

The use of resource objects is a safe way to return pointers to native data structures from a NIF. -- [https://erlang.org/doc/man/erl_nif.html](https://erlang.org/doc/man/erl_nif.html)

Nimler has boilerplate reduction for common resource objects usage pattern:

* On NIF load, open new resource type specific to the module. Store resource type in `priv_data`
* From this point NIFs can access resource type with `enif_priv_data()` for creating instances of resource

## Example

```nim tab="ResourceTest.nim"
import nimler
import nimler/codec
import nimler/resources

using
	env: ptr ErlNifEnv
	argc: cint
	argv: ErlNifArgs

type MyResource {.packed.} = object
	thing: int32

func new_res(env, argc, argv): ErlNifTerm {.nif(arity=0, name="new").} =
	let res = env.new_resource(MyResource)
	if res.isNone():
		return env.error(env.to_term("fail to allocate new resource"))
	res.get().thing = 0
	return env.ok(env.release_resource(res.get()))

func set_res(env, argc, argv): ErlNifTerm {.nif(arity=2, name="set").} =
	let resource = env.get_resource(argv[0], MyResource)
	let nval = env.from_term(argv[1], int32).get(-1)
	if resource.isNone():
		return env.error()
	let pval = resource.get().thing
	resource.get().thing = nval
	return env.ok(env.to_term(pval), argv[1])

func check_res(env, argc, argv): ErlNifTerm {.nif(arity=2, name="check").} =
	let resource = env.get_resource(argv[0], MyResource)
	let comp = env.from_term(argv[1], int32)
	let checked = resource.isSome() and comp.isSome() and resource.get().thing == comp.get()
	return if checked: env.ok() else: env.error()

resources.export_nifs("Elixir.ResourceTest", [
	new_res,
	set_res,
	check_res
])
```

```elixir tab="ResourceTest.exs"
defmodule ResourceTest do
	@on_load :load_nif
	def new(), do: raise "not implemented"
	def set(_a, _b), do: raise "not implemented"
	def check(_a, _b), do: raise "not implemented"
	def load_nif do
		:erlang.load_nif(to_charlist(Path.join(Path.dirname(__ENV__.file), "nif")), 0)

		{:ok, res} = new()
		assert(is_reference(res))
		assert({:ok} == check(res, 0))
		assert({:ok,0,123} == set(res, 123))
		assert({:ok} == check(res, 123))
		assert({:ok,123,124} == set(res, 124))
		assert({:error} == check(res, 125))
	end
end
```

!!! info "ResourceTest.nim"
    * `import nimler/resources` Although nimler/resources provides convenience for using resources, it is optional. There are tests for using resources [with](https://github.com/wltsmrz/nimler/tree/develop/tests/init_resource) and [without](https://github.com/wltsmrz/nimler/tree/develop/tests/resource) the additional functionality of nimler/resources.
    * `resources.export_nifs()` rather than `nimler.export_nifs()` to automatically add `load` and `unload` handlers
    * `env.new_resource(T): Option[ptr T]` allocate new resource of type
    * `env.release_resource(ptr T): term` create `ErlNifTerm` of the resource and pass ownership to BEAM
    * `env.get_resource(term, T): Option[ptr T]` get resource at term


