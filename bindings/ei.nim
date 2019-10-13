
type
  erlang_char_encoding* = enum
    ERLANG_ASCII = 1, ERLANG_LATIN1 = 2, ERLANG_UTF8 = 4
  erlang_pid* {.bycopy.} = object
    node*: array[(255 * 4 + 1), char]
    num*: cuint
    serial*: cuint
    creation*: cuint
  UNION1* {.bycopy.} = object {.union.}
    i_val*: clong
    d_val*: cdouble
    atom_name*: array[(255 * 4 + 1), char]
    pid*: erlang_pid
    port*: erlang_port
    `ref`*: erlang_ref
  erlang_port* {.bycopy.} = object
    node*: array[(255 * 4 + 1), char]
    id*: cuint
    creation*: cuint
  erlang_ref* {.bycopy.} = object
    node*: array[(255 * 4 + 1), char]
    len*: cint
    n*: array[3, cuint]
    creation*: cuint
  erlang_big* {.bycopy.} = object
    arity*: cuint
    is_neg*: cint
    digits*: pointer
  ei_term* {.bycopy.} = object
    ei_type*: char
    arity*: cint
    size*: cint
    value*: UNION1
  ei_x_buff* {.bycopy.} = object
    buff*: cstring
    buffsz*: cint
    index*: cint

proc ei_encode_version*(buf: cstring; index: ptr cint): cint {.header: "ei.h", importc: "ei_encode_version".}
proc ei_encode_long*(buf: cstring; index: ptr cint; p: clong): cint {.header: "ei.h", importc: "ei_encode_long".}
proc ei_x_encode_long*(x: ptr ei_x_buff; n: clong): cint {.header: "ei.h", importc: "ei_x_encode_long".}
proc ei_encode_ulong*(buf: cstring; index: ptr cint; p: culong): cint {.header: "ei.h", importc: "ei_encode_ulong".}
proc ei_x_encode_ulong*(x: ptr ei_x_buff; n: culong): cint {.header: "ei.h", importc: "ei_x_encode_ulong".}
proc ei_encode_double*(buf: cstring; index: ptr cint; p: cdouble): cint {.header: "ei.h", importc: "ei_encode_double".}
proc ei_x_encode_double*(x: ptr ei_x_buff; dbl: cdouble): cint {.header: "ei.h", importc: "ei_x_encode_double".}
proc ei_encode_boolean*(buf: cstring; index: ptr cint; p: cint): cint {.header: "ei.h", importc: "ei_encode_boolean".}
proc ei_x_encode_boolean*(x: ptr ei_x_buff; p: cint): cint {.header: "ei.h", importc: "ei_x_encode_boolean".}
proc ei_encode_char*(buf: cstring; index: ptr cint; p: char): cint {.header: "ei.h", importc: "ei_encode_char".}
proc ei_x_encode_char*(x: ptr ei_x_buff; p: char): cint {.header: "ei.h", importc: "ei_x_encode_char".}
proc ei_encode_string*(buf: cstring; index: ptr cint; p: cstring): cint {.header: "ei.h", importc: "ei_encode_string".}
proc ei_encode_string_len*(buf: cstring; index: ptr cint; p: cstring; len: cint): cint {.header: "ei.h", importc: "ei_encode_string_len".}
proc ei_x_encode_string*(x: ptr ei_x_buff; s: cstring): cint {.header: "ei.h", importc: "ei_x_encode_string".}
proc ei_x_encode_string_len*(x: ptr ei_x_buff; s: cstring; len: cint): cint {.header: "ei.h", importc: "ei_x_encode-string_len".}
proc ei_encode_atom*(buf: cstring; index: ptr cint; p: cstring): cint {.header: "ei.h", importc: "ei_encode_atom".}
proc ei_encode_atom_as*(buf: cstring; index: ptr cint; p: cstring; `from`: erlang_char_encoding; to: erlang_char_encoding): cint {.header: "ei.h", importc: "ei_encode_atom_as".}
proc ei_encode_atom_len*(buf: cstring; index: ptr cint; p: cstring; len: cint): cint {.header: "ei.h", importc: "ei_encode_atom_len".}
proc ei_encode_atom_len_as*(buf: cstring; index: ptr cint; p: cstring; len: cint; `from`: erlang_char_encoding; to: erlang_char_encoding): cint {.header: "ei.h", importc: "ei_encode_atom_len_as".}
proc ei_x_encode_atom*(x: ptr ei_x_buff; s: cstring): cint {.header: "ei.h", importc: "ei_x_encode_atom".}
proc ei_x_encode_atom_as*(x: ptr ei_x_buff; s: cstring; `from`: erlang_char_encoding; to: erlang_char_encoding): cint {.header: "ei.h", importc: "ei_x_encode_atom_as".}
proc ei_x_encode_atom_len*(x: ptr ei_x_buff; s: cstring; len: cint): cint {.header: "ei.h", importc: "ei_x_encode_atom_len".}
proc ei_x_encode_atom_len_as*(x: ptr ei_x_buff; s: cstring; len: cint; `from`: erlang_char_encoding; to: erlang_char_encoding): cint {.header: "ei.h", importc: "ei_x_encode_atom_len_as".}
proc ei_encode_binary*(buf: cstring; index: ptr cint; p: pointer; len: clong): cint {.header: "ei.h", importc: "ei_encode_binary".}
proc ei_encode_bitstring*(buf: cstring; index: ptr cint; p: cstring; bitoffs: csize; bits: csize): cint {.header: "ei.h", importc: "ei_encode_bitstring".}
proc ei_x_encode_binary*(x: ptr ei_x_buff; s: pointer; len: cint): cint {.header: "ei.h", importc: "ei_x_encode_binary".}
proc ei_x_encode_bitstring*(x: ptr ei_x_buff; p: cstring; bitoffs: csize; bits: csize): cint {.header: "ei.h", importc: "ei_x_encode_bitstring".}
proc ei_encode_pid*(buf: cstring; index: ptr cint; p: ptr erlang_pid): cint {.header: "ei.h", importc: "ei_encode_pid".}
proc ei_x_encode_pid*(x: ptr ei_x_buff; pid: ptr erlang_pid): cint {.header: "ei.h", importc: "ei_x_encode_pid".}
proc ei_encode_port*(buf: cstring; index: ptr cint; p: ptr erlang_port): cint {.header: "ei.h", importc: "ei_encode_port".}
proc ei_x_encode_port*(x: ptr ei_x_buff; p: ptr erlang_port): cint {.header: "ei.h", importc: "ei_x_encode_port".}
proc ei_encode_ref*(buf: cstring; index: ptr cint; p: ptr erlang_ref): cint {.header: "ei.h", importc: "ei_encode_ref".}
proc ei_x_encode_ref*(x: ptr ei_x_buff; p: ptr erlang_ref): cint {.header: "ei.h", importc: "ei_x_encode_ref".}
proc ei_encode_term*(buf: cstring; index: ptr cint; t: pointer): cint {.header: "ei.h", importc: "ei_encode_term".}
proc ei_x_encode_term*(x: ptr ei_x_buff; t: pointer): cint {.header: "ei.h", importc: "ei_x_encode_term".}
proc ei_encode_tuple_header*(buf: cstring; index: ptr cint; arity: cint): cint {.header: "ei.h", importc: "ei_encode_tuple_header".}
proc ei_x_encode_tuple_header*(x: ptr ei_x_buff; n: clong): cint {.header: "ei.h", importc: "ei_x_encode_tuple_header".}
proc ei_encode_list_header*(buf: cstring; index: ptr cint; arity: cint): cint {.header: "ei.h", importc: "ei_encode_list_header".}
proc ei_x_encode_list_header*(x: ptr ei_x_buff; n: clong): cint {.header: "ei.h", importc: "ei_x_encode_list_header".}
proc ei_x_encode_empty_list*(x: ptr ei_x_buff): cint {.header: "ei.h", importc: "ei_x_encode_empty_list".}
proc ei_encode_map_header*(buf: cstring; index: ptr cint; arity: cint): cint {.header: "ei.h", importc: "ei_encode_map_header".}
proc ei_x_encode_map_header*(x: ptr ei_x_buff; n: clong): cint {.header: "ei.h", importc: "ei_x_encode_map_header".}
proc ei_get_type*(buf: cstring; index: ptr cint; `type`: ptr cint; size: ptr cint): cint {.header: "ei.h", importc: "ei_get_type".}
proc ei_decode_version*(buf: cstring; index: ptr cint; version: ptr cint): cint {.header: "ei.h", importc: "ei_decode_version".}
proc ei_decode_long*(buf: cstring; index: ptr cint; p: ptr clong): cint {.header: "ei.h", importc: "ei_decode_long".}
proc ei_decode_ulong*(buf: cstring; index: ptr cint; p: ptr culong): cint {.header: "ei.h", importc: "ei_decode_ulong".}
proc ei_decode_double*(buf: cstring; index: ptr cint; p: ptr cdouble): cint {.header: "ei.h", importc: "ei_decode_double".}
proc ei_decode_boolean*(buf: cstring; index: ptr cint; p: ptr cint): cint {.header: "ei.h", importc: "ei_decode_boolean".}
proc ei_decode_char*(buf: cstring; index: ptr cint; p: cstring): cint {.header: "ei.h", importc: "ei_decode_char".}
proc ei_decode_string*(buf: cstring; index: ptr cint; p: cstring): cint {.header: "ei.h", importc: "ei_decode_string".}
proc ei_decode_atom*(buf: cstring; index: ptr cint; p: cstring): cint {.header: "ei.h", importc: "ei_decode_atom".}
proc ei_decode_atom_as*(a1: cstring; a2: ptr cint; a3: cstring; a4: cint; a5: erlang_char_encoding; a6: ptr erlang_char_encoding; a7: ptr erlang_char_encoding): cint {.header: "ei.h", importc: "ei_decode_atom_as".}
proc ei_decode_binary*(buf: cstring; index: ptr cint; p: pointer; len: ptr clong): cint {.header: "ei.h", importc: "ei_decode_binary".}
proc ei_decode_bitstring*(buf: cstring; index: ptr cint; pp: cstringArray; bitoffsp: ptr cuint; nbitsp: ptr csize): cint {.header: "ei.h", importc: "ei_decode_bitstring".}
proc ei_decode_pid*(buf: cstring; index: ptr cint; p: ptr erlang_pid): cint {.header: "ei.h", importc: "ei_decode_pid".}
proc ei_decode_port*(buf: cstring; index: ptr cint; p: ptr erlang_port): cint {.header: "ei.h", importc: "ei_decode_port".}
proc ei_decode_ref*(buf: cstring; index: ptr cint; p: ptr erlang_ref): cint {.header: "ei.h", importc: "ei_decode_ref".}
proc ei_decode_term*(buf: cstring; index: ptr cint; t: pointer): cint {.header: "ei.h", importc: "ei_decode_term".}
proc ei_decode_tuple_header*(buf: cstring; index: ptr cint; arity: ptr cint): cint {.header: "ei.h", importc: "ei_decode_tuple_header".}
proc ei_decode_list_header*(buf: cstring; index: ptr cint; arity: ptr cint): cint {.header: "ei.h", importc: "ei_decode_list_header".}
proc ei_decode_map_header*(buf: cstring; index: ptr cint; arity: ptr cint): cint {.header: "ei.h", importc: "ei_decode_map_header".}
proc ei_decode_ei_term*(buf: cstring; index: ptr cint; term: ptr ei_term): cint {.header: "ei.h", importc: "ei_decode_ei_term".}
proc ei_x_new*(x: ptr ei_x_buff): cint {.header: "ei.h", importc: "ei_x_new".}
proc ei_x_new_with_version*(x: ptr ei_x_buff): cint {.header: "ei.h", importc: "ei_x_new_with_version".}
proc ei_x_free*(x: ptr ei_x_buff): cint {.header: "ei.h", importc: "ei_x_free".}
proc ei_x_append*(x: ptr ei_x_buff; x2: ptr ei_x_buff): cint {.header: "ei.h", importc: "ei_x_append".}
proc ei_x_append_buf*(x: ptr ei_x_buff; buf: cstring; len: cint): cint {.header: "ei.h", importc: "ei_x_append_buf".}
proc ei_skip_term*(buf: cstring; index: ptr cint): cint {.header: "ei.h", importc: "ei_skip_term".}
proc ei_init*(): cint {.header: "ei.h", importc: "ei_init".}
proc ei_decode_longlong*(buf: cstring; index: ptr cint; p: ptr clonglong): cint {.header: "ei.h", importc: "ei_decode_longlong".}
proc ei_decode_ulonglong*(buf: cstring; index: ptr cint; p: ptr culonglong): cint {.header: "ei.h", importc: "ei_decode_ulonglong".}
proc ei_encode_longlong*(buf: cstring; index: ptr cint; p: clonglong): cint {.header: "ei.h", importc: "ei_encode_longlong".}
proc ei_encode_ulonglong*(buf: cstring; index: ptr cint; p: culonglong): cint {.header: "ei.h", importc: "ei_encode_ulonglong".}
proc ei_x_encode_longlong*(x: ptr ei_x_buff; n: clonglong): cint {.header: "ei.h", importc: "ei_x_encode_longlong".}
proc ei_x_encode_ulonglong*(x: ptr ei_x_buff; n: culonglong): cint {.header: "ei.h", importc: "ei_x_encode_ulonglong".}
proc ei_decode_intlist*(buf: cstring; index: ptr cint; a: ptr clong; count: ptr cint): cint {.header: "ei.h", importc: "ei_decode_intlist".}
proc ei_encode_big*(buf: cstring; index: ptr cint; big: ptr erlang_big): cint {.header: "ei.h", importc: "ei_encode_big".}
proc ei_x_encode_big*(x: ptr ei_x_buff; big: ptr erlang_big): cint {.header: "ei.h", importc: "ei_x_encode_big".}
proc ei_decode_big*(buf: cstring; index: ptr cint; p: ptr erlang_big): cint {.header: "ei.h", importc: "ei_decode_big".}
proc ei_big_comp*(x: ptr erlang_big; y: ptr erlang_big): cint {.header: "ei.h", importc: "ei_big_comp".}
proc ei_big_to_double*(b: ptr erlang_big; resp: ptr cdouble): cint {.header: "ei.h", importc: "ei_big_to_double".}
proc ei_small_to_big*(s: cint; b: ptr erlang_big): cint {.header: "ei.h", importc: "ei_small_to_big".}
proc ei_alloc_big*(arity: cuint): ptr erlang_big {.header: "ei.h", importc: "ei_alloc_big".}
proc ei_free_big*(b: ptr erlang_big) {.header: "ei.h", importc: "ei_free_big".}
