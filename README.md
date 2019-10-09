
# nimler

Erlang/elixir NIF bindings for nim. Motivating use case is bridging [control](https://en.wikipedia.org/wiki/Control_theory) libraries, often written in C/C++, to Elixir and [Nerves](https://nerves-project.org/).

STATUS: Stage -1 experimental work

CAUTION: NIFs can crash the Erlang VM

### Why nim

* Interop with C is simple
* Garbage collection can be disabled
* Nim is relatively pleasant and a tad safer to write, and fast

### Why not nim

* [rustler](https://github.com/rusterlium/rustler) should be a safer option if one prefers Rust


# Example

**nif.nim**

```nim
import nif_interface

proc add_int(env: ptr ErlNifEnv, argc: cint, argv: array[2, ErlNifTerm]): ErlNifTerm {.exportc.} =
  var v1, v2: cint

  if not enif_get_int(env, argv[0], addr(v1)):
    return enif_make_badarg(env)

  if not enif_get_int(env, argv[1], addr(v2)):
    return enif_make_badarg(env)

  return enif_make_int(env, v1 + v2)

{.emit: """
static ErlNifFunc funcs[] = {
  {"add_int", 2, add_int}
};

ERL_NIF_INIT(Elixir.NimNif, funcs, NULL, NULL, NULL, NULL)
""".}
```

**niftest.ex**

```elixir
defmodule NimNif do
    @on_load :load_nifs

    def load_nifs do
        :erlang.load_nif('./nif', 0)

        IO.inspect(add_int(1, 2), label: "add_int(1, 2)")
    end

    def add_int(_a, _b), do: raise "not implemented"
end
```

### Running example

```
$ nim c -f --gc:none -d:release --noMain --app:lib --cincludes:/usr/lib/erlang/usr/include  -o:nif.so nif.nim
$ iex ./nimtest.ex

> Erlang/OTP 22 [erts-10.5] [source] [64-bit] [smp:2:2] [ds:2:2:10] [async-threads:1] [hipe]
>
> add_int(1, 2): 3
```

# TODO

* Impl enif resources
* Impl enif map iterator w/ nim iterators
* Impl enif consume_timeslice
* Attempt impl enif events
* Attempt impl enif select






