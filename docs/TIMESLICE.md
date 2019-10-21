# Cooperating with Erlang scheduler

In general, NIFs should perform some unit of work quickly and return as soon as possible. The threshold for not-quick is around 1ms--although in reality this figure is dynamic. Erlang supports NIFs that take longer to execute--"dirty" NIFs--in a handful of ways. Two ways are supported in nimler.

See the [timeslice](../tests/timeslice) tests for example use of NIF rescheduling.

See the [dirty NIF](../tests/dirty_nif) tests for example use of dirty NIFs.

### Explicitly identifying NIFs as dirty

If a NIF identifies as dirty, Erlang will schedule it separately from normal NIFs. This is somewhat consequential, so [the documentation](http://erlang.org/doc/man/erl_nif.html) should be consulted. In nimler, dirty functions are passed as in the following example.

```nim
import nimler

proc dirty_cpu(env: ptr ErlNifEnv, argc: cint, argv: ErlNifArgs): ErlNifTerm =
  os.sleep(100)
  return enif_make_int(env, 1)

proc dirty_io(env: ptr ErlNifEnv, argc: cint, argv: ErlNifArgs): ErlNifTerm =
  os.sleep(100)
  return enif_make_int(env, 1)

export_nifs("Elixir.NimlerWrapper", NifOptions(
  name: "Elixir.NimlerWrapper",
  dirty_funcs: @[
    ("dirty_cpu", 0, dirty_cpu, ERL_NIF_DIRTY_CPU),
    ("dirty_io", 0, dirty_io, ERL_NIF_DIRTY_IO)
  ]
))
```

* `dirty_funcs` rather than `funcs`
* `ERL_NIF_DIRTY_CPU` / `ERL_NIF_DIRTY_IO` flags specify whether the function is CPU or IO bound. It's important to classify these right. Per documentation: If you should classify CPU bound jobs as I/O bound jobs, dirty I/O schedulers might starve ordinary schedulers

### Separating work into multiple NIF calls

If work can be reasonably iterated, NIFs can reschedule subsequent invocations if they consume too much time. The following function counts to 1000 in 1ms increments. It reschedules itself after it has consumed approximately 10% of a timeslice. In reality this NIF will invoke itself hundreds of times without the calling module's knowledge. This is the preferred way to handle potentially long-running NIF.

```nim
proc test_consume_timeslice(env: ptr ErlNifEnv, argc: cint, argv: ErlNifArgs): ErlNifTerm =
  var it, invocations: int32

  discard enif_get_int(env, argv[0], addr(it))
  discard enif_get_int(env, argv[1], addr(invocations))

  inc(invocations)

  while it < 1000:
    if enif_consume_timeslice(env, cint(10)):
      let fun_name = cstring("test_consume_timeslice")
      let flags = cint(0)
      let fptr = test_consume_timeslice
      let next_args = [ it.encode(env), invocations.encode(env) ]
      return enif_schedule_nif(env, fun_name, flags, fptr, next_args)
    os.sleep(1)
    inc(it)

  let result = encode(
    it.encode(env),
    invocations.encode(env),
    env
  )
  return ResultOk(result).encode(env) # {:ok, {1000, 932}}
```

* `enif_consume_timeslice(env, cint): bool` takes a % argument and returns true if the NIF has consumed this percent of the timeslice--a timeslice is roughly 1ms.
* `enif_schedule_nif()` is used to reschedule the NIF to be called later. This allows the Erlang scheduler to function as normal in the event that other work needs attention.


