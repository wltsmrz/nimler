# nimler

Nimler is a library for authoring Erlang and Elixir NIFs in the nim programming language. It has mostly complete bindings for the Erlang NIF API and some accessories for making writing NIFs easier, including idiomatic functions for converting between Erlang terms and nim types, and simplifications for using resource objects.

Mostly, Nimler is a minimal, zero-dependency wrapper for Erlang NIF API.

## Build status

| Target               | Status                                                                 |
|----------------------|------------------------------------------------------------------------|
| x86_64<sub>[0]</sub> | ![](https://github.com/wltsmrz/nimler/workflows/build-x64/badge.svg)   |
| arm64<sub>[1]</sub>  | ![](https://github.com/wltsmrz/nimler/workflows/build-arm64/badge.svg) |

<sub>[0]</sub> ubuntu 18.04 github runner / nimler release build, --gc:arc

<sub>[1]</sub> ubuntu 18.04 github runner / nimler release build cross-compiled for arm64, --gc:arc / elixir arm64v8 docker

## Installation

Nimler requires nim version 1.2.0+.  See nim [<ins>installation guide</ins>](https://nim-lang.org/install.html).

Install nimler with via nimble:

```bash
$ nimble install nimler
```

## Documentation

Nimler is documented at [smrz.dev/nimler](https://smrz.dev/nimler).

## Running tests

```bash
$ git clone git@github.com:wltsmrz/nimler.git
$ cd nimler
$ nimble build_all # build all test NIFs
$ nimble test_all # run tests
```
