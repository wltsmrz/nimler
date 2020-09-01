import ../../nimler
import tables

using
  env: ptr ErlNifEnv

func posInt(env; a: int, b: int): (ErlAtom, int) {.xnif: "pos_int".} =
  doAssert(a == 1)
  doAssert(b == 2)
  return (AtomOk, a + b)

func posBool(env; a: int, b: int, c: bool, d: bool): (ErlAtom, bool, bool) {.xnif: "pos_bool".} =
  doAssert(c == false)
  doAssert(d == true)
  doAssert(a == 1)
  doAssert(b == 2)
  return (AtomOk, a > b, a < b)

func posBin(env; a: seq[byte]): (ErlAtom, seq[byte]) {.xnif: "pos_bin".} =
  doAssert(a == cast[seq[byte]]("test"))
  return (AtomOk, a & cast[seq[byte]]("ing"))

func posStr(env; a: string): (ErlAtom, string) {.xnif: "pos_str".} =
  doAssert(a == "test")
  return (AtomOk, a & "ing")

func posSeq(env; a: seq[int]): (ErlAtom, seq[int]) {.xnif: "pos_seq".} =
  if len(a) > 0:
    doAssert(a == @[1,2,3])
  return (AtomOk, a & @[4,5,6])

func posCharlist(env; a: seq[char]): (ErlAtom, seq[char]) {.xnif: "pos_charlist".} =
  doAssert(a == @"test")
  return (AtomOk, a & @"ing")

func posMap(env; x: Table[ErlAtom, int]): (ErlAtom, Table[ErlAtom, int]) {.xnif: "pos_map".} =
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
func posTupMap(env; a: TupMap): (ErlAtom, TupMap) {.xnif: "pos_tup_map".} =
  var ret: TupMap
  ret = initTable[ErlAtom, tuple[a: string, b: int]](4)
  ret.add(ErlAtom("c"), ("d", 5))
  return (AtomOk, ret)

func posPid(env; pid: ErlPid, msg: ErlTerm): ErlAtom {.xnif: "pos_pid", dirtyCpu.} =
  if not enif_send(env, unsafeAddr(pid), nil, msg):
    return AtomError
  return AtomOk

func posRename(env; a: ErlTerm): (ErlAtom, ErlTerm) {.xnif: "pos_ok?".} =
  return (AtomOk, a)

type MyO = object
  a: int
  b: string
  c: float

func posKeywords(env; a: MyO): ErlAtom {.xnif: "pos_keywords".} =
  doAssert(a.a == 1)
  doAssert(a.b == "test")
  doAssert(a.c == 3.1)
  return AtomOk

func posResult(env; a: int, b: int): ErlResult[int] {.xnif: "pos_result".} =
  doAssert(a == 1)
  doAssert(b == 2)
  return (AtomOk, a + b)

exportNifs "Elixir.NimlerPositionalArgs",
  [
    posInt,
    posBool,
    posBin,
    posStr,
    posCharlist,
    posSeq,
    posMap,
    posTupMap,
    posPid,
    posRename,
    posKeywords,
    posResult
  ]

