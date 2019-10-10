#!/bin/sh

ERL_LIB="/usr/lib/erlang/usr/include"
NIM_BUILD_IN="nif.nim"
NIM_BUILD_OUT="nif.so"
ELIXIR_TEST_IN="niftest.exs"

echo "building nim nif"

# nim c \
# --verbosity:0 \
# --forceBuild \
# --gc:none \
# --noMain \
# --app:lib \
# --define:release \
# --define:noSignalHandler \
# --cincludes:$ERL_LIB \
# --out:$NIM_BUILD_OUT \
# $NIM_BUILD_IN

nim c \
--verbosity:0 \
--hints:off \
--warnings:off \
--forceBuild \
--gc:none \
--noMain \
--app:lib \
--cincludes:$ERL_LIB \
--out:$NIM_BUILD_OUT \
$NIM_BUILD_IN

echo "running elixir test"

elixir $ELIXIR_TEST_IN

