
A rudimentary [PI controller](https://en.wikipedia.org/wiki/PID_controller#PI_controller) that uses [resource objects](https://wltsmrz.github.io/nimler/guide/resources/).

```nim tab="controller_nif.nim"
import nimler
import nimler/codec
import nimler/resources
import ./controller

const rate = 100.0
const min = -10.0
const max = 10.0
const kp = 0.5
const ki = 0.25
const kf = 1.0

using
  env: ptr ErlNifEnv
  argc: cint
  argv: ErlNifArgs

func create_resource(env; argc; argv): ErlNifTerm =
  let res = env.new_resource(PIControl)

  if res.isNone():
    return env.error(env.to_term("fail to allocate new resource"))

  init_controller(res.get(), rate, min, max, kp, ki, kf)
  return env.ok(env.release_resource(res.get()))

func update_resource(env; argc; argv): ErlNifTerm =
  let resource = env.get_resource(argv[0], PIControl)

  if resource.isNone():
    return enif_make_badarg(env)

  let controller = resource.get()
  let sp = env.from_term(argv[1], float)
  let pv = env.from_term(argv[2], float)
  
  if sp.isNone() or pv.isNone():
    return enif_make_badarg(env)

  let res = controller.update(sp.get(), pv.get())

  return env.ok(env.to_term(res))

resources.export_nifs(
  "Elixir.Controller",
  [
    create_resource.to_nif(name="create_resource", arity=0, flags=ERL_NIF_DIRTY_IO),
    update_resource.to_nif(name="update_resource", arity=3)
  ]
)

```

```nim tab="controller.nim"
type PIControl* = object
  kp: float # proportional gain
  ki: float # integral gain
  kf: float # feedforward gain
  p: float  # proportional
  i: float  # integral
  f: float  # feedforward
  r: float  # control
  di: float # integral rate
  min: float
  max: float
  integrate: bool

proc init_controller*(control: ptr PIControl, rate: float, min: float, max: float, kp: float = 0.0, ki: float = 0.0, kf: float = 0.0) =
  control.min = min
  control.max = max
  control.di = 1.0 / rate
  control.integrate = true
  control.kp = kp
  control.ki = ki
  control.kf = kf
  control.p = 0.0
  control.i = 0.0
  control.f = 0.0
  control.r = 0.0

proc set_gain*(control: ptr PIControl, kp: float, ki: float, kf: float) =
  control.kp = kp
  control.ki = ki
  control.kf = kf

proc clear_gain*(control: ptr PIControl) =
  set_gain(control, 0.0, 0.0, 0.0)

proc pause_i*(control: ptr PIControl) =
  control.integrate = false

proc resume_i*(control: ptr PIControl) =
  control.integrate = true

proc update*(control: ptr PIControl, sp: float, pv: float, f: float = 0.0): float =
  let error = sp - pv
  control.p = control.kp * error
  if control.integrate:
    control.i = control.i + error * control.ki * control.di
  control.f = control.kf * f
  control.r = clamp(control.p + control.i + control.f, control.min, control.max)
  result = control.r
```

```elixir tab="Controller.exs"
defmodule Controller do
    @on_load :load_nif

    def create_resource(), do: raise "not implemented"
    def update_resource(_a, _b, _c), do: raise "not implemented"

    def load_nif do
        :erlang.load_nif(to_charlist(Path.join(Path.dirname(__ENV__.file), "libcontroller_nif.so")), 0)

        {:ok, ctrl} = create_resource()
        IO.inspect(update_resource(ctrl, 10.0, 1.0), label: 'PIControl update')
        IO.inspect(update_resource(ctrl, 10.0, 5.0), label: 'PIControl update')
        IO.inspect(update_resource(ctrl, 10.0, 8.0), label: 'PIControl update')
        :ok
    end
end
```

```bash tab="compile_and_run.sh"
nim c --app:lib --noMain --gc:arc controller_nif.nim

elixir Controller.exs
```

!!! info "controller.nif.nim"
    * `import nimler/resources` Although nimler/resources provides convenience for using resources, it is optional. There are tests for using resources [with](https://github.com/wltsmrz/nimler/tree/develop/tests/init_resource) and [without](https://github.com/wltsmrz/nimler/tree/develop/tests/resource) the additional functionality of nimler/resources.
    * `resources.export_nifs()` rather than nimler.export_nifs() to automatically add load and unload handlers
    * `env.new_resource(T): Option[ptr T]` allocate new resource of type
    * `env.release_resource(ptr T): term` create ErlNifTerm of the resource and pass ownership to BEAM
    * `env.get_resource(term, T): Option[ptr T]` get resource at term


