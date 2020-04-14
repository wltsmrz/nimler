# nimler

Nimler is a library for authoring Erlang and Elixir NIFs in the nim programming language. It has mostly complete bindings for the Erlang NIF API and some accessories for making writing NIFs easier, including idiomatic functions for converting between Erlang terms and nim types, and simplifications for using resource objects.

## Build status

| Target               | Status                                                                 |
|----------------------|------------------------------------------------------------------------|
| x86_64<sub>[0]</sub> | ![](https://github.com/wltsmrz/nimler/workflows/build-x64/badge.svg)   |
| arm64<sub>[1]</sub>  | ![](https://github.com/wltsmrz/nimler/workflows/build-arm64/badge.svg) |

<sub>[0]</sub> ubuntu 18.04 github runner / nimler release build, --gc:arc

<sub>[1]</sub> ubuntu 18.04 github runner / nimler release build cross-compiled for arm64, --gc:arc / elixir arm64v8 docker

## Installation

Nimler requires nim version 1.2.x.  Follow nim [<ins>installation guide</ins>](https://nim-lang.org/install.html).

```bash
$ nim --version
# Nim Compiler Version 1.2.0 [Linux: amd64]
# Compiled at 2020-04-03
# Copyright (c) 2006-2020 by Andreas Rumpf

# active boot switches: -d:release
```

Install nimler with nim's de-facto package manager, `nimble`.

```bash
$ nimble install nimler
```

## Running tests

```bash
$ git clone git@github.com:wltsmrz/nimler.git
$ cd nimler
$ nimble build_all # build all test NIFs
$ nimble test_all # run tests
```

## Documentation

Docs site is [here](https://wltsmrz.github.io/nimler/)
