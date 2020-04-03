
# erl_nif API bindings

The following bindings are available to nimler NIFs.

For more details, see the [<ins>erl_nif docs</ins>](https://erlang.org/doc/man/erl_nif.html).

## enif_map_iterator_create
proc enif_map_iterator_create*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ptr ErlNifMapIterator; a4: ErlNifMapIteratorEntry): bool 
## enif_map_iterator_destroy
proc enif_map_iterator_destroy*(a1: ptr ErlNifEnv; a2: ptr ErlNifMapIterator): void 
## enif_map_iterator_next
proc enif_map_iterator_next*(a1: ptr ErlNifEnv; a2: ptr ErlNifMapIterator): bool 
## enif_map_iterator_prev
proc enif_map_iterator_prev*(a1: ptr ErlNifEnv; a2: ptr ErlNifMapIterator): bool 
## enif_map_iterator_get_pair
proc enif_map_iterator_get_pair*(a1: ptr ErlNifEnv; a2: ptr ErlNifMapIterator; a3: ptr ErlNifTerm; a4: ptr ErlNifTerm): bool 
## enif_map_iterator_is_head
proc enif_map_iterator_is_head*(a1: ptr ErlNifEnv; a2: ptr ErlNifMapIterator): bool 
## enif_map_iterator_is_tail
proc enif_map_iterator_is_tail*(a1: ptr ErlNifEnv; a2: ptr ErlNifMapIterator): bool 
## enif_snprintf
proc enif_snprintf*(a1: ptr char, a2: cuint; a3: cstring): bool 
## enif_fprintf
proc enif_fprintf*(a1: File, a2: cstring): bool 
## enif_alloc
proc enif_alloc*(a1: csize_t): pointer 
## enif_free
proc enif_free*(a1: pointer) 
## enif_realloc
proc enif_realloc*(a1: pointer; a2: csize_t): pointer 
## enif_priv_data
proc enif_priv_data*(a1: ptr ErlNifEnv): pointer 
## enif_term_type
proc enif_term_type*(a1: ptr ErlNifEnv; a2: ErlNifTerm): ErlNifTermType 
## enif_is_process_alive
proc enif_is_process_alive*(a1: ptr ErlNifEnv; a2: ptr ErlNifPid): bool 
## enif_is_port_alive
proc enif_is_port_alive*(a1: ptr ErlNifEnv; a2: ErlNifTerm): bool 
## enif_is_pid_undefined
proc enif_is_pid_undefined*(a2: ptr ErlNifPid): bool 
## enif_is_exception
proc enif_is_exception*(a1: ptr ErlNifEnv; a2: ErlNifTerm): bool 
## enif_is_atom
proc enif_is_atom*(a1: ptr ErlNifEnv; a2: ErlNifTerm): bool 
## enif_is_binary
proc enif_is_binary*(a1: ptr ErlNifEnv; a2: ErlNifTerm): bool 
## enif_is_ref
proc enif_is_ref*(a1: ptr ErlNifEnv; a2: ErlNifTerm): bool 
## enif_is_fun
proc enif_is_fun*(a1: ptr ErlNifEnv; a2: ErlNifTerm): bool 
## enif_is_pid
proc enif_is_pid*(a1: ptr ErlNifEnv; a2: ErlNifTerm): bool 
## enif_is_port
proc enif_is_port*(a1: ptr ErlNifEnv; a2: ErlNifTerm): bool 
## enif_is_identical
proc enif_is_identical*(lhs: ErlNifTerm; rhs: ErlNifTerm): bool 
## enif_is_list
proc enif_is_list*(a1: ptr ErlNifEnv; a2: ErlNifTerm): bool 
## enif_is_tuple
proc enif_is_tuple*(a1: ptr ErlNifEnv; a2: ErlNifTerm): bool 
## enif_is_empty_list
proc enif_is_empty_list*(a1: ptr ErlNifEnv; a2: ErlNifTerm): bool 
## enif_is_map
proc enif_is_map*(a1: ptr ErlNifEnv; a2: ErlNifTerm): bool 
## enif_is_number
proc enif_is_number*(a1: ptr ErlNifEnv; a2: ErlNifTerm): bool 
## enif_is_current_process_alive
proc enif_is_current_process_alive*(a1: ptr ErlNifEnv): bool 
## enif_compare
proc enif_compare*(a1: ErlNifTerm; a2: ErlNifTerm): cint 
## enif_inspect_binary
proc enif_inspect_binary*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ptr ErlNifBinary): bool 
## enif_alloc_binary
proc enif_alloc_binary*(a1: csize_t; a2: ptr ErlNifBinary): cint 
## enif_realloc_binary
proc enif_realloc_binary*(a1: ptr ErlNifBinary; a2: csize_t): cint 
## enif_release_binary
proc enif_release_binary*(a1: ptr ErlNifBinary): cint 
## enif_get_atom
proc enif_get_atom*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ptr char; a4: csize_t; a5: ErlNifCharEncoding): cint 
## enif_get_atom_length
proc enif_get_atom_length*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ptr cuint; a4: ErlNifCharEncoding): bool 
## enif_get_int
proc enif_get_int*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ptr cint): bool 
## enif_get_long
proc enif_get_long*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ptr clong): bool 
## enif_get_int64
proc enif_get_int64*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ptr clonglong): bool 
## enif_get_uint
proc enif_get_uint*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ptr cuint): bool 
## enif_get_ulong
proc enif_get_ulong*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ptr culong): bool 
## enif_get_uint64
proc enif_get_uint64*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ptr culonglong): bool 
## enif_get_double
proc enif_get_double*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ptr cdouble): bool 
## enif_get_list_cell
proc enif_get_list_cell*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ptr ErlNifTerm; a4: ptr ErlNifTerm): bool 
## enif_get_list_length
proc enif_get_list_length*(a1: ptr ErlNifEnv; a2: ErlNifTerm; len: ptr cuint): bool 
## enif_get_tuple
proc enif_get_tuple*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ptr cuint; a4: ptr ptr UncheckedArray[ErlNifTerm]): bool 
## enif_get_string
proc enif_get_string*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ptr char; a4: csize_t; a5: ErlNifCharEncoding): cint 
## enif_make_unique_integer
proc enif_make_unique_integer*(a1: ptr ErlNifEnv; a2: ErlNifUniqueInteger): ErlNifTerm 
## enif_make_atom
proc enif_make_atom*(a1: ptr ErlNifEnv; a2: cstring): ErlNifTerm 
## enif_make_atom_len
proc enif_make_atom_len*(a1: ptr ErlNifEnv; a2: cstring; a3: csize_t): ErlNifTerm 
## enif_make_existing_atom
proc enif_make_existing_atom*(a1: ptr ErlNifEnv; a2: cstring; a3: ptr ErlNifTerm; a4: ErlNifCharEncoding): bool 
## enif_make_existing_atom_len
proc enif_make_existing_atom_len*(a1: ptr ErlNifEnv; a2: cstring; a3: cuint; a4: ptr ErlNifTerm; a5: ErlNifCharEncoding): bool 
## enif_make_binary
proc enif_make_binary*(a1: ptr ErlNifEnv; a2: ptr ErlNifBinary): ErlNifTerm 
## enif_make_sub_binary
proc enif_make_sub_binary*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: csize_t; a4: csize_t): ErlNifTerm 
## enif_make_badarg
proc enif_make_badarg*(a1: ptr ErlNifEnv): ErlNifTerm 
## enif_make_int
proc enif_make_int*(a1: ptr ErlNifEnv; a2: cint): ErlNifTerm 
## enif_make_long
proc enif_make_long*(a1: ptr ErlNifEnv; a2: clong): ErlNifTerm 
## enif_make_int64
proc enif_make_int64*(a1: ptr ErlNifEnv; a2: clonglong): ErlNifTerm 
## enif_make_ulong
proc enif_make_ulong*(a1: ptr ErlNifEnv; a2: culong): ErlNifTerm 
## enif_make_uint64
proc enif_make_uint64*(a1: ptr ErlNifEnv; a2: culonglong): ErlNifTerm 
## enif_make_double
proc enif_make_double*(a1: ptr ErlNifEnv; a2: cdouble): ErlNifTerm 
## enif_make_tuple
proc enif_make_tuple*(a1: ptr ErlNifEnv; a2: csize_t): ErlNifTerm 
## enif_make_list
proc enif_make_list*(a1: ptr ErlNifEnv; a2: csize_t): ErlNifTerm 
## enif_make_list_cell
proc enif_make_list_cell*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ErlNifTerm): ErlNifTerm 
## enif_make_reverse_list
proc enif_make_reverse_list*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ptr ErlNifTerm): bool 
## enif_make_string
proc enif_make_string*(a1: ptr ErlNifEnv; string: cstring; a3: ErlNifCharEncoding): ErlNifTerm 
## enif_make_string_len
proc enif_make_string_len*(a1: ptr ErlNifEnv; string: cstring; a2: csize_t; a3: ErlNifCharEncoding): ErlNifTerm 
## enif_make_ref
proc enif_make_ref*(a1: ptr ErlNifEnv): ErlNifTerm 
## enif_make_uint
proc enif_make_uint*(a1: ptr ErlNifEnv; a2: csize_t): ErlNifTerm 
## enif_make_tuple_from_array
proc enif_make_tuple_from_array*(a1: ptr ErlNifEnv; a2: openArray[ErlNifTerm]): ErlNifTerm 
## enif_make_list_from_array
proc enif_make_list_from_array*(a1: ptr ErlNifEnv; a2: openArray[ErlNifTerm]): ErlNifTerm 
## enif_make_new_binary
proc enif_make_new_binary*(a1: ptr ErlNifEnv; a2: csize_t; a3: ptr ErlNifTerm): ptr cuchar 
## enif_system_info
proc enif_system_info*(a1: ptr ErlNifSysInfo; a2: csize_t): void 
## enif_system_info
proc enif_system_info*(): ErlNifSysInfo
## enif_raise_exception
proc enif_raise_exception*(a1: ptr ErlNifEnv; a2: ErlNifTerm): ErlNifTerm 
## enif_has_pending_exception
proc enif_has_pending_exception*(a1: ptr ErlNifEnv; a2: ptr ErlNifTerm): bool 
## enif_has_pending_exception
proc enif_has_pending_exception*(a1: ptr ErlNifEnv): bool
## enif_term_to_binary
proc enif_term_to_binary*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ptr ErlNifBinary): cint 
## enif_binary_to_term
proc enif_binary_to_term*(a1: ptr ErlNifEnv; a2: ptr cuchar; a3: csize_t; a4: ptr ErlNifTerm; a5: csize_t): csize_t 
## enif_hash
proc enif_hash*(a1: ErlNifHash; term: ErlNifTerm; salt: culonglong = 0): culonglong 
## enif_alloc_env
proc enif_alloc_env*(): ptr ErlNifEnv 
## enif_free_env
proc enif_free_env*(a1: ptr ErlNifEnv) 
## enif_clear_env
proc enif_clear_env*(a1: ptr ErlNifEnv) 
## enif_send
proc enif_send*(a1: ptr ErlNifEnv; a2: ptr ErlNifPid; a3: ptr ErlNifEnv; a4: ErlNifTerm): bool
## enif_make_copy
proc enif_make_copy*(a1: ptr ErlNifEnv; a2: ErlNifTerm): ErlNifTerm 
## enif_make_pid
proc enif_make_pid*(a1: ptr ErlNifEnv; a2: ptr ErlNifPid): ErlNifTerm 
## enif_self
proc enif_self*(a1: ptr ErlNifEnv; a2: ptr ErlNifPid): ptr ErlNifPid 
## enif_get_local_pid
proc enif_get_local_pid*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ptr ErlNifPid): bool 
## enif_get_map_size
proc enif_get_map_size*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ptr cuint): bool 
## enif_make_new_map
proc enif_make_new_map*(a1: ptr ErlNifEnv): ErlNifTerm 
## enif_make_map_from_arrays
proc enif_make_map_from_arrays*(a1: ptr ErlNifEnv; a2: ptr ErlNifTerm; a3: ptr ErlNifTerm; a4: cuint, a5: ptr ErlNifTerm): bool 
## enif_make_map_put
proc enif_make_map_put*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ErlNifTerm; a4: ErlNifTerm; a5: ptr ErlNifTerm): bool 
## enif_get_map_value
proc enif_get_map_value*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ErlNifTerm; a4: ptr ErlNifTerm): bool 
## enif_make_map_update
proc enif_make_map_update*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ErlNifTerm; a4: ErlNifTerm; a5: ptr ErlNifTerm): bool 
## enif_make_map_remove
proc enif_make_map_remove*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: ErlNifTerm; a4: ptr ErlNifTerm): bool 
## enif_open_resource_type
proc enif_open_resource_type*(a1: ptr ErlNifEnv, a2: typeof(nil); a3: cstring, a4: pointer; a5: ErlNifResourceFlags; a6: ptr ErlNifResourceFlags): ptr ErlNifResourceType 
## enif_open_resource_type
proc enif_open_resource_type*(a1: ptr ErlNifEnv; a2: cstring; a3: ErlNifResourceFlags; a4: ptr ErlNifResourceFlags): ptr ErlNifResourceType
## enif_open_resource_type
proc enif_open_resource_type*(a1: ptr ErlNifEnv; a2: cstring; a3: ErlNifResourceFlags): ptr ErlNifResourceType
## enif_alloc_resource
proc enif_alloc_resource*(a1: pointer; a2: csize_t): pointer 
## enif_release_resource
proc enif_release_resource*(a1: pointer): void 
## enif_make_resource
proc enif_make_resource*(a1: ptr ErlNifEnv; a2: pointer): ErlNifTerm 
## enif_get_resource
proc enif_get_resource*(a1: ptr ErlNifEnv; a2: ErlNifTerm; a3: pointer; a4: pointer): bool 
## enif_consume_timeslice
proc enif_consume_timeslice*(a1: ptr ErlNifEnv; a2: cint): bool 
## enif_schedule_nif
proc enif_schedule_nif*(a1: ptr ErlNifEnv; a2: cstring; a3: cint; a4: NifFunc; a5: cint; a6: ErlNifArgs): ErlNifTerm 
## enif_schedule_nif
proc enif_schedule_nif*(a1: ptr ErlNifEnv; a2: cstring; a3: cint; a4: NifFunc; a5: openArray[ErlNifTerm]): ErlNifTerm
## enif_schedule_nif
proc enif_schedule_nif*(a1: ptr ErlNifEnv; a2: NifFunc; a3: openArray[ErlNifTerm]): ErlNifTerm

