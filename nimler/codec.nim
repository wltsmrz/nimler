import std/macros
import std/typetraits
import std/tables
import std/hashes
import bindings/erl_nif

import std/options
export options

using
  env: ptr ErlNifEnv
  term: ErlNifTerm

type ErlPid* = ErlNifPid
type ErlCharlist* = seq[char]
type ErlBinary* = seq[byte]
type ErlString* = string
type ErlList*[T] = seq[T]
type ErlInt* = int
type ErlUInt* = uint
type ErlFloat* = float

type ErlTerm* = ErlNifTerm
type ErlAtom* = distinct string
type ErlKeywords*[T] = seq[tuple[k: ErlAtom, v: T]]

proc `$`*(x: ErlAtom): string {.borrow.}
proc `==`*(a: ErlAtom, b: ErlAtom): bool {.borrow.}
proc hash*(x: ErlAtom): Hash {.borrow.}
proc len*(x: ErlAtom): int {.borrow.}

proc add*[T](x: var ErlKeywords[T], k: string, v: T) =
  x.add((ErlAtom(k), v))

func getKey*[T](keywords: ErlKeywords[T], key: ErlAtom, def: T = default(T)): (bool, T) =
  for (k, v) in keywords:
    if k == key:
      return (true, v)
  return (false, def)

func getKey*[T](keywords: ErlKeywords[T], key: string): (bool, T) =
  return getKey(keywords, ErlAtom(key))

func hasKey*[T](keywords: ErlKeywords[T], key: ErlAtom): bool =
  return getKey(keywords, key)[0]

func hasKey*[T](keywords: ErlKeywords[T], key: string): bool =
  return getKey(keywords, ErlAtom(key))[0]

const AtomOk* = ErlAtom("ok")
const AtomError* = ErlAtom("error")
const AtomTrue* = ErlAtom("true")
const AtomFalse* = ErlAtom("false")

macro genericParams(T: typedesc): untyped =
  result = newNimNode(nnkTupleConstr)
  var impl = getTypeImpl(T)
  expectKind(impl, nnkBracketExpr)
  impl = impl[1]
  while true:
    case impl.kind
    of nnkSym:
      impl = impl.getImpl
      continue
    of nnkTypeDef:
      impl = impl[2]
      continue
    of nnkBracketExpr:
      for i in 1..<impl.len:
        result.add impl[i]
      break
    else:
      error "wrong kind: " & $impl.kind

# term
func fromTerm*(env; term; T: typedesc[ErlTerm]): Option[T] {.inline.} = some(term)

func toTerm*(env; term: ErlTerm): ErlTerm {.inline.} = term

# pid
func fromTerm*(env; term; T: typedesc[ErlPid]): Option[T] {.inline.} =
  var pid: ErlPid
  if enif_get_local_pid(env, term, addr(pid)):
    result = some(pid)

func toTerm*(env; term: ErlPid): ErlTerm {.inline.} =
  result = enif_make_pid(env, unsafeAddr(term))

# int
func fromTerm*(env; term; T: typedesc[int]): Option[T] {.inline.} =
  var res: int
  if enif_get_long(env, term, addr(res)):
    result = some(res)

func toTerm*(env; term: int): ErlTerm {.inline.} =
  enif_make_long(env, term)

# uint
func fromTerm*(env; term; T: typedesc[uint]): Option[T] {.inline.} =
  var res: uint
  if enif_get_ulong(env, term, addr(res)):
    result = some(res)

func toTerm*(env; term: uint): ErlTerm {.inline.} =
  enif_make_ulong(env, term)

# int32
func fromTerm*(env; term; T: typedesc[int32]): Option[T] {.inline.} =
  var res: clong
  if enif_get_long(env, term, addr(res)):
    result = some(res.int32)

func toTerm*(env; term: int32): ErlTerm {.inline.} =
  enif_make_long(env, term)

# uint32
func fromTerm*(env; term; T: typedesc[uint32]): Option[T] {.inline.} =
  var res: culong
  if enif_get_ulong(env, term, addr(res)):
    result = some(res.uint32)

func toTerm*(env; term: uint32): ErlTerm {.inline.} =
  enif_make_ulong(env, term)
  
# int64
func fromTerm*(env; term; T: typedesc[int64]): Option[T] {.inline.} =
  var res: int64
  if enif_get_int64(env, term, addr(res)):
    result = some(res)

func toTerm*(env; term: int64): ErlTerm {.inline.} =
  enif_make_int64(env, term)

# uint64
func fromTerm*(env; term; T: typedesc[uint64]): Option[T] {.inline.} =
  var res: uint64
  if enif_get_uint64(env, term, addr(res)):
    result = some(res)

func toTerm*(env; term: uint64): ErlTerm {.inline.} =
  enif_make_uint64(env, term)

# float
func fromTerm*(env; term; T: typedesc[float]): Option[T] {.inline.} =
  var res: float
  if enif_get_double(env, term, addr(res)):
    result = some(res)

func toTerm*(env; term: float): ErlTerm {.inline.} =
  enif_make_double(env, term)

# atom
func fromTerm*(env; term; T: typedesc[ErlAtom]): Option[T] =
  var atomLen: cuint
  if enif_get_atom_length(env, term, addr(atomLen), ERL_NIF_LATIN1):
    let bufLen = atomLen + 1
    var atom = newString(atomLen)
    if enif_get_atom(env, term, addr(atom[0]), bufLen, ERL_NIF_LATIN1) == cint(bufLen):
      result = some(ErlAtom(atom))

func toTerm*(env; V: ErlAtom): ErlTerm {.inline.} =
  var res: ErlTerm
  if enif_make_existing_atom_len(env, V.cstring, len(V).csize_t, addr(res)):
    result = res
  else:
    result = enif_make_atom_len(env, V.cstring, len(V).csize_t)

# bool
func fromTerm*(env; term; T: typedesc[bool]): Option[T] {.inline.} =
  result = some(some(AtomTrue) == fromTerm(env, term, ErlAtom))

func toTerm*(env; term: bool): ErlTerm {.inline.} =
  result = toTerm(env, if term: AtomTrue else: AtomFalse)

# charlist
func fromTerm*(env; term; T: typedesc[seq[char]]): Option[T] =
  var stringLen: cuint
  if enif_get_list_length(env, term, addr(stringLen)):
    let bufLen = stringLen + 1
    var stringBuf = newSeq[char](stringLen)
    if enif_get_string(env, term, addr(stringBuf[0]), bufLen, ERL_NIF_LATIN1) == cint(bufLen):
      result = some(stringBuf)

func toTerm*(env; V: seq[char]): ErlTerm {.inline.} =
  enif_make_string_len(env, V, ERL_NIF_LATIN1)

# string
func fromTerm*(env; term; T: typedesc[string]): Option[T] =
  var erlBin: ErlNifBinary
  if enif_inspect_binary(env, term, addr(erlBin)):
    var bin = newString(erlBin.size)
    copyMem(addr(bin[0]), erlbin.data, erlBin.size)
    result = some(bin)

func toTerm*(env; V: string): ErlTerm {.inline.} =
  var term: ErlTerm
  var bin = cast[ptr byte](enif_make_new_binary(env, len(V).csize_t, term.addr))
  copyMem(bin, unsafeAddr(V[0]), len(V))
  result = term

# binary
func fromTerm*(env; term; T: typedesc[openArray[byte] or seq[byte]]): Option[T] =
  var erlBin: ErlNifBinary
  if enif_inspect_binary(env, term, addr(erlBin)):
    var bin = newSeq[byte](erlBin.size)
    copyMem(addr(bin[0]), erlBin.data, erlBin.size)
    result = some(bin)

func toTerm*(env; V: openArray[byte] or seq[byte]): ErlTerm {.inline.} =
  var term: ErlTerm
  var bin = cast[ptr byte](enif_make_new_binary(env, len(V).csize_t, term.addr))
  copyMem(bin, unsafeAddr(V[0]), len(V))
  result = term

# list
func fromTerm*(env; term; T: typedesc[seq]): Option[T] =
  type ElType = codec.genericParams(T).get(0)
  if not enif_is_list(env, term):
    return none(T)
  var res: T
  var cursor = term
  var head, tail: ErlTerm
  while enif_get_list_cell(env, cursor, addr(head), addr(tail)):
    var headD = env.fromTerm(head, ElType)
    if headD.isNone():
      return none(T)
    res.add(move(headD.get()))
    cursor = tail
  return some(res)

func toTerm*(env; V: seq): ErlTerm =
  var v = newSeqOfCap[ErlTerm](V.len)
  for el in V:
    v.add(env.toTerm(el))
  result = enif_make_list_from_array(env, move(v))

# tuple
func fromTerm*(env; term; T: typedesc[tuple]): Option[T] =
  var tup: ptr UncheckedArray[ErlTerm]
  var arity: cuint
  if not enif_get_tuple(env, term, addr(arity), addr(tup)):
    return none(T)
  if arity.int < T.arity:
    return none(T)
  var res: T
  var ind = 0
  for field in res.fields:
    let val = env.fromTerm(tup[ind], type(field))
    if val.isNone():
      return none(T)
    field = val.get()
    inc(ind)
  return some(res)

macro toTerm*(env: typed; V: tuple): untyped =
  expectKind(V, {nnkSym, nnkTupleConstr, nnkCall})
  case V.kind
  of nnkSym:
    let tupLen = V.getTypeImpl().len
    result = newCall("enif_make_tuple", env, newLit(tupLen))
    for i in 0 ..< tupLen:
      let v = quote do: `V`[`i`]
      result.add(newCall("toTerm", env, v))
  of nnkTupleConstr, nnkCall:
    result = quote do:
      let tup = `V`
      toTerm(env, tup)
  else:
    error "wrong kind"

# map/table
func fromTerm*(env; term; T: typedesc[Table]): Option[T] =
  type KeyType = codec.genericParams(T).get(0)
  type ValType = codec.genericParams(T).get(1)
  var res: Table[KeyType, ValType]
  var iter: ErlNifMapIterator
  var key, val: ErlTerm
  if not enif_map_iterator_create(env, term, addr(iter), ERL_NIF_MAP_ITERATOR_FIRST):
    return none(T)
  while enif_map_iterator_get_pair(env, addr(iter), addr(key), addr(val)):
    let keyD = env.fromTerm(key, KeyType)
    let valD = env.fromTerm(val, ValType)
    if keyD.isNone() or valD.isNone():
      enif_map_iterator_destroy(env, addr(iter))
      return none(T)
    res[keyD.get()] = valD.get()
    discard enif_map_iterator_next(env, addr(iter))
  enif_map_iterator_destroy(env, addr(iter))
  return some(res)

func toTerm*(env; V: Table): ErlTerm =
  var keys, vals = newSeqOfCap[ErlTerm](len(V))
  for k, v in V:
    keys.add(env.toTerm(k))
    vals.add(env.toTerm(v))
  var res: ErlTerm
  if not enif_make_map_from_arrays(env, addr(keys[0]), addr(vals[0]), cuint(keys.len), addr(res)):
    return enif_raise_exception(env, env.toTerm(ErlAtom("fail to encode map")))
  return res

# keyword list
func fromTerm*(env; term; T: typedesc[ErlKeywords]): Option[T] =
  type ElType = (ErlAtom, codec.genericParams(T).get(0))
  if not enif_is_list(env, term):
    return none(T)
  var res: T
  var cursor = term
  var head, tail: ErlTerm
  while enif_get_list_cell(env, cursor, addr(head), addr(tail)):
    var headD = env.fromTerm(head, ElType)
    if headD.isNone():
      return none(T)
    res.add(move(headD.get()))
    cursor = tail
  return some(res)

func fromTerm*(env; term; T: typedesc[object]): Option[T] =
  let keywords = fromTerm(env, term, ErlKeywords[ErlTerm])
  if isNone(keywords):
    return none(T)
  let keywordsVal = keywords.get()
  var res: T
  for k, v in fieldPairs(res):
    var (has, kval) = keywordsVal.getKey(ErlAtom(k))
    if not has:
      return none(T)
    var keywordVal = fromTerm(env, move(kval), type(v))
    if isNone(keywordVal):
      return none(T)
    v = move(keywordVal.get())
  return some(res)

func toTerm*(env; V: object): ErlTerm =
  var keywords: ErlKeywords[ErlTerm]
  for k, v in fieldPairs(V):
    keywords.add((ErlAtom(k), toTerm(env, v)))
  return toTerm(env, keywords)

# result
type ErlResult*[T] = tuple[R: ErlAtom, V: T]

macro resultTuple*(env; res: ErlResult): untyped =
  template args(res) =
    [toTerm(env, res[0]), toTerm(env, res[1])]
  result = newCall("enif_make_tuple_from_array", env, getAst(args(res)))

macro resultTuple*(env; resType: ErlAtom, term: untyped): untyped =
  template args(resType, term) =
    [toTerm(env, resType), toTerm(env, term)]
  result = newCall("enif_make_tuple_from_array", env, getAst(args(resType, term)))

macro resultTuple*(env; resType: ErlAtom): untyped =
  result = newCall("toTerm", env, resType)

template ok*(env; term): untyped = resultTuple(env, AtomOk, term)
template ok*(env): untyped = resultTuple(env, AtomOk)

template error*(env; term): untyped = resultTuple(env, AtomError, term)
template error*(env): untyped = resultTuple(env, AtomError)

macro toTerm*(env; V: ErlResult): ErlTerm =
  result = newCall("resultTuple", env, V)

proc copyPragmaWithout(p: NimNode, x: string): NimNode {.compileTime.} =
  expectKind(p, {nnkEmpty, nnkPragma})
  result = newTree(nnkPragma)
  for e in p:
    expectKind(e, {nnkIdent, nnkExprColonExpr})
    case e.kind
    of nnkExprColonExpr:
      if not eqIdent(e[0], x):
        result.add(e)
    of nnkIdent:
      if not eqIdent(e, x):
        result.add(e)
    else: error "wrong kind"

proc genNifWrapper(nifName: NimNode, fn: NimNode): NimNode {.compileTime.} =
  expectKind(nifName, nnkStrLit)
  expectKind(fn, {nnkProcDef, nnkFuncDef})

  let rname = fn.name
  fn.name = ident("z" & $fn.name & "Internal")

  let rbody = newTree(nnkStmtList, fn)
  let rcall = newCall(fn.name, ident("env"))

  for i in 2 ..< len(fn.params):
    let p = fn.params[i]
    let arg = newTree(nnkBracketExpr, ident("argv"), newLit(i-2))
    rbody.add(newTree(nnkLetSection, newTree(nnkIdentDefs,
      p[0],
      newNimNode(nnkEmpty),
      newCall("fromTerm", ident("env"), arg, p[1]))))
    rbody.add(newTree(nnkIfStmt, newTree(nnkElifBranch,
      newCall("unlikely", newCall("isNone", p[0])),
      newTree(nnkReturnStmt, newCall("enif_make_badarg", ident("env"))))))
    rcall.add(newCall("unsafeGet", p[0]))

  rbody.add(newTree(nnkReturnStmt, newCall("toTerm", ident("env"), rcall)))

  let rfn = newProc(rname, [], rbody, fn.kind)
  rfn.params = newTree(nnkFormalParams,
    ident("ErlTerm"),
    newTree(nnkIdentDefs,
      ident("env"),
      newNimNode(nnkPtrTy).add(ident("ErlNifEnv")),
      newNimNode(nnkEmpty)),
    newTree(nnkIdentDefs,
      ident("argc"),
      ident("cint"),
      newNimNode(nnkEmpty)),
    newTree(nnkIdentDefs,
      ident("argv"),
      ident("ErlNifArgs"),
      newNimNode(nnkEmpty)))

  rfn.pragma = copyPragmaWithout(fn.pragma, "raises")
  rfn.pragma.add(ident("nif"))
  rfn.pragma.add(newTree(nnkExprColonExpr, ident("arity"), newLit(len(fn.params)-2)))
  rfn.pragma.add(newTree(nnkExprColonExpr, ident("nif_name"), nifName))

  result = rfn

macro xnif*(nifName: untyped, fn: untyped): untyped =
  result = genNifWrapper(nifName, fn)

macro xnif*(fn: untyped): untyped =
  result = genNifWrapper(newLit(repr fn.name), fn)

