
# nimler

Erlang/elixir NIF bindings for nim. Motivating use case is bridging [control](https://en.wikipedia.org/wiki/Control_theory) libraries, often written in C/C++, to Elixir and [Nerves](https://nerves-project.org/).

**Status** Stage -1 experimental work

**Caution** NIFs can crash the Erlang VM

### Why nim

* Interop with C is simple
* Garbage collection can be disabled
* Nim is relatively pleasant and a tad safer to write, and fast

### Why not nim

* [rustler](https://github.com/rusterlium/rustler) should be a safer option if one prefers Rust


### Running tests

```
$ cd test/
$ ./run.sh
```

# TODO

* Impl enif resources
* Impl enif map iterator w/ nim iterators
* Impl enif consume_timeslice
* Attempt impl enif events
* Attempt impl enif select

