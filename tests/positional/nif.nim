import ../../nimler
import ../../nimler/codec
import tables

using
  env: ptr ErlNifEnv

func pos_int(env; a: int, b: int): (ErlAtom, int) {.xnif, raises: [].} =
  doAssert(a == 1)
  doAssert(b == 2)
  return (AtomOk, a + b)

func pos_bool(env; a: int, b: int, c: bool, d: bool): (ErlAtom, bool, bool) {.xnif, raises: [].} =
  doAssert(c == false)
  doAssert(d == true)
  doAssert(a == 1)
  doAssert(b == 2)
  return (AtomOk, a > b, a < b)

func pos_bin(env; a: seq[byte]): (ErlAtom, seq[byte]) {.xnif, raises: [].} =
  doAssert(a == cast[seq[byte]]("test"))
  return (AtomOk, a & cast[seq[byte]]("ing"))

func pos_str(env; a: string): (ErlAtom, string) {.xnif, raises: [].} =
  doAssert(a == "test")
  return (AtomOk, a & "ing")

func pos_seq(env; a: seq[int]): (ErlAtom, seq[int]) {.xnif, raises: [].} =
  doAssert(a == @[1,2,3])
  return (AtomOk, a & @[4,5,6])

func pos_charlist(env; a: seq[char]): (ErlAtom, seq[char]) {.xnif, raises: [].} =
  doAssert(a == @"test")
  return (AtomOk, a & @"ing")

func pos_map(env; x: Table[ErlAtom, int]): (ErlAtom, Table[ErlAtom, int]) {.xnif, raises: [].} =
  doAssert(x.hasKey(ErlAtom("a1")))
  doAssert(false == x.hasKey(ErlAtom("a9")))
  doAssert(len(x) == 3)
  var t = initTable[ErlAtom, int](4)
  for k, v in x:
    t.add(k, v)
  t.add(ErlAtom("a4"), 4)
  return (AtomOk, t)

type TupMap = Table[ErlAtom, tuple[a: string, b: int]]
# { :t, ("a", 1) }
func pos_tup_map(env; a: TupMap): (ErlAtom, TupMap) {.xnif.} =
  var ret: TupMap
  ret = initTable[ErlAtom, tuple[a: string, b: int]](4)
  ret.add(ErlAtom("c"), ("d", 5))
  return (AtomOk, ret)

func pos_pid(env; pid: ErlPid, msg: ErlTerm): ErlAtom {.xnif, raises: [].} =
  if not enif_send(env, unsafeAddr(pid), nil, msg):
    return AtomError
  return AtomOk

export_nifs "Elixir.NimlerPositionalArgs",
  [
    pos_int,
    pos_bool,
    pos_bin,
    pos_str,
    pos_charlist,
    pos_seq,
    pos_map,
    pos_tup_map,
    pos_pid
  ]

