type
  Buffer* = ptr UncheckedArray[cchar]
  ErlNifEnv* {.importc: "ErlNifEnv", header: "erl_nif.h", bycopy.} = object
  ErlNifTerm* = culonglong
  ErlNifUInt64* = culonglong
  ErlNifArgs* = UncheckedArray[ErlNifTerm]
  NifFunc* = proc (env: ptr ErlNifEnv; argc: cint; argv: ErlNifArgs): ErlNifTerm {.nimcall.}
  NifSpec* = tuple[name: string, arity: int, fptr: NifFunc]
  DirtyNifSpec* = tuple[name: string, arity: int, fptr: NifFunc, flags: ErlNifFlags]
  ErlNifFunc* {.importc: "ErlNifFunc", header: "erl_nif.h", bycopy.} = object
    name* {.importc: "name".}: cstring
    arity* {.importc: "arity".}: cuint
    fptr* {.importc: "fptr".}: NifFunc
    flags* {.importc: "flags".}: cuint
  ErlNifFlags* {.size: sizeof(cint).} = enum
    ERL_NIF_DIRTY_CPU,
    ERL_NIF_DIRTY_IO
  ErlNifUniqueInteger* {.size: sizeof(cint).} = enum
    ERL_NIF_UNIQUE_POSITIVE = (1 shl 0),
    ERL_NIF_UNIQUE_MONOTONIC = (1 shl 1)
  ErlNifSysInfo* {.importc: "ErlNifSysInfo", header: "erl_nif.h", bycopy.} = object
    driver_major_version* {.importc: "driver_major_version".}: cint
    driver_minor_version* {.importc: "driver_minor_version".}: cint
    erts_version* {.importc: "erts_version".}: cstring
    otp_release* {.importc: "otp_release".}: cstring
    thread_support* {.importc: "thread_support".}: cint
    smp_support* {.importc: "smp_support".}: cint
    async_threads* {.importc: "async_threads".}: cint
    scheduler_threads* {.importc: "scheduler_threads".}: cint
    nif_major_version* {.importc: "nif_major_version".}: cint
    nif_minor_version* {.importc: "nif_minor_version".}: cint
    dirty_scheduler_support* {.importc: "dirty_scheduler_support".}: cint
  ErlNifPid* {.importc: "ErlNifPid", header: "erl_nif.h", bycopy.} = object
    pid* {.importc: "pid".}: ErlNifTerm
  ErlNifHash* {.size: sizeof(cint).} = enum
    ERL_NIF_INTERNAL_HASH = 1, ERL_NIF_PHASH2 = 2
  ErlNifCharEncoding* {.size: sizeof(cint).} = enum
    ERL_NIF_LATIN1 = 1
  ErlNifEvent* {.importc: "ErlNifEvent", header: "erl_nif.h".} = cint
  ErlNifMonitor* {.importc: "ErlNifMonitor", header: "erl_nif.h".} = object
    data {.importc: "data".}: array[4, csize]
  ErlNifEntryLoad = proc (a1: ptr ErlNifEnv; priv_data: ptr pointer; load_info: ErlNifTerm): cint
  ErlNifEntryReload = proc (a1: ptr ErlNifEnv; priv_data: ptr pointer; load_info: ErlNifTerm): cint
  ErlNifEntryUpgrade = proc (a1: ptr ErlNifEnv; priv_data: ptr pointer; old_priv_data: ptr pointer; load_info: ErlNifTerm): cint
  ErlNifEntryUnload = proc (a1: ptr ErlNifEnv; priv_data: pointer)
  ErlNifEntry* {.importc: "ErlNifEntry", header: "erl_nif.h", bycopy.} = object
    major* {.importc: "major".}: cint
    minor* {.importc: "minor".}: cint
    name* {.importc: "name".}: cstring
    num_of_funcs* {.importc: "num_of_funcs".}: cint
    funcs* {.importc: "funcs".}: ptr UncheckedArray[ErlNifFunc]
    load* {.importc: "load".}: pointer
    reload* {.importc: "reload".}: pointer
    upgrade* {.importc: "upgrade".}: pointer
    unload* {.importc: "unload".}: pointer
    vm_variant* {.importc: "vm_variant".}: cstring
    options* {.importc: "options".}: cint
    sizeof_ErlNifResourceTypeInit* {.importc: "sizeof_ErlNifResourceTypeInit".}: csize
    min_erts* {.importc: "min_erts".}: cstring
  ErlNifResourceType* = object {.importc: "enif_resource_type_t", header: "erl_nif.h".}
  ErlNifResourceFlags* {.size: sizeof(cint).} = enum
    ERL_NIF_RT_CREATE = (1 shl 0),
    ERL_NIF_RT_TAKEOVER = (1 shl 1)
  ErlNifResourceDtor* = proc (a1: ptr ErlNifEnv; a2: pointer): void
  ErlNifResourceStop* = proc (a1: ptr ErlNifEnv; a2: pointer; a3: ErlNifEvent; is_direct_call: cint): void
  ErlNifResourceDown* = proc (a1: ptr ErlNifEnv; a2: pointer; a3: ptr ErlNifPid; a4: ptr ErlNifMonitor): void
  ErlNifResourceTypeInit* {.importc: "ErlNifResourceTypeInit", header: "erl_nif.h", bycopy.} = object
    dtor* {.importc: "dtor".}: ptr ErlNifResourceDtor
    stop* {.importc: "stop".}: ptr ErlNifResourceStop
    down* {.importc: "down".}: ptr ErlNifResourceDown
  ErlNifBinary* {.importc: "ErlNifBinary", header: "erl_nif.h", bycopy.} = object
    size* {.importc: "size".}: csize
    data* {.importc: "data".}: ptr cuchar
    ref_bin* {.importc: "ref_bin".}: pointer
    spare* {.importc: "__spare__".}: array[2, pointer]

proc enif_alloc*(a1: csize): pointer {.importc: "enif_alloc", header: "erl_nif.h".}
proc enif_free*(a1: pointer) {.importc: "enif_free", header: "erl_nif.h".}
proc enif_realloc*(a1: pointer; a2: csize): pointer {.importc: "enif_realloc", header: "erl_nif.h".}
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
proc enif_inspect_binary*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ptr ErlNifBinary): cint {.importc: "enif_inspect_binary", header: "erl_nif.h".}
proc enif_alloc_binary*(a1: csize; a2: ptr ErlNifBinary): cint {.importc: "enif_alloc_binary", header: "erl_nif.h".}
proc enif_realloc_binary*(a1: ptr ErlNifBinary; a2: csize): cint {.importc: "enif_realloc_binary", header: "erl_nif.h".}
proc enif_release_binary*(a1: ptr ErlNifBinary): cint {.importc: "enif_release_binary", header: "erl_nif.h".}
proc enif_get_atom*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: Buffer; a4: cuint; a5: ErlNifCharEncoding): cuint {.importc: "enif_get_atom", header: "erl_nif.h".}
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
proc enif_get_string*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: Buffer; a4: cuint; a5: ErlNifCharEncoding): cint {.importc: "enif_get_string", header: "erl_nif.h".}
proc enif_make_unique_integer*(a1: ptr ErlNifEnv; a2: ErlNifUniqueInteger): ErlNifTerm {.importc: "enif_make_unique_integer", header: "erl_nif.h".}
proc enif_make_atom*(a1: ptr ErlNifEnv; a2: cstring): ErlNifTerm {.importc: "enif_make_atom", header: "erl_nif.h".}
proc enif_make_atom_len*(a1: ptr ErlNifEnv; a2: cstring; a3: csize): ErlNifTerm {.importc: "enif_make_atom_len", header: "erl_nif.h".}
proc enif_make_existing_atom*(a1: ptr ErlNifEnv; a2: cstring; a3: ptr ErlNifTerm; a4: ErlNifCharEncoding): bool {.  importc: "enif_make_existing_atom", header: "erl_nif.h".}
proc enif_make_existing_atom_len*(a1: ptr ErlNifEnv; a2: cstring; a3: csize; a4: ptr ErlNifTerm; a5: ErlNifCharEncoding): bool {.importc: "enif_make_existing_atom_len", header: "erl_nif.h".}
proc enif_make_binary*(a1: ptr ErlNifEnv; a2: ptr ErlNifBinary): ErlNifTerm {.importc: "enif_make_binary", header: "erl_nif.h".}
proc enif_make_sub_binary*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: csize; a4: csize): ErlNifTerm {.importc: "enif_make_sub_binary", header: "erl_nif.h".}
proc enif_make_badarg*(a1: ptr ErlNifEnv): ErlNifTerm {.importc: "enif_make_badarg", header: "erl_nif.h".}
proc enif_make_int*(a1: ptr ErlNifEnv; a2: cint): ErlNifTerm {.importc: "enif_make_int", header: "erl_nif.h".}
proc enif_make_long*(a1: ptr ErlNifEnv; a2: clong): ErlNifTerm {.importc: "enif_make_long", header: "erl_nif.h".}
proc enif_make_int64*(a1: ptr ErlNifEnv; a2: clonglong): ErlNifTerm {.importc: "enif_make_int64", header: "erl_nif.h".}
proc enif_make_ulong*(a1: ptr ErlNifEnv; a2: culong): ErlNifTerm {.importc: "enif_make_ulong", header: "erl_nif.h".}
proc enif_make_uint64*(a1: ptr ErlNifEnv; a2: culonglong): ErlNifTerm {.importc: "enif_make_uint64", header: "erl_nif.h".}
proc enif_make_double*(a1: ptr ErlNifEnv; a2: cdouble): ErlNifTerm {.importc: "enif_make_double", header: "erl_nif.h".}
proc enif_make_tuple*(a1: ptr ErlNifEnv; a2: cuint): ErlNifTerm {.varargs, importc: "enif_make_tuple", header: "erl_nif.h".}
proc enif_make_list*(a1: ptr ErlNifEnv; a2: cuint): ErlNifTerm {.varargs, importc: "enif_make_list", header: "erl_nif.h".}
proc enif_make_list_cell*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ErlNifTerm): ErlNifTerm {.importc: "enif_make_list_cell", header: "erl_nif.h".}
proc enif_make_reverse_list*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ptr ErlNifTerm): bool {.importc: "enif_make_reverse_list", header: "erl_nif.h".}
proc enif_make_string*(a1: ptr ErlNifEnv; string: cstring; a3: ErlNifCharEncoding): ErlNifTerm {.importc: "enif_make_string", header: "erl_nif.h".}
proc enif_make_string_len*(a1: ptr ErlNifEnv; string: cstring; a2: csize; a3: ErlNifCharEncoding): ErlNifTerm {.  importc: "enif_make_string_len", header: "erl_nif.h".}
proc enif_make_ref*(a1: ptr ErlNifEnv): ErlNifTerm {.importc: "enif_make_ref", header: "erl_nif.h".}
proc enif_make_uint*(a1: ptr ErlNifEnv; a2: cuint): ErlNifTerm {.importc: "enif_make_uint", header: "erl_nif.h".}
proc enif_make_tuple_from_array*(a1: ptr ErlNifEnv; a2: openArray[ErlNifTerm]): ErlNifTerm {.  importc: "enif_make_tuple_from_array", header: "erl_nif.h".}
proc enif_make_list_from_array*(a1: ptr ErlNifEnv; a2: openArray[ErlNifTerm]): ErlNifTerm {.importc: "enif_make_list_from_array", header: "erl_nif.h".}
proc enif_make_new_binary*(a1: ptr ErlNifEnv; a2: csize; a3: ptr ErlNifTerm): ptr cuchar {.importc: "enif_make_new_binary", header: "erl_nif.h".}
proc enif_system_info*(a1: ptr ErlNifSysInfo; a2: csize) {.importc: "enif_system_info", header: "erl_nif.h".}
proc enif_raise_exception*(a1: ptr ErlNifEnv; a2: ErlNifTerm): ErlNifTerm {.importc: "enif_raise_exception", header: "erl_nif.h".}
proc enif_term_to_binary*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ptr ErlNifBinary): cint {.importc: "enif_term_to_binary", header: "erl_nif.h".}
proc enif_binary_to_term*(a1: ptr ErlNifEnv; a2: ptr cuchar; a3: csize; a4: ptr ErlNifTerm; a5: cuint): csize {.importc: "enif_binary_to_term", header: "erl_nif.h".}
proc enif_hash*(a1: ErlNifHash; term: ErlNifTerm; salt: ErlNifUInt64): ErlNifUInt64 {.importc: "enif_hash", header: "erl_nif.h".}
proc enif_alloc_env*(): ptr ErlNifEnv {.importc: "enif_alloc_env", header: "erl_nif.h".}
proc enif_free_env*(a1: ptr ErlNifEnv) {.importc: "enif_free_env", header: "erl_nif.h".}
proc enif_clear_env*(a1: ptr ErlNifEnv) {.importc: "enif_clear_env", header: "erl_nif.h".}
proc enif_send*(a1: ptr ErlNifEnv; a2: ptr ErlNifPid; a3: ptr ErlNifEnv; a4: ErlNifTerm): cint {.importc: "enif_send", header: "erl_nif.h".}
proc enif_make_copy*(a1: ptr ErlNifEnv; a2: ErlNifTerm): ErlNifTerm {.importc: "enif_make_copy", header: "erl_nif.h".}
proc enif_make_pid*(a1: ptr ErlNifEnv; a2: ptr ErlNifPid): ErlNifTerm {.importc: "enif_make_pid", header: "erl_nif.h".}
proc enif_self*(a1: ptr ErlNifEnv; a2: ptr ErlNifPid): ptr ErlNifPid {.importc: "enif_self", header: "erl_nif.h".}
proc enif_get_local_pid*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ptr ErlNifPid): bool {.importc: "enif_get_local_pid", header: "erl_nif.h".}
proc enif_get_map_size*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ptr csize): bool {.importc: "enif_get_map_size", header: "erl_nif.h".}
proc enif_make_new_map*(a1: ptr ErlNifEnv): ErlNifTerm {.importc: "enif_make_new_map", header: "erl_nif.h".}
proc enif_make_map_from_arrays*(a1: ptr ErlNifEnv; a2: ptr ErlNifTerm; a3: ptr ErlNifTerm; a4: csize, a5: ptr ErlNifTerm): bool {.importc: "enif_make_map_from_arrays", header: "erl_nif.h".}
proc enif_make_map_put*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ErlNifTerm; a4: ErlNifTerm; a5: ptr ErlNifTerm): bool {.importc: "enif_make_map_put", header: "erl_nif.h".}
proc enif_get_map_value*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ErlNifTerm; a4: ptr ErlNifTerm): bool {.importc: "enif_get_map_value", header: "erl_nif.h".}
proc enif_make_map_update*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ErlNifTerm; a4: ErlNifTerm; a5: ptr ErlNifTerm): bool {.importc: "enif_make_map_update", header: "erl_nif.h".}
proc enif_make_map_remove*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ErlNifTerm; a4: ptr ErlNifTerm): bool {.importc: "enif_make_map_remove", header: "erl_nif.h".}
proc enif_open_resource_type*(a1: ptr ErlNifEnv, a2: typeof(nil); a3: cstring, a4: pointer; a5: ErlNifResourceFlags; a6: ptr ErlNifResourceFlags): pointer {.importc: "enif_open_resource_type", header: "erl_nif.h".}
proc enif_alloc_resource*(a1: pointer; a2: csize): pointer {.importc: "enif_alloc_resource", header: "erl_nif.h".}
proc enif_release_resource*(a1: pointer): void {.importc: "enif_release_resource", header: "erl_nif.h".}
proc enif_make_resource*(a1: ptr ErlNifEnv; a2: pointer): ErlNifTerm {.importc: "enif_make_resource", header: "erl_nif.h".}
proc enif_get_resource*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: pointer; a4: pointer): bool {.importc: "enif_get_resource", header: "erl_nif.h".}
proc enif_consume_timeslice*(a1: ptr ErlNifEnv; a2: cint): bool {.importc: "enif_consume_timeslice", header: "erl_nif.h".}
proc enif_schedule_nif*(a1: ptr ErlNifEnv; a2: cstring; a3: cint; a4: NifFunc; a5: cint; a6: ptr ErlNifArgs): ErlNifTerm {.importc: "enif_schedule_nif", header: "erl_nif.h".}
  
