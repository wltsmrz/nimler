
Nimler can generate an Elixir wrapper at compile time. Given the following NIF:

```nim tab="NumberAdder.nim"
import nimler
import nimler/codec

using
  env: ptr ErlNifEnv
  argc: cint
  argv: ErlNifArgs

func add_numbers(env; argc; argv): ErlNifTerm {.nif: 2, raises: [].} =
  let a1 = env.from_term(argv[0], int32).get(0)
  let a2 = env.from_term(argv[1], int32).get(0)
  let r = a1 + a2
  return env.to_term(r)

export_nifs("Elixir.NumberAdder", [add_numbers])
```

Compiling with:

```bash
nim c --app:lib --noMain --gc:arc -d:nimlerGenModule NumberAdder.nim
```

will produce `libNumberAdder.so` and `NumberAdder.ex`. The name of the target Elixir module, and its filename, is based on the module name as exported from nimler (`Elixir.NumberAdder`) and not the name of the .nim source file.

The target directory is the same as the .nim source. i.e., `-o` nim compile flag affects the destination of generated Elixir module.

By default, an existing Elixir module of the same filename is not overwritten. Pass `-d:nimlerGenModuleForce` to force generating Elixir module.

