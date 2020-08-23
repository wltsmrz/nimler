import std/macros
import std/typetraits
import std/tables
import bindings/erl_nif

import std/options
export options

using
  env: ptr ErlNifEnv
  term: ErlNifTerm

const AtomOk* = ErlAtom("ok")
const AtomError* = ErlAtom("error")
const AtomTrue* = ErlAtom("true")
const AtomFalse* = ErlAtom("false")

macro generic_params(T: typedesc): untyped =
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
# int
func from_term*(env; term; T: typedesc[int]): Option[T] {.inline.} =
  var res: int
  if enif_get_long(env, term, addr(res)):
    result = some(res)

func to_term*(env; term: int): ErlNifTerm {.inline.} =
  enif_make_long(env, term)

# uint
func from_term*(env; term; T: typedesc[uint]): Option[T] {.inline.} =
  var res: uint
  if enif_get_ulong(env, term, addr(res)):
    result = some(res)

func to_term*(env; term: uint): ErlNifTerm {.inline.} =
  enif_make_ulong(env, term)

# int32
func from_term*(env; term; T: typedesc[int32]): Option[T] {.inline.} =
  var res: clong
  if enif_get_long(env, term, addr(res)):
    result = some(res.int32)

func to_term*(env; term: int32): ErlNifTerm {.inline.} =
  enif_make_long(env, term)

# uint32
func from_term*(env; term; T: typedesc[uint32]): Option[T] {.inline.} =
  var res: culong
  if enif_get_ulong(env, term, addr(res)):
    result = some(res.uint32)

func to_term*(env; term: uint32): ErlNifTerm {.inline.} =
  enif_make_ulong(env, term)
  
# int64
func from_term*(env; term; T: typedesc[int64]): Option[T] {.inline.} =
  var res: int64
  if enif_get_int64(env, term, addr(res)):
    result = some(res)

func to_term*(env; term: int64): ErlNifTerm {.inline.} =
  enif_make_int64(env, term)

# uint64
func from_term*(env; term; T: typedesc[uint64]): Option[T] {.inline.} =
  var res: uint64
  if enif_get_uint64(env, term, addr(res)):
    result = some(res)

func to_term*(env; term: uint64): ErlNifTerm {.inline.} =
  enif_make_uint64(env, term)

# float
func from_term*(env; term; T: typedesc[float]): Option[T] {.inline.} =
  var res: float
  if enif_get_double(env, term, addr(res)):
    result = some(res)

func to_term*(env; term: float): ErlNifTerm {.inline.} =
  enif_make_double(env, term)

# atom
func from_term*(env; term; T: typedesc[ErlAtom]): Option[T] {.inline.} =
  var atom_len: cuint
  if enif_get_atom_length(env, term, addr(atom_len), ERL_NIF_LATIN1):
    let buf_len = atom_len + 1
    var atom = newString(atom_len)
    if enif_get_atom(env, term, addr(atom[0]), buf_len, ERL_NIF_LATIN1) == cint(buf_len):
      result = some(ErlAtom(atom))

func to_term*(env; V: ErlAtom): ErlNifTerm {.inline.} =
  var res: ErlNifTerm
  if enif_make_existing_atom_len(env, V.cstring, len(V).csize_t, addr(res)):
    result = res
  else:
    result = enif_make_atom_len(env, V.cstring, len(V).csize_t)

# charlist
func from_term*(env; term; T: typedesc[seq[char]]): Option[T] {.inline.} =
  var string_len: cuint
  if enif_get_list_length(env, term, addr(string_len)):
    let buf_len = string_len + 1
    var string_buf = newSeq[char](string_len)
    if enif_get_string(env, term, addr(string_buf[0]), buf_len, ERL_NIF_LATIN1) == cint(buf_len):
      result = some(string_buf)

func to_term*(env; V: seq[char]): ErlNifTerm {.inline.} =
  enif_make_string_len(env, V, ERL_NIF_LATIN1)

# string
func bin_to_str(bin: ErlNifBinary): string {.inline.} =
  result = newString(bin.size)
  copyMem(addr(result[0]), bin.data, result.len)

func from_term*(env; term; T: typedesc[string]): Option[T] {.inline.} =
  var bin: ErlNifBinary
  if enif_inspect_binary(env, term, addr(bin)):
    result = some(bin_to_str(bin))

func to_term*(env; V: string): ErlNifTerm {.inline.} =
  var term: ErlNifTerm
  var bin = cast[ptr byte](enif_make_new_binary(env, len(V).csize_t, term.addr))
  copyMem(bin, unsafeAddr(V[0]), len(V))
  result = term

# binary
func from_term*(env; term; T: typedesc[seq[byte]]): Option[T] {.inline.} =
  var erl_bin: ErlNifBinary
  if enif_inspect_binary(env, term, addr(erl_bin)):
    var bin = newSeq[byte](erl_bin.size)
    copyMem(addr(bin[0]), erl_bin.data, erl_bin.size)
    result = some(bin)

func to_term*(env; V: seq[byte]): ErlNifTerm {.inline.} =
  var term: ErlNifTerm
  var bin = cast[ptr byte](enif_make_new_binary(env, len(V).csize_t, term.addr))
  copyMem(bin, unsafeAddr(V[0]), len(V))
  result = term

# list
func from_term*(env; term; T: typedesc[seq]): Option[T] =
  if not enif_is_list(env, term):
    return none(T)
  var res: T
  var cursor = term
  var head, tail: ErlNifTerm
  type el_type = codec.generic_params(T).get(0)
  while enif_get_list_cell(env, cursor, addr(head), addr(tail)):
    var head_d = env.from_term(head, el_type)
    if head_d.isNone():
      return none(T)
    res.add(move(head_d.get()))
    cursor = tail
  return some(res)

func to_term*(env; V: seq): ErlNifTerm =
  var v = newSeqOfCap[ErlNifTerm](V.len)
  for el in V:
    v.add(env.to_term(el))
  result = enif_make_list_from_array(env, move(v))

# tuple
func from_term*(env; term; T: typedesc[tuple]): Option[T] =
  var tup: ptr UncheckedArray[ErlNifTerm]
  var arity: cuint
  if not enif_get_tuple(env, term, addr(arity), addr(tup)):
    return none(T)
  if arity.int < T.arity:
    return none(T)
  var res: T
  var ind = 0
  for field in res.fields:
    let val = env.from_term(tup[ind], type(field))
    if val.isNone():
      return none(T)
    field = val.get()
    inc(ind)
  return some(res)

macro to_term*(env: typed; V: tuple): untyped =
  expectKind(V, {nnkSym, nnkTupleConstr})
  if V.kind == nnkSym:
    let tup_len = V.getTypeImpl().len
    result = newCall("enif_make_tuple", env, newLit(tup_len))
    for i in 0 ..< tup_len:
      let v = quote do: `V`[`i`]
      result.add(newCall("to_term", env, v))
  elif V.kind == nnkTupleConstr:
    result = quote do:
      let erl_tup = `V`
      to_term(env, erl_tup)

# map/table
func from_term*(env; term; T: typedesc[Table]): Option[T] =
  type key_type = codec.generic_params(T).get(0)
  type val_type = codec.generic_params(T).get(1)
  var res: Table[key_type, val_type]
  var iter: ErlNifMapIterator
  var key, val: ErlNifTerm
  if not enif_map_iterator_create(env, term, addr(iter), ERL_NIF_MAP_ITERATOR_FIRST):
    return none(T)
  while enif_map_iterator_get_pair(env, addr(iter), addr(key), addr(val)):
    let key_d = env.from_term(key, key_type)
    let val_d = env.from_term(val, val_type)
    if key_d.isNone() or val_d.isNone():
      enif_map_iterator_destroy(env, addr(iter))
      return none(T)
    res[key_d.get()] = val_d.get()
    discard enif_map_iterator_next(env, addr(iter))
  enif_map_iterator_destroy(env, addr(iter))
  return some(res)

func to_term*(env; V: Table): ErlNifTerm =
  var keys, vals = newSeqOfCap[ErlNifTerm](len(V))
  for k, v in V:
    keys.add(env.to_term(k))
    vals.add(env.to_term(v))
  var res: ErlNifTerm
  if not enif_make_map_from_arrays(env, addr(keys[0]), addr(vals[0]), cuint(keys.len), addr(res)):
    return enif_raise_exception(env, env.to_term(ErlAtom("fail to encode map")))
  return res

# bool
func from_term*(env; term; T: typedesc[bool]): Option[T] {.inline.} =
  result = some(some(AtomTrue) == from_term(env, term, ErlAtom))

func to_term*(env; term: bool): ErlNifTerm {.inline.} =
  result = to_term(env, if term: AtomTrue else: AtomFalse)

# result
func result_tuple*(env; res_type: ErlnifTerm; terms: varargs[ErlNifTerm]): ErlNifTerm {.inline.} =
  return enif_make_tuple_from_array(env, res_type & @terms)

func ok*(env; terms: varargs[ErlNifTerm]): ErlNifTerm {.inline.} =
  return result_tuple(env, env.to_term(AtomOk), terms)

func error*(env; terms: varargs[ErlNifTerm]): ErlNifTerm {.inline.} =
  return result_tuple(env, env.to_term(AtomError), terms)

macro xnif*(fn: untyped): untyped =
  expectKind(fn, {nnkProcDef, nnkFuncDef})
  var rname = fn.name
  fn.name = ident($rname & "_inner")
  fn.addPragma(ident("inline"))
  var rbody = newTree(nnkStmtList, fn)
  var rcall = newCall(fn.name, ident("env"))
  var arity = 0

  for i, p in fn.params:
    if i < 2: continue
    inc(arity)
    var arg = newTree(nnkBracketExpr, ident("argv"), newLit(i-2))
    var decode_term = newCall("from_term", ident("env"), arg, p[1])
    var get_term = newCall("get", p[0], newCall("default", p[1]))
    rbody.add(newTree(nnkLetSection, newTree(nnkIdentDefs,
      p[0],
      newNimNode(nnkEmpty),
      decode_term)))
    rbody.add(newTree(nnkIfStmt, newTree(nnkElifBranch,
      newCall("isNone", p[0]),
      newTree(nnkReturnStmt, newCall("enif_make_badarg", ident("env"))))))
    rcall.add(get_term)

  rbody.add(
    newTree(nnkLetSection,
      newTree(nnkIdentDefs,
        ident("ret"),
        newNimNode(nnkEmpty),
        rcall)),
    newTree(nnkReturnStmt,
      newCall("to_term", ident("env"), ident("ret"))))

  var rparams = newTree(nnkFormalParams,
    ident("ErlNifTerm"),
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

  var rfn = newProc(
    rname,
    [],
    rbody,
    nnkFuncDef,
  )
  rfn.params = rparams
  rfn.pragma = newTree(nnkPragma,
    ident("nif"),
    newTree(nnkExprColonExpr, ident("arity"), newLit(arity)))

  result = rfn


