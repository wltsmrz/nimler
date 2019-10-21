# Resources

From Erlang documentation: The use of resource objects is a safe way to return pointers to native data structures from a NIF. See the section on `Resource objects` of [Erlang NIF documentation](http://erlang.org/doc/man/erl_nif.html) for more information.

See [resource test](https://github.com/wltsmrz/nimler/tree/master/tests/resource) for example usage.

### Required functions from Erlang NIF API

The following functions are required to support resource tracking. Their use is documented below.

* `load` and `unload` NIF init functions, to create and free resource
* `enif_free`
* `enif_alloc`
* `enif_release_resource`
* `enif_open_resource_type`
* `enif_alloc_resource`
* `enif_get_resource`
* `enif_priv_data`

# Usage guide

### 1. Create private reference to resource type

First, memory should be allocated for private struct to contain a `resource_type` using `enif_alloc`. Then, a resource type is created with `enif_open_resource_type`. This should happen in the `load` callback to the NIF init (prior to any sort of interaction with the corresponding Erlang module). Load callback should always return 0 if success, otherwise return 1.

```nim
type MyResource = object
    data: int32

type MyResourcePriv = object
    resource_type: ptr ErlNifResourceType
    atom_ok: ErlNifTerm

proc on_unload(env: ptr ErlNifEnv, priv_data: pointer): void =
    enif_free(priv_data)

proc on_load(env: ptr ErlNifEnv, priv_data: ptr pointer, load_info: ErlNifTerm): cint =
    let priv = cast[ptr MyResourcePriv](enif_allof(sizeof(MyResourcePriv)))
    var flags_created: ErlNifResourceFlags
    priv[].resource_type = enif_open_resource_type(env, nil, cstring("MyResource"), nil, ERL_NIF_RT_CREATE, addr(flags_created))
    priv[].atom_ok = ErlAtom("ok").encode(env)
    priv_data[] = priv
    return 0

export_nifs("Elixir.NimlerWrapper", NifOptions(
    funcs: @[],
    load: on_load,
    unload: on_unload
))
```

* `MyResource` arbitrary resource struct
* `MyResourcePriv` container to stash `resource_type`
* `priv_data` is a special argument to the NIF `load` callback to be mutated
* `load_info` is not used here but is second argument to load_nif, passed from corresponding Erlang module
* `open_resource_type()` arguments specify the name of the resource, a destructor (if required--none in this case), and the flag to create resource (`ERL_NIF_RT_CREATE`).

### 2. Create resource term

Next step is to create a `resource` term using the `resource_type` that should already be stored in `priv_data` for module. Then, return the term so that the implementing module can pass it back to another NIF later.

```nim
proc create_resource(env: ptr ErlNifEnv, argc: int, argv: ErlNifArgs): ErlNifTerm =
    let priv = cast[ptr MyResourcePriv](enif_priv_data(env))
    let resource = cast[ptr MyResource](enif_alloc_resource(priv[].resource_type, sizeof(MyResource)))
    let resource_term = enif_make_resource(env, resource)
    enif_release_resource(resource)
    return resource_term
```

* `enif_priv_data()` accesses previously-stored data private to the NIF function
* `enif_alloc_resource()` creates memory for specified resource type and size, and returns pointer
* `enif_make_resource()` creates an Erlang term for resource
* `enif_release_resource()` releases the resource to Erlang to control its lifetime

### 3. Do something with it

Further NIF calls can receive resource term as any other term, as long as the `resource_type` is known.

```nim
proc modify_resource(env: ptr ErlNifEnv, argc: cint, argv: ErlNifArgs): ErlNifTerm =
    let priv = cast[ptr MyResourcePriv](enif_priv_data(env))
    var resource_ptr: ptr MyResource
    discard enif_get_resource(env, argv[0], priv[].resource_type, addr(resource_ptr))
    resource[].data = 1234
    return argv[0]
```
