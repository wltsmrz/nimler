
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

