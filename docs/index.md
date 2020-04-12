# Getting Started

## Introduction

Nimler is a library for authoring Erlang and Elixir NIFs in the nim programming language. It has mostly complete [bindings](https://github.com/wltsmrz/nimler/blob/develop/nimler/bindings/erl_nif.nim) for the Erlang [NIF API](http://erlang.org/doc/man/erl_nif.html) and some accessories for making writing NIFs easier, including idiomatic functions for converting between Erlang terms and nim types, and simplifications for using resource objects.

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

## Testing

Nimler tests are Elixir NIFs. A local installation of elixir is required to run tests.  Automated tests are run via github actions on ubuntu.

```bash
$ git clone git@github.com:wltsmrz/nimler.git
$ cd nimler
$ nimble build_all # build all test NIFs
$ nimble test_all # run tests
```

