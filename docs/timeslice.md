
# Cooperating with Erlang scheduler

NIFs should return as soon as possible. The threshold for not-quick is around 1ms--although in reality this figure is dynamic. Erlang supports NIFs that take longer to execute--"dirty" NIFs--in multiple ways.

## Identifying NIFs as dirty

If a NIF identifies as dirty, Erlang will schedule it separately from normal NIFs. In nimler, dirty functions are specified as in the following example:

```nim
import nimler
import os

proc dirty_cpu(env: ptr ErlNifEnv, argc: cint, argv: ErlNifArgs): ErlNifTerm =
  for i in 0 ..< 1000:
    # do something hard

  return AtomOk.encode(env)

proc dirty_io(env: ptr ErlNifEnv, argc: cint, argv: ErlNifArgs): ErlNifTerm =
  os.sleep(1000)

  return AtomOk.encode(env)

export_nifs("Elixir.NimlerWrapper", @[
    ("dirty_cpu", 0, dirty_cpu, ERL_NIF_DIRTY_CPU), # dirty CPU flag
    ("dirty_io", 0, dirty_io, ERL_NIF_DIRTY_IO) # dirty IO flag
  ]
))
```

!!! note
    * `ERL_NIF_DIRTY_CPU` and `ERL_NIF_DIRTY_IO` flags specify whether the function is CPU or IO bound. It's important to classify these right. Per documentation: If you should classify CPU bound jobs as I/O bound jobs, dirty I/O schedulers might starve ordinary schedulers

## Separating work into multiple NIF calls

NIFs can schedule subsequent invocations on the basis of consumed-time. The following function counts to 1000 in 1ms increments. It reschedules itself after it has consumed approximately 10% of a timeslice. 

```nim
proc test_consume_timeslice(env: ptr ErlNifEnv, argc: cint, argv: ErlNifArgs): ErlNifTerm =
  var i = argv[0].decode(env, int32).get(0)
  var schedule_count = argv[1].decode(env, int32).get(0)

  inc(schedule_count)

  while i < 1000:
    if enif_consume_timeslice(env, cint(10)):
      return enif_schedule_nif(env, test_consume_timeslice, [
        i.encode(env),
        schedule_count.encode(env)
      ])

    os.sleep(1)
    inc(i)

  return (i, schedule_count).ok(env) # {:ok, {1000, 932}}
```

!!! note
    * `enif_consume_timeslice(env, cint): bool` takes a % argument and returns true if the NIF has consumed this percent of the timeslice--a timeslice is roughly 1ms.
    * `enif_schedule_nif()` is used to reschedule the NIF to be called later. This allows the Erlang scheduler to function as normal in the event that other work needs attention.

