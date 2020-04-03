
# Advanced example

This example shows rudimentary [PI controller](https://en.wikipedia.org/wiki/PID_controller#PI_controller). It makes use of "resource objects," and more complex nimler init API.

!!! note "Resource tracking"
    > The use of resource objects is a safe way to return pointers to native data structures from a NIF.

    See the section on Resource objects of [Erlang NIF docs](http://erlang.org/doc/man/erl_nif.html#functionality) for more information

```nim tab="nif.nim"
import nimler
import ./pi_controller

const rate = 100.0
const min = -10.0
const max = 10.0
const kp = 0.5
const ki = 0.25
const kf = 1.0

type ResourcePriv = object
  resource_type: ptr ErlNifResourceType

proc on_unload(env: ptr ErlNifEnv, priv_data: pointer): void =
  enif_free(priv_data)

proc on_load(env: ptr ErlNifEnv, priv_data: ptr pointer, load_info: ErlNifTerm): cint =
  let priv = cast[ptr ResourcePriv](enif_alloc(cast[csize_t](sizeof(ResourcePriv))))

  priv.resource_type = enif_open_resource_type(env, "PIController", ERL_NIF_RT_CREATE)
  priv_data[] = priv

  return 0

proc create_resource(env: ptr ErlNifEnv, argc: cint, argv: ErlNifArgs): ErlNifTerm =
  let priv = cast[ptr ResourcePriv](enif_priv_data(env))
  var controller = cast[ptr PIControl](enif_alloc_resource(priv.resource_type, cast[csize_t](sizeof(PIControl))))

  init_controller(controller, rate, min, max, kp, ki, kf)
  
  var resource_term = enif_make_resource(env, controller)
  enif_release_resource(controller)

  return resource_term


proc update_resource(env: ptr ErlNifEnv, argc: cint, argv: ErlNifArgs): ErlNifTerm =
  let priv = cast[ptr ResourcePriv](enif_priv_data(env))
  var controller: ptr PIControl

  if not enif_get_resource(env, argv[0], priv.resource_type, addr(controller)):
    return enif_make_badarg(env)

  let sp = argv[1].decode(env, float).get()
  let pv = argv[2].decode(env, float).get()
  let res = controller.update(sp, pv)

  return ok(res, env)

const exports = NifOptions(
  funcs: @[
    create_resource.toNif("create_resource", arity=0),
    update_resource.toNif("update_resource", arity=3)
  ],
  load: on_load,
  unload: on_unload
)
export_nifs(exports)
```

```nim tab="pi_controller.nim"
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
defmodule PIController do
  @on_load :load_nif

  def create_resource(), do: raise "not implemented"
  def update_resource(_a, _b, _c), do: raise "not implemented"

  def load_nif do
    :erlang.load_nif(to_charlist(Path.join(Path.dirname(__ENV__.file), "nif")), 0)

    ctrl = create_resource()
    IO.inspect(update_resource(ctrl, 10.0, 1.0), label: 'PIControl update')
    IO.inspect(update_resource(ctrl, 10.0, 5.0), label: 'PIControl update')
    IO.inspect(update_resource(ctrl, 10.0, 8.0), label: 'PIControl update')
  end
end
```

