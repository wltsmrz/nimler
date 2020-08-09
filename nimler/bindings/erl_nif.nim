import ../erl_sys_info

const dep_header_name = "erl_nif.h"
{.pragma: c_dep, importc, header: dep_header_name.}
{.pragma: c_dep_struct, c_dep, bycopy.}
{.pragma: c_dep_enum, c_dep, size: sizeof(cint).}
{.pragma: c_dep_proc, c_dep, cdecl.}

type
  ErlNifTerm* {.c_dep, importc: "ERL_NIF_TERM".} = distinct uint
  ErlNifEnv* {.c_dep, incompleteStruct.} = object
  ErlNifArgs* = ptr UncheckedArray[ErlNifTerm]
  ErlNifFptr* = proc (env: ptr ErlNifEnv; argc: cint; argv: ErlNifArgs): ErlNifTerm {.cdecl.}
  ErlNifFlags* {.c_dep_enum, importc: "ErlNifDirtyTaskFlags".} = enum
    ERL_NIF_REGULAR = 0,
    ERL_NIF_DIRTY_CPU = 1,
    ERL_NIF_DIRTY_IO = 2
  ErlNifFunc* {.c_dep_struct.} = object
    name*: cstring
    arity*: cuint
    fptr*: ErlNifFptr
    flags*: ErlNifFlags
  ErlNifEntryLoad* = proc (a1: ptr ErlNifEnv; priv_data: ptr pointer; load_info: ErlNifTerm): cint {.nimcall.}
  ErlNifEntryReload* = proc (a1: ptr ErlNifEnv; priv_data: ptr pointer; load_info: ErlNifTerm): cint {.nimcall.}
  ErlNifEntryUpgrade* = proc (a1: ptr ErlNifEnv; priv_data: ptr pointer; old_priv_data: ptr pointer; load_info: ErlNifTerm): cint {.nimcall.}
  ErlNifEntryUnload* = proc (a1: ptr ErlNifEnv; priv_data: pointer) {.nimcall.}
  ErlNifEntry* {.c_dep_struct.} = object
    major*: cint
    minor*: cint
    name*: cstring
    num_of_funcs*: cint
    funcs*: ptr ErlNifFunc
    load*: ErlNifEntryLoad
    reload*: ErlNifEntryReload
    upgrade*: ErlNifEntryUpgrade
    unload*: ErlNifEntryUnload
    vm_variant*: cstring
    when nif_version_gte(2, 7):
      options*: cint
    when nif_version_gte(2, 12):
      sizeof_ErlNifResourceTypeInit*: csize_t
    when nif_version_gte(2, 14):
      min_erts*: cstring
  ErlNifTermType* {.c_dep_enum.} = enum
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
  ErlNifUniqueInteger* {.c_dep_enum.} = enum
    ERL_NIF_UNIQUE_POSITIVE = (1 shl 0),
    ERL_NIF_UNIQUE_MONOTONIC = (1 shl 1)
  ErlNifSysInfo* {.c_dep_struct.} = object
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
  ErlNifPid* {.c_dep_struct.} = object
    pid*: ErlNifTerm
  ErlNifHash* {.c_dep_enum.} = enum
    ERL_NIF_INTERNAL_HASH = 1,
    ERL_NIF_PHASH2 = 2
  ErlNifCharEncoding* {.c_dep_enum.} = enum
    ERL_NIF_LATIN1 = 1
  ErlNifEvent* {.importc.} = cint
  ErlNifMonitor* {.c_dep_struct.} = object
    data: array[4, csize_t]
  ErlNifResourceType* {.c_dep_struct.} = object
  ErlNifResourceFlags* {.c_dep_enum.} = enum
    ERL_NIF_RT_CREATE = 1
    ERL_NIF_RT_TAKEOVER = 2
  ErlNifResourceDtor* = proc (a1: ptr ErlNifEnv; a2: pointer): void
  ErlNifResourceStop* = proc (a1: ptr ErlNifEnv; a2: pointer; a3: ErlNifEvent; is_direct_call: cint): void
  ErlNifResourceDown* = proc (a1: ptr ErlNifEnv; a2: pointer; a3: ptr ErlNifPid; a4: ptr ErlNifMonitor): void
  ErlNifResourceTypeInit* {.c_dep_struct.} = object
    dtor*: ptr ErlNifResourceDtor
    stop*: ptr ErlNifResourceStop
    down*: ptr ErlNifResourceDown
  ErlNifBinaryToTerm* {.c_dep_enum.} = enum
    ERL_NIF_BIN2TERM_SAFE = 0x20000000
  ErlNifBinary* {.c_dep_struct.} = object
    size*: csize_t
    data*: ptr cuchar
    ref_bin*: pointer
    spare*: array[2, pointer]
  ErlNifMapIteratorEntry* {.c_dep_enum.} = enum
    ERL_NIF_MAP_ITERATOR_FIRST = 1,
    ERL_NIF_MAP_ITERATOR_LAST = 2
  ErlNifMapIteratorFlat = object
    ks*: ErlNifTerm
    vs*: ErlNifTerm
  ErlNifMapIteratorHash = object
    wstack*: pointer
    kv*: ErlNifTerm
  ErlNifMapIteratorU {.union.} = object
      flat*: ErlNifMapIteratorFlat
      hash*: ErlNifMapIteratorHash
  ErlNifMapIterator* {.c_dep_struct.} = object
    map*: ErlNifTerm
    size*: cuint
    idx*: cuint
    u*: ErlNifMapIteratorU
    spare*: array[2, pointer]
  ErlNifTime* {.c_dep.} = int
  ErlNifTimeUnit* {.c_dep_enum.} = enum
    ERL_NIF_SEC = 0
    ERL_NIF_MSEC = 1
    ERL_NIF_USEC = 2
    ERL_NIF_NSEC = 3
  ErlNifTimeError* {.c_dep, importc: "ERL_NIF_TIME_ERROR".} = int

func enif_priv_data*(a1: ptr ErlNifEnv): pointer {.c_dep_proc.}
func enif_hash*(a1: ErlNifHash; term: ErlNifTerm; salt: culonglong = 0): culonglong {.c_dep_proc.}
func enif_system_info*(a1: ptr ErlNifSysInfo; a2: csize_t): void {.c_dep_proc.}
func enif_system_info*(): ErlNifSysInfo {.inline.} =
  var info = ErlNifSysInfo()
  enif_system_info(addr(info), cast[csize_t](sizeof(info)))
  return info

# allocator
func enif_alloc*(a1: csize_t): pointer {.c_dep_proc.}
func enif_free*(a1: pointer) {.c_dep_proc.}
func enif_realloc*(a1: pointer; a2: csize_t): pointer {.c_dep_proc.}

# comparisons
func enif_term_type*(a1: ptr ErlNifEnv; a2: ErlNifTerm): ErlNifTermType {.c_dep_proc, min_nif_version(2, 15).}
func enif_compare*(a1: ErlNifTerm; a2: ErlNifTerm): cint {.c_dep_proc.}
func enif_is_current_process_alive*(a1: ptr ErlNifEnv): bool {.c_dep_proc.}
func enif_is_process_alive*(a1: ptr ErlNifEnv; a2: ptr ErlNifPid): bool {.c_dep_proc.}
func enif_is_port_alive*(a1: ptr ErlNifEnv; a2: ErlNifTerm): bool {.c_dep_proc.}
func enif_is_pid_undefined*(a2: ptr ErlNifPid): bool {.c_dep_proc.}
func enif_is_exception*(a1: ptr ErlNifEnv; a2: ErlNifTerm): bool {.c_dep_proc.}
func enif_is_atom*(a1: ptr ErlNifEnv; a2: ErlNifTerm): bool {.c_dep_proc.}
func enif_is_binary*(a1: ptr ErlNifEnv; a2: ErlNifTerm): bool {.c_dep_proc.}
func enif_is_ref*(a1: ptr ErlNifEnv; a2: ErlNifTerm): bool {.c_dep_proc.}
func enif_is_fun*(a1: ptr ErlNifEnv; a2: ErlNifTerm): bool {.c_dep_proc.}
func enif_is_pid*(a1: ptr ErlNifEnv; a2: ErlNifTerm): bool {.c_dep_proc.}
func enif_is_port*(a1: ptr ErlNifEnv; a2: ErlNifTerm): bool {.c_dep_proc.}
func enif_is_identical*(lhs: ErlNifTerm; rhs: ErlNifTerm): bool {.c_dep_proc.}
func enif_is_list*(a1: ptr ErlNifEnv; a2: ErlNifTerm): bool {.c_dep_proc.}
func enif_is_tuple*(a1: ptr ErlNifEnv; a2: ErlNifTerm): bool {.c_dep_proc.}
func enif_is_empty_list*(a1: ptr ErlNifEnv; a2: ErlNifTerm): bool {.c_dep_proc.}
func enif_is_map*(a1: ptr ErlNifEnv; a2: ErlNifTerm): bool {.c_dep_proc.}
func enif_is_number*(a1: ptr ErlNifEnv; a2: ErlNifTerm): bool {.c_dep_proc.}

# get
func enif_get_atom*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ptr char; a4: csize_t; a5: ErlNifCharEncoding): cint {.c_dep_proc.}
func enif_get_atom_length*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ptr cuint; a4: ErlNifCharEncoding): bool {.c_dep_proc.}
func enif_get_int*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ptr cint): bool {.c_dep_proc.}
func enif_get_long*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ptr clong): bool {.c_dep_proc.}
func enif_get_uint*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ptr cuint): bool {.c_dep_proc.}
func enif_get_ulong*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ptr culong): bool {.c_dep_proc.}
func enif_get_double*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ptr cdouble): bool {.c_dep_proc.}
func enif_get_list_cell*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ptr ErlNifTerm; a4: ptr ErlNifTerm): bool {.c_dep_proc.}
func enif_get_list_length*(a1: ptr ErlNifEnv; a2: ErlNifTerm; len: ptr cuint): bool {.c_dep_proc.}
func enif_get_tuple*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ptr cuint; a4: ptr ptr UncheckedArray[ErlNifTerm]): bool {.c_dep_proc.}
func enif_get_string*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ptr char; a4: csize_t; a5: ErlNifCharEncoding): cint {.c_dep_proc.}

# make
func enif_make_unique_integer*(a1: ptr ErlNifEnv; a2: ErlNifUniqueInteger): ErlNifTerm {.c_dep_proc.}
func enif_make_atom*(a1: ptr ErlNifEnv; a2: cstring): ErlNifTerm {.c_dep_proc.}
func enif_make_atom_len*(a1: ptr ErlNifEnv; a2: cstring; a3: uint): ErlNifTerm {.c_dep_proc.}
func enif_make_existing_atom*(a1: ptr ErlNifEnv; a2: cstring; a3: ptr ErlNifTerm; a4: ErlNifCharEncoding): bool {.c_dep_proc.}
template enif_make_existing_atom*(a1: ptr ErlNifEnv; a2: cstring; a3: ptr ErlNifTerm): untyped =
  enif_make_existing_atom(a1, a2, a3, ERL_NIF_LATIN1)
func enif_make_existing_atom_len*(a1: ptr ErlNifEnv; a2: cstring; a3: uint; a4: ptr ErlNifTerm; a5: ErlNifCharEncoding): bool {.c_dep_proc.}
template enif_make_existing_atom_len*(a1: ptr ErlNifEnv; a2: cstring; a3: uint; a4: ptr ErlNifTerm): untyped =
  enif_make_existing_atom_len(a1, a2, a3, a4, ERL_NIF_LATIN1)
func enif_make_binary*(a1: ptr ErlNifEnv; a2: ptr ErlNifBinary): ErlNifTerm {.c_dep_proc.}
func enif_make_sub_binary*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: csize_t; a4: csize_t): ErlNifTerm {.c_dep_proc.}
func enif_make_badarg*(a1: ptr ErlNifEnv): ErlNifTerm {.c_dep_proc.}
func enif_make_int*(a1: ptr ErlNifEnv; a2: cint): ErlNifTerm {.c_dep_proc.}
func enif_make_long*(a1: ptr ErlNifEnv; a2: clong): ErlNifTerm {.c_dep_proc.}
func enif_make_ulong*(a1: ptr ErlNifEnv; a2: culong): ErlNifTerm {.c_dep_proc.}
func enif_make_double*(a1: ptr ErlNifEnv; a2: cdouble): ErlNifTerm {.c_dep_proc.}
func enif_make_tuple*(a1: ptr ErlNifEnv; a2: csize_t): ErlNifTerm {.varargs, c_dep_proc.}
func enif_make_list*(a1: ptr ErlNifEnv; a2: csize_t): ErlNifTerm {.varargs, c_dep_proc.}
func enif_make_list_cell*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ErlNifTerm): ErlNifTerm {.c_dep_proc.}
func enif_make_reverse_list*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ptr ErlNifTerm): bool {.c_dep_proc.}
func enif_make_string*(a1: ptr ErlNifEnv; a2: cstring; a3: ErlNifCharEncoding): ErlNifTerm {.c_dep_proc.}
template enif_make_string*(a1: ptr ErlNifEnv; a2: cstring): untyped =
  enif_make_string(a1, a2, ERL_NIF_LATIN1)
func enif_make_string_len*(a1: ptr ErlNifEnv; string: cstring; a2: csize_t; a3: ErlNifCharEncoding): ErlNifTerm {.c_dep_proc.}
func enif_make_string_len*(a1: ptr ErlNifEnv; string: openArray[char]; a3: ErlNifCharEncoding): ErlNifTerm {.c_dep_proc.}
func enif_make_ref*(a1: ptr ErlNifEnv): ErlNifTerm {.c_dep_proc.}
func enif_make_uint*(a1: ptr ErlNifEnv; a2: csize_t): ErlNifTerm {.c_dep_proc.}
func enif_make_tuple_from_array*(a1: ptr ErlNifEnv; a2: openArray[ErlNifTerm]): ErlNifTerm {.c_dep_proc.}
func enif_make_list_from_array*(a1: ptr ErlNifEnv; a2: openArray[ErlNifTerm]): ErlNifTerm {.c_dep_proc.}
func enif_make_new_binary*(a1: ptr ErlNifEnv; a2: csize_t; a3: ptr ErlNifTerm): ptr cuchar {.c_dep_proc.}
func enif_make_copy*(a1: ptr ErlNifEnv; a2: ErlNifTerm): ErlNifTerm {.c_dep_proc.}
func enif_make_pid*(a1: ptr ErlNifEnv; a2: ptr ErlNifPid): ErlNifTerm {.c_dep_proc.}

# 64bit
func enif_get_int64*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ptr clonglong): bool {.c_dep_proc.}
func enif_get_uint64*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ptr culonglong): bool {.c_dep_proc.}
func enif_make_int64*(a1: ptr ErlNifEnv; a2: clonglong): ErlNifTerm {.c_dep_proc.}
func enif_make_uint64*(a1: ptr ErlNifEnv; a2: culonglong): ErlNifTerm {.c_dep_proc.}

#maps
func enif_map_iterator_create*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ptr ErlNifMapIterator; a4: ErlNifMapIteratorEntry): bool {.c_dep_proc.}
func enif_map_iterator_destroy*(a1: ptr ErlNifEnv; a2: ptr ErlNifMapIterator): void {.c_dep_proc.}
func enif_map_iterator_next*(a1: ptr ErlNifEnv; a2: ptr ErlNifMapIterator): bool {.c_dep_proc.}
func enif_map_iterator_prev*(a1: ptr ErlNifEnv; a2: ptr ErlNifMapIterator): bool {.c_dep_proc.}
func enif_map_iterator_get_pair*(a1: ptr ErlNifEnv; a2: ptr ErlNifMapIterator; a3: ptr ErlNifTerm; a4: ptr ErlNifTerm): bool {.c_dep_proc.}
func enif_map_iterator_is_head*(a1: ptr ErlNifEnv; a2: ptr ErlNifMapIterator): bool {.c_dep_proc.}
func enif_map_iterator_is_tail*(a1: ptr ErlNifEnv; a2: ptr ErlNifMapIterator): bool {.c_dep_proc.}
func enif_get_map_size*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ptr csize_t): bool {.c_dep_proc.}
func enif_make_new_map*(a1: ptr ErlNifEnv): ErlNifTerm {.c_dep_proc.}
func enif_make_map_from_arrays*(a1: ptr ErlNifEnv; a2: ptr ErlNifTerm; a3: ptr ErlNifTerm; a4: cuint, a5: ptr ErlNifTerm): bool {.c_dep_proc, min_nif_version(2, 14).}
func enif_make_map_put*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ErlNifTerm; a4: ErlNifTerm; a5: ptr ErlNifTerm): bool {.c_dep_proc.}
func enif_get_map_value*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ErlNifTerm; a4: ptr ErlNifTerm): bool {.c_dep_proc.}
func enif_make_map_update*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ErlNifTerm; a4: ErlNifTerm; a5: ptr ErlNifTerm): bool {.c_dep_proc.}
func enif_make_map_remove*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ErlNifTerm; a4: ptr ErlNifTerm): bool {.c_dep_proc.}

# binaries
func enif_inspect_binary*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ptr ErlNifBinary): bool {.c_dep_proc.}
func enif_alloc_binary*(a1: csize_t; a2: ptr ErlNifBinary): bool {.c_dep_proc.}
func enif_realloc_binary*(a1: ptr ErlNifBinary; a2: csize_t): bool {.c_dep_proc.}
func enif_release_binary*(a1: ptr ErlNifBinary): void {.c_dep_proc.}
func enif_term_to_binary*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ptr ErlNifBinary): bool {.c_dep_proc.}
func enif_binary_to_term*(a1: ptr ErlNifEnv; a2: ptr cuchar; a3: csize_t; a4: ptr ErlNifTerm; a5: ErlNifBinaryToTerm): csize_t {.c_dep_proc.}
template enif_binary_to_term*(a1: ptr ErlNifEnv; a2: ptr cuchar; a3: csize_t; a4: ptr ErlNifTerm): untyped =
  enif_binary_to_term(a1, a2, a3, a4, ERL_NIF_BIN2TERM_SAFE)

# messages
func enif_alloc_env*(): ptr ErlNifEnv {.c_dep_proc.}
func enif_free_env*(a1: ptr ErlNifEnv) {.c_dep_proc.}
func enif_clear_env*(a1: ptr ErlNifEnv) {.c_dep_proc.}
func enif_send*(a1: ptr ErlNifEnv; a2: ptr ErlNifPid; a3: ptr ErlNifEnv; a4: ErlNifTerm): bool {.c_dep_proc.}
func enif_self*(a1: ptr ErlNifEnv; a2: ptr ErlNifPid): ptr ErlNifPid {.c_dep_proc.}
func enif_get_local_pid*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ptr ErlNifPid): bool {.c_dep_proc.}

# resources
func enif_open_resource_type*(a1: ptr ErlNifEnv, a2: pointer; a3: cstring, a4: pointer; a5: ErlNifResourceFlags; a6: ptr ErlNifResourceFlags): ptr ErlNifResourceType {.c_dep_proc.}
func enif_open_resource_type*(a1: ptr ErlNifEnv, a2: pointer; a3: cstring, a4: pointer; a5: cint; a6: ptr cint): ptr ErlNifResourceType {.c_dep_proc.}
template enif_open_resource_type*(a1: ptr ErlNifEnv; a2: cstring; a3: cint; a4: ptr cint): untyped =
  enif_open_resource_type(a1, nil, a2, nil, a3, a4)
template enif_open_resource_type*(a1: ptr ErlNifEnv; a2: cstring; a3: ErlNifResourceFlags; a4: ptr ErlNifResourceFlags): untyped =
  enif_open_resource_type(a1, nil, a2, nil, a3, a4)
func enif_alloc_resource*(a1: pointer; a2: csize_t): pointer {.c_dep_proc.}
func enif_release_resource*(a1: pointer): void {.c_dep_proc.}
func enif_keep_resource*(a1: pointer): cint {.c_dep_proc.}
func enif_make_resource*(a1: ptr ErlNifEnv; a2: pointer): ErlNifTerm {.c_dep_proc.}
func enif_get_resource*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: pointer; a4: pointer): bool {.c_dep_proc.}

# timeslice/scheduling
func enif_consume_timeslice*(a1: ptr ErlNifEnv; a2: cint): bool {.c_dep_proc.}
func enif_schedule_nif*(a1: ptr ErlNifEnv; a2: cstring; a3: ErlNifFlags; a4: ErlNifFptr; a5: cint; a6: ErlNifArgs): ErlNifTerm {.c_dep_proc.}
template enif_schedule_nif*(a1: ptr ErlNifEnv; a2: ErlNifFptr; a3: openArray[ErlNifTerm]): untyped =
  enif_schedule_nif(a1, astToStr(a2), ERL_NIF_REGULAR, a2, len(a3).cint, cast[ErlNifArgs](a3.unsafeAddr))

# exceptions
func enif_raise_exception*(a1: ptr ErlNifEnv; a2: ErlNifTerm): ErlNifTerm {.c_dep_proc.}
func enif_has_pending_exception*(a1: ptr ErlNifEnv; a2: ptr ErlNifTerm): bool {.c_dep_proc, min_nif_version(2, 8).}
template enif_has_pending_exception*(a1): untyped =
  enif_has_pending_exception(a1, nil)

# time
func enif_monotonic_time*(a1: ErlNifTimeUnit): ErlNifTime {.c_dep_proc, min_nif_version(2, 10).}
func enif_convert_time_unit*(a1: ErlNifTime, a2: ErlNifTimeUnit, a3: ErlNifTimeUnit): ErlNifTime {.c_dep_proc, min_nif_version(2, 10).}
func enif_time_offset*(a1: ErlNifTimeUnit): ErlNifTime {.c_dep_proc, min_nif_version(2, 10).}
func enif_cpu_time*(a1: ptr ErlNifEnv): ErlNifTerm {.c_dep_proc, min_nif_version(2, 10).}
func enif_now_time*(a1: ptr ErlNifEnv): ErlNifTerm {.c_dep_proc, min_nif_version(2, 10).}

# printing
func enif_fprintf*(a1: File; a2: cstring): bool {.varargs, c_dep_proc.}
func enif_snprintf*(a1: ptr char, a2: cuint; a3: cstring): bool {.varargs, c_dep_proc, min_nif_version(2, 11).}

