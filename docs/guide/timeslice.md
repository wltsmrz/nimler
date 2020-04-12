
# Cooperating with Erlang schedulers

NIFs should return as soon as possible. The threshold for not-quick is around 1ms--although in reality this figure is dynamic.

Erlang supports long-running NIFs in multiple ways.

## Identifying NIFs as dirty

If a NIF identifies as dirty, Erlang will schedule it separately from normal NIFs. In nimler, dirty functions are specified as in the following example:

```nim
import os
import nimler
import nimler/codec

using
	env: ptr ErlNifEnv
	argc: cint
	argv: ErlNifArgs

proc fib(n: uint64): uint64 =
  if n > 2.uint64:
    return fib(n - 1) + fib(n - 2)
  return n

proc dirty_cpu(env; argc; argv): ErlNifTerm =
  discard fib(40)
  return env.to_term(AtomOk)

proc dirty_io(env, argc; argv): ErlNifTerm =
	os.sleep(1000)
	return env.to_term(AtomOk)

export_nifs("Elixir.NimlerWrapper", [
	toNif("dirty_cpu", 0, dirty_cpu, ERL_NIF_DIRTY_CPU),
	toNif("dirty_io", 0, dirty_io, ERL_NIF_DIRTY_IO)
))
```

!!! note
    * `ERL_NIF_DIRTY_CPU` and `ERL_NIF_DIRTY_IO` flags specify whether the function is CPU or IO bound. It's important to classify these right. Per documentation: If you should classify CPU bound jobs as I/O bound jobs, dirty I/O schedulers might starve ordinary schedulers

## Separating work into multiple NIF calls

NIFs can schedule subsequent invocations on the basis of consumed-time. The following function counts to 1000 in 1ms increments. It reschedules itself after it has consumed 100% of a timeslice. The function `test_consume_timeslice` is invoked 1001 times while yielding to the Erlang scheduler.

This is the preferred way to support long-running NIFs.

```nim
import os
import nimler
import nimler/codec

using
	env: ptr ErlNifEnv
	argc: cint
	argv: ErlNifArgs

proc test_consume_timeslice(env; argc; argv): ErlNifTerm {.nif: 2.} =
	var it = env.from_term(argv[0], int).get(0)
	var invocations = env.from_term(argv[1], int).get(0)
	inc(invocations)

	while it < 1000:
		os.sleep(1)
		inc(it)
		if enif_consume_timeslice(env, cint(100)):
			let next_args = [ env.to_term(it), env.to_term(invocations) ]
			return enif_schedule_nif(env, test_consume_timeslice, next_args)

	return env.ok(env.to_term(it), env.to_term(invocations))

export_nifs("Elixir.NimlerWrapper", [test_consume_timeslice])
```

!!! note
    * `enif_consume_timeslice(env, cint): bool` takes a % argument and returns true if the NIF has consumed this percent of the timeslice--a timeslice is roughly 1ms.
    * `enif_schedule_nif()` is used to reschedule the NIF to be called later. This allows the Erlang scheduler to function as normal in the event that other work needs attention.

