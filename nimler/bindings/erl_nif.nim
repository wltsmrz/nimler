import ../erl_sys_info

type
  ErlNifEnv* {.importc: "ErlNifEnv", header: "erl_nif.h".} = object
  ErlNifTerm* = culonglong
  ErlNifArgs* = ptr UncheckedArray[ErlNifTerm]
  ErlNifFptr* = proc (env: ptr ErlNifEnv; argc: cint; argv: ErlNifArgs): ErlNifTerm {.nimcall.}
  ErlNifFlags* {.size: sizeof(cint).} = enum
    ERL_NIF_REGULAR = 0,
    ERL_NIF_DIRTY_CPU = 1,
    ERL_NIF_DIRTY_IO = 2
  ErlNifFunc* {.importc: "ErlNifFunc", header: "erl_nif.h"} = object
    name*: cstring
    arity*: cuint
    fptr*: ErlNifFptr
    flags*: ErlNifFlags
  ErlNifEntryLoad* = proc (a1: ptr ErlNifEnv; priv_data: ptr pointer; load_info: ErlNifTerm): cint {.nimcall.}
  ErlNifEntryReload* = proc (a1: ptr ErlNifEnv; priv_data: ptr pointer; load_info: ErlNifTerm): cint {.nimcall.}
  ErlNifEntryUpgrade* = proc (a1: ptr ErlNifEnv; priv_data: ptr pointer; old_priv_data: ptr pointer; load_info: ErlNifTerm): cint {.nimcall.}
  ErlNifEntryUnload* = proc (a1: ptr ErlNifEnv; priv_data: pointer) {.nimcall.}
  ErlNifEntry* {.importc: "ErlNifEntry", header: "erl_nif.h"} = object
    major*: cint
    minor*: cint
    name*: cstring
    num_of_funcs*: cint
    funcs*: ptr ErlNifFunc
    load*: pointer
    reload*: pointer
    upgrade*: pointer
    unload*: pointer
    vm_variant*: cstring
    options*: cint
    sizeof_ErlNifResourceTypeInit*: csize_t
    min_erts*: cstring
  ErlNifTermType* {.size: sizeof(cint), importc: "ErlNifTermType", header: "erl_nif.h".} = enum
    ERL_NIF_TERM_TYPE_ATOM = 1
    ERL_NIF_TERM_TYPE_BITSTRING = 2
    ERL_NIF_TERM_TYPE_FLOAT = 3
    ERL_NIF_TERM_TYPE_FUN = 4
    ERL_NIF_TERM_TYPE_INTEGER = 5
    ERL_NIF_TERM_TYPE_LIST = 6
    ERL_NIF_TERM_TYPE_MAP = 7
    ERL_NIF_TERM_TYPE_PID = 8
    ERL_NIF_TERM_TYPE_PORT = 9
    ERL_NIF_TERM_TYPE_REFERENCE = 10
    ERL_NIF_TERM_TYPE_TUPLE = 11
  ErlNifUniqueInteger* {.size: sizeof(cint), importc: "ErlNifUniqueInteger", header: "erl_nif.h".} = enum
    ERL_NIF_UNIQUE_POSITIVE = (1 shl 0),
    ERL_NIF_UNIQUE_MONOTONIC = (1 shl 1)
  ErlNifSysInfo* {.importc: "ErlNifSysInfo", header: "erl_nif.h"} = object
    driver_major_version*: cint
    driver_minor_version*: cint
    erts_version*: cstring
    otp_release*: cstring
    thread_support*: cint
    smp_support*: cint
    async_threads*: cint
    scheduler_threads*: cint
    nif_major_version*: cint
    nif_minor_version*: cint
    dirty_scheduler_support*: cint
  ErlNifPid* {.importc: "ErlNifPid", header: "erl_nif.h"} = object
    pid*: ErlNifTerm
  ErlNifHash* {.size: sizeof(cint), importc: "ErlNifHash", header: "erl_nif.h".} = enum
    ERL_NIF_INTERNAL_HASH = 1,
    ERL_NIF_PHASH2 = 2
  ErlNifCharEncoding* {.size: sizeof(cint), importc: "ErlNifCharEncoding", header: "erl_nif.h".} = enum
    ERL_NIF_LATIN1 = 1
  ErlNifEvent* {.importc: "ErlNifEvent", header: "erl_nif.h"} = cint
  ErlNifMonitor* {.importc: "ErlNifMonitor", header: "erl_nif.h".} = object
    data: array[4, csize_t]
  ErlNifResourceType* {.importc: "ErlNifResourceType", header: "erl_nif.h"} = object
  ErlNifResourceFlags* {.size: sizeof(cint), importc: "ErlNifResourceFlags", header: "erl_nif.h".} = enum
    ERL_NIF_RT_CREATE = 1
    ERL_NIF_RT_TAKEOVER = 2
  ErlNifResourceDtor* = proc (a1: ptr ErlNifEnv; a2: pointer): void
  ErlNifResourceStop* = proc (a1: ptr ErlNifEnv; a2: pointer; a3: ErlNifEvent; is_direct_call: cint): void
  ErlNifResourceDown* = proc (a1: ptr ErlNifEnv; a2: pointer; a3: ptr ErlNifPid; a4: ptr ErlNifMonitor): void
  ErlNifResourceTypeInit* {.importc: "ErlNifResourceTypeInit", header: "erl_nif.h"} = object
    dtor*: ptr ErlNifResourceDtor
    stop*: ptr ErlNifResourceStop
    down*: ptr ErlNifResourceDown
  ErlNifBinaryToTerm* {.size: sizeof(cint), importc: "ErlNifBinaryToTerm", header: "erl_nif.h".} = enum
    ERL_NIF_BIN2TERM_SAFE = 0x20000000
  ErlNifBinary* {.importc: "ErlNifBinary", header: "erl_nif.h".} = object
    size*: csize_t
    data*: ptr cuchar
    ref_bin*: pointer
    spare*: array[2, pointer]
  ErlNifMapIteratorEntry* {.size: sizeof(cint), importc: "ErlNifMapIteratorEntry", header: "erl_nif.h".} = enum
    ERL_NIF_MAP_ITERATOR_FIRST = 1,
    ERL_NIF_MAP_ITERATOR_LAST = 2
  ErlNifMapIteratorFlat* = object
    ks*: ErlNifTerm
    vs*: ErlNifTerm
  ErlNifMapIteratorHash* = object
    wstack*: pointer
    kv*: ErlNifTerm
  ErlNifMapIteratorU* {.union.} = object
      flat*: ErlNifMapIteratorFlat
      hash*: ErlNifMapIteratorHash
  ErlNifMapIterator* {.importc: "ErlNifMapIterator", header: "erl_nif.h".} = object
    map*: ErlNifTerm
    size*: cuint
    idx*: cuint
    u*: ErlNifMapIteratorU
    spare*: array[2, pointer]

proc enif_map_iterator_create*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ptr ErlNifMapIterator; a4: ErlNifMapIteratorEntry): bool {.importc: "enif_map_iterator_create", header: "erl_nif.h".}
proc enif_map_iterator_destroy*(a1: ptr ErlNifEnv; a2: ptr ErlNifMapIterator): void {.importc: "enif_map_iterator_destroy", header: "erl_nif.h".}
proc enif_map_iterator_next*(a1: ptr ErlNifEnv; a2: ptr ErlNifMapIterator): bool {.importc: "enif_map_iterator_next", header: "erl_nif.h".}
proc enif_map_iterator_prev*(a1: ptr ErlNifEnv; a2: ptr ErlNifMapIterator): bool {.importc: "enif_map_iterator_prev", header: "erl_nif.h".}
proc enif_map_iterator_get_pair*(a1: ptr ErlNifEnv; a2: ptr ErlNifMapIterator; a3: ptr ErlNifTerm; a4: ptr ErlNifTerm): bool {.importc: "enif_map_iterator_get_pair", header: "erl_nif.h".}
proc enif_map_iterator_is_head*(a1: ptr ErlNifEnv; a2: ptr ErlNifMapIterator): bool {.importc: "enif_map_iterator_is_head", header: "erl_nif.h".}
proc enif_map_iterator_is_tail*(a1: ptr ErlNifEnv; a2: ptr ErlNifMapIterator): bool {.importc: "enif_map_iterator_is_tail", header: "erl_nif.h".}
proc enif_alloc*(a1: csize_t): pointer {.importc: "enif_alloc", header: "erl_nif.h".}
proc enif_free*(a1: pointer) {.importc: "enif_free", header: "erl_nif.h".}
proc enif_realloc*(a1: pointer; a2: csize_t): pointer {.importc: "enif_realloc", header: "erl_nif.h".}
proc enif_priv_data*(a1: ptr ErlNifEnv): pointer {.importc: "enif_priv_data", header: "erl_nif.h".}
proc enif_term_type*(a1: ptr ErlNifEnv; a2: ErlNifTerm): ErlNifTermType {.importc: "enif_term_type", header: "erl_nif.h"}
proc enif_is_process_alive*(a1: ptr ErlNifEnv; a2: ptr ErlNifPid): bool {.importc: "enif_is_process_alive", header: "erl_nif.h".}
proc enif_is_port_alive*(a1: ptr ErlNifEnv; a2: ErlNifTerm): bool {.importc: "enif_is_port_alive", header: "erl_nif.h".}
proc enif_is_pid_undefined*(a2: ptr ErlNifPid): bool {.importc: "enif_is_pid_undefined", header: "erl_nif.h".}
proc enif_is_exception*(a1: ptr ErlNifEnv; a2: ErlNifTerm): bool {.importc: "enif_is_exception", header: "erl_nif.h".}
proc enif_is_atom*(a1: ptr ErlNifEnv; a2: ErlNifTerm): bool {.importc: "enif_is_atom", header: "erl_nif.h".}
proc enif_is_binary*(a1: ptr ErlNifEnv; a2: ErlNifTerm): bool {.  importc: "enif_is_binary", header: "erl_nif.h".}
proc enif_is_ref*(a1: ptr ErlNifEnv; a2: ErlNifTerm): bool {.importc: "enif_is_ref", header: "erl_nif.h".}
proc enif_is_fun*(a1: ptr ErlNifEnv; a2: ErlNifTerm): bool {.importc: "enif_is_fun", header: "erl_nif.h".}
proc enif_is_pid*(a1: ptr ErlNifEnv; a2: ErlNifTerm): bool {.importc: "enif_is_pid", header: "erl_nif.h".}
proc enif_is_port*(a1: ptr ErlNifEnv; a2: ErlNifTerm): bool {.importc: "enif_is_port", header: "erl_nif.h".}
proc enif_is_identical*(lhs: ErlNifTerm; rhs: ErlNifTerm): bool {.importc: "enif_is_identical", header: "erl_nif.h".}
proc enif_is_list*(a1: ptr ErlNifEnv; a2: ErlNifTerm): bool {.importc: "enif_is_list", header: "erl_nif.h".}
proc enif_is_tuple*(a1: ptr ErlNifEnv; a2: ErlNifTerm): bool {.importc: "enif_is_tuple", header: "erl_nif.h".}
proc enif_is_empty_list*(a1: ptr ErlNifEnv; a2: ErlNifTerm): bool {.importc: "enif_is_empty_list", header: "erl_nif.h".}
proc enif_is_map*(a1: ptr ErlNifEnv; a2: ErlNifTerm): bool {.importc: "enif_is_map", header: "erl_nif.h".}
proc enif_is_number*(a1: ptr ErlNifEnv; a2: ErlNifTerm): bool {.importc: "enif_is_number", header: "erl_nif.h".}
proc enif_is_current_process_alive*(a1: ptr ErlNifEnv): bool {.  importc: "enif_is_current_process_alive", header: "erl_nif.h".}
proc enif_compare*(a1: ErlNifTerm; a2: ErlNifTerm): cint {.importc: "enif_compare", header: "erl_nif.h".}
proc enif_inspect_binary*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ptr ErlNifBinary): bool {.importc: "enif_inspect_binary", header: "erl_nif.h".}
proc enif_alloc_binary*(a1: csize_t; a2: ptr ErlNifBinary): cint {.importc: "enif_alloc_binary", header: "erl_nif.h".}
proc enif_realloc_binary*(a1: ptr ErlNifBinary; a2: csize_t): cint {.importc: "enif_realloc_binary", header: "erl_nif.h".}
proc enif_release_binary*(a1: ptr ErlNifBinary): cint {.importc: "enif_release_binary", header: "erl_nif.h".}
proc enif_get_atom*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ptr char; a4: csize_t; a5: ErlNifCharEncoding): cint {.importc: "enif_get_atom", header: "erl_nif.h".}
proc enif_get_atom_length*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ptr cuint; a4: ErlNifCharEncoding): bool {.importc: "enif_get_atom_length", header: "erl_nif.h".}
proc enif_get_int*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ptr cint): bool {.importc: "enif_get_int", header: "erl_nif.h".}
proc enif_get_long*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ptr clong): bool {.importc: "enif_get_long", header: "erl_nif.h".}
proc enif_get_int64*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ptr clonglong): bool {.importc: "enif_get_int64", header: "erl_nif.h".}
proc enif_get_uint*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ptr cuint): bool {.importc: "enif_get_uint", header: "erl_nif.h".}
proc enif_get_ulong*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ptr culong): bool {.importc: "enif_get_ulong", header: "erl_nif.h".}
proc enif_get_uint64*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ptr culonglong): bool {.importc: "enif_get_uint64", header: "erl_nif.h".}
proc enif_get_double*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ptr cdouble): bool {.importc: "enif_get_double", header: "erl_nif.h".}
proc enif_get_list_cell*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ptr ErlNifTerm; a4: ptr ErlNifTerm): bool {.importc: "enif_get_list_cell", header: "erl_nif.h".}
proc enif_get_list_length*(a1: ptr ErlNifEnv; a2: ErlNifTerm; len: ptr cuint): bool {.importc: "enif_get_list_length", header: "erl_nif.h".}
proc enif_get_tuple*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ptr cuint; a4: ptr ptr UncheckedArray[ErlNifTerm]): bool {.importc: "enif_get_tuple", header: "erl_nif.h".}
proc enif_get_string*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ptr char; a4: csize_t; a5: ErlNifCharEncoding): cint {.importc: "enif_get_string", header: "erl_nif.h".}
proc enif_make_unique_integer*(a1: ptr ErlNifEnv; a2: ErlNifUniqueInteger): ErlNifTerm {.importc: "enif_make_unique_integer", header: "erl_nif.h".}
proc enif_make_atom*(a1: ptr ErlNifEnv; a2: cstring): ErlNifTerm {.importc: "enif_make_atom", header: "erl_nif.h".}
proc enif_make_atom_len*(a1: ptr ErlNifEnv; a2: cstring; a3: csize_t): ErlNifTerm {.importc: "enif_make_atom_len", header: "erl_nif.h".}
proc enif_make_existing_atom*(a1: ptr ErlNifEnv; a2: cstring; a3: ptr ErlNifTerm; a4: ErlNifCharEncoding): bool {.  importc: "enif_make_existing_atom", header: "erl_nif.h".}
proc enif_make_existing_atom_len*(a1: ptr ErlNifEnv; a2: cstring; a3: cuint; a4: ptr ErlNifTerm; a5: ErlNifCharEncoding): bool {.importc: "enif_make_existing_atom_len", header: "erl_nif.h".}
proc enif_make_binary*(a1: ptr ErlNifEnv; a2: ptr ErlNifBinary): ErlNifTerm {.importc: "enif_make_binary", header: "erl_nif.h".}
proc enif_make_sub_binary*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: csize_t; a4: csize_t): ErlNifTerm {.importc: "enif_make_sub_binary", header: "erl_nif.h".}
proc enif_make_badarg*(a1: ptr ErlNifEnv): ErlNifTerm {.importc: "enif_make_badarg", header: "erl_nif.h".}
proc enif_make_int*(a1: ptr ErlNifEnv; a2: cint): ErlNifTerm {.importc: "enif_make_int", header: "erl_nif.h".}
proc enif_make_long*(a1: ptr ErlNifEnv; a2: clong): ErlNifTerm {.importc: "enif_make_long", header: "erl_nif.h".}
proc enif_make_int64*(a1: ptr ErlNifEnv; a2: clonglong): ErlNifTerm {.importc: "enif_make_int64", header: "erl_nif.h".}
proc enif_make_ulong*(a1: ptr ErlNifEnv; a2: culong): ErlNifTerm {.importc: "enif_make_ulong", header: "erl_nif.h".}
proc enif_make_uint64*(a1: ptr ErlNifEnv; a2: culonglong): ErlNifTerm {.importc: "enif_make_uint64", header: "erl_nif.h".}
proc enif_make_double*(a1: ptr ErlNifEnv; a2: cdouble): ErlNifTerm {.importc: "enif_make_double", header: "erl_nif.h".}
proc enif_make_tuple*(a1: ptr ErlNifEnv; a2: csize_t): ErlNifTerm {.varargs, importc: "enif_make_tuple", header: "erl_nif.h".}
proc enif_make_list*(a1: ptr ErlNifEnv; a2: csize_t): ErlNifTerm {.varargs, importc: "enif_make_list", header: "erl_nif.h".}
proc enif_make_list_cell*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ErlNifTerm): ErlNifTerm {.importc: "enif_make_list_cell", header: "erl_nif.h".}
proc enif_make_reverse_list*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ptr ErlNifTerm): bool {.importc: "enif_make_reverse_list", header: "erl_nif.h".}
proc enif_make_string*(a1: ptr ErlNifEnv; string: cstring; a3: ErlNifCharEncoding): ErlNifTerm {.importc: "enif_make_string", header: "erl_nif.h".}
proc enif_make_string_len*(a1: ptr ErlNifEnv; string: cstring; a2: csize_t; a3: ErlNifCharEncoding): ErlNifTerm {.  importc: "enif_make_string_len", header: "erl_nif.h".}
proc enif_make_ref*(a1: ptr ErlNifEnv): ErlNifTerm {.importc: "enif_make_ref", header: "erl_nif.h".}
proc enif_make_uint*(a1: ptr ErlNifEnv; a2: csize_t): ErlNifTerm {.importc: "enif_make_uint", header: "erl_nif.h".}
proc enif_make_tuple_from_array*(a1: ptr ErlNifEnv; a2: openArray[ErlNifTerm]): ErlNifTerm {.  importc: "enif_make_tuple_from_array", header: "erl_nif.h".}
proc enif_make_list_from_array*(a1: ptr ErlNifEnv; a2: openArray[ErlNifTerm]): ErlNifTerm {.importc: "enif_make_list_from_array", header: "erl_nif.h".}
proc enif_make_new_binary*(a1: ptr ErlNifEnv; a2: csize_t; a3: ptr ErlNifTerm): ptr cuchar {.importc: "enif_make_new_binary", header: "erl_nif.h".}
proc enif_system_info*(a1: ptr ErlNifSysInfo; a2: csize_t): void {.importc: "enif_system_info", header: "erl_nif.h".}
proc enif_system_info*(): ErlNifSysInfo =
  var info: ErlNifSysInfo
  enif_system_info(addr(info), cast[csize_t](sizeof(info)))
  return info
proc enif_raise_exception*(a1: ptr ErlNifEnv; a2: ErlNifTerm): ErlNifTerm {.importc: "enif_raise_exception", header: "erl_nif.h".}
proc enif_term_to_binary*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ptr ErlNifBinary): cint {.importc: "enif_term_to_binary", header: "erl_nif.h".}
proc enif_binary_to_term*(a1: ptr ErlNifEnv; a2: ptr cuchar; a3: csize_t; a4: ptr ErlNifTerm; a5: ErlNifBinaryToTerm): csize_t {.importc: "enif_binary_to_term", header: "erl_nif.h".}
template enif_binary_to_term*(a1: ptr ErlNifEnv; a2: ptr cuchar; a3: csize_t; a4: ptr ErlNifTerm): csize_t =
  enif_binary_to_term(a1, a2, a3, a4, ERL_NIF_BIN2TERM_SAFE)
proc enif_hash*(a1: ErlNifHash; term: ErlNifTerm; salt: culonglong = 0): culonglong {.importc: "enif_hash", header: "erl_nif.h".}
proc enif_alloc_env*(): ptr ErlNifEnv {.importc: "enif_alloc_env", header: "erl_nif.h".}
proc enif_free_env*(a1: ptr ErlNifEnv) {.importc: "enif_free_env", header: "erl_nif.h".}
proc enif_clear_env*(a1: ptr ErlNifEnv) {.importc: "enif_clear_env", header: "erl_nif.h".}
proc enif_send*(a1: ptr ErlNifEnv; a2: ptr ErlNifPid; a3: ptr ErlNifEnv; a4: ErlNifTerm): cint {.importc: "enif_send", header: "erl_nif.h".}
proc enif_make_copy*(a1: ptr ErlNifEnv; a2: ErlNifTerm): ErlNifTerm {.importc: "enif_make_copy", header: "erl_nif.h".}
proc enif_make_pid*(a1: ptr ErlNifEnv; a2: ptr ErlNifPid): ErlNifTerm {.importc: "enif_make_pid", header: "erl_nif.h".}
proc enif_self*(a1: ptr ErlNifEnv; a2: ptr ErlNifPid): ptr ErlNifPid {.importc: "enif_self", header: "erl_nif.h".}
proc enif_get_local_pid*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ptr ErlNifPid): bool {.importc: "enif_get_local_pid", header: "erl_nif.h".}
proc enif_get_map_size*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ptr csize_t): bool {.importc: "enif_get_map_size", header: "erl_nif.h".}
proc enif_make_new_map*(a1: ptr ErlNifEnv): ErlNifTerm {.importc: "enif_make_new_map", header: "erl_nif.h".}
proc enif_make_map_from_arrays*(a1: ptr ErlNifEnv; a2: ptr ErlNifTerm; a3: ptr ErlNifTerm; a4: cuint, a5: ptr ErlNifTerm): bool {.importc: "enif_make_map_from_arrays", header: "erl_nif.h".}
proc enif_make_map_put*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ErlNifTerm; a4: ErlNifTerm; a5: ptr ErlNifTerm): bool {.importc: "enif_make_map_put", header: "erl_nif.h".}
proc enif_get_map_value*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ErlNifTerm; a4: ptr ErlNifTerm): bool {.importc: "enif_get_map_value", header: "erl_nif.h".}
proc enif_make_map_update*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ErlNifTerm; a4: ErlNifTerm; a5: ptr ErlNifTerm): bool {.importc: "enif_make_map_update", header: "erl_nif.h".}
proc enif_make_map_remove*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ErlNifTerm; a4: ptr ErlNifTerm): bool {.importc: "enif_make_map_remove", header: "erl_nif.h".}
proc enif_open_resource_type*(a1: ptr ErlNifEnv, a2: pointer; a3: cstring, a4: pointer; a5: ErlNifResourceFlags; a6: ptr ErlNifResourceFlags): ptr ErlNifResourceType {.importc: "enif_open_resource_type", header: "erl_nif.h".}
proc enif_open_resource_type*(a1: ptr ErlNifEnv, a2: pointer; a3: cstring, a4: pointer; a5: cint; a6: ptr cint): ptr ErlNifResourceType {.importc: "enif_open_resource_type", header: "erl_nif.h".}
template enif_open_resource_type*(a1: ptr ErlNifEnv; a2: cstring; a3: cint; a4: ptr cint): ptr ErlNifResourceType =
  enif_open_resource_type(a1, nil, a2, nil, a3, a4)
template enif_open_resource_type*(a1: ptr ErlNifEnv; a2: cstring; a3: cint): ptr ErlNifResourceType =
  enif_open_resource_type(a1, nil, a2, nil, a3, nil)
template enif_open_resource_type*(a1: ptr ErlNifEnv; a2: cstring; a3: ErlNifResourceFlags; a4: ptr ErlNifResourceFlags): ptr ErlNifResourceType =
  enif_open_resource_type(a1, nil, a2, nil, a3, a4)
template enif_open_resource_type*(a1: ptr ErlNifEnv; a2: cstring; a3: ErlNifResourceFlags): ptr ErlNifResourceType =
  enif_open_resource_type(a1, nil, a2, nil, a3, nil)
proc enif_alloc_resource*(a1: pointer; a2: csize_t): pointer {.importc: "enif_alloc_resource", header: "erl_nif.h".}
proc enif_release_resource*(a1: pointer): void {.importc: "enif_release_resource", header: "erl_nif.h".}
proc enif_make_resource*(a1: ptr ErlNifEnv; a2: pointer): ErlNifTerm {.importc: "enif_make_resource", header: "erl_nif.h".}
proc enif_get_resource*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: pointer; a4: pointer): bool {.importc: "enif_get_resource", header: "erl_nif.h".}
proc enif_consume_timeslice*(a1: ptr ErlNifEnv; a2: cint): bool {.importc: "enif_consume_timeslice", header: "erl_nif.h".}
proc enif_schedule_nif*(a1: ptr ErlNifEnv; a2: cstring; a3: cint; a4: ErlNifFptr; a5: cint; a6: ErlNifArgs): ErlNifTerm {.importc: "enif_schedule_nif", header: "erl_nif.h".}
template enif_schedule_nif*(a1: ptr ErlNifEnv; a2: cstring; a3: cint; a4: ErlNifFptr; a5: openArray[ErlNifTerm]): untyped =
  enif_schedule_nif(a1, a2, a3, a4, len(a5).cint, cast[ErlNifArgs](unsafeAddr(a5[0])))
template enif_schedule_nif*(a1: ptr ErlNifEnv; a2: ErlNifFptr; a3: openArray[ErlNifTerm]): untyped =
  enif_schedule_nif(a1, astToStr(a2), cint(0), a2, len(a3).cint, cast[ErlNifArgs](unsafeAddr(a3[0])))

when (nifMajor, nifMinor) >= (2, 8):
  proc enif_has_pending_exception*(a1: ptr ErlNifEnv; a2: ptr ErlNifTerm): bool {.importc: "enif_has_pending_exception", header: "erl_nif.h".}
  proc enif_has_pending_exception*(a1: ptr ErlNifEnv): bool =
    return enif_has_pending_exception(a1, nil)

when (nifMajor, nifMinor) >= (2, 11):
  proc enif_snprintf*(a1: ptr char, a2: cuint; a3: cstring): bool {.varargs, importc: "enif_snprintf", header: "erl_nif.h".}
