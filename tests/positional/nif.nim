import ../../nimler
import ../../nimler/codec

func pos_int(env: pointer, a: int, b: int): (ErlAtom, int) {.xnif, raises: [].} =
  doAssert(a == 1)
  doAssert(b == 2)
  return (AtomOk, a + b)

func pos_bool(env: pointer, a: int, b: int, c: bool, d: bool): (ErlAtom, bool, bool) {.xnif, raises: [].} =
  doAssert(c == false)
  doAssert(d == true)
  doAssert(a == 1)
  doAssert(b == 2)
  return (AtomOk, a > b, a < b)

func pos_bin(env: pointer, a: seq[byte]): (ErlAtom, seq[byte]) {.xnif, raises: [].} =
  doAssert(a == cast[seq[byte]]("test"))
  return (AtomOk, a & cast[seq[byte]]("ing"))

export_nifs "Elixir.NimlerPositionalArgs",
  [ pos_int, pos_bool, pos_bin ]

