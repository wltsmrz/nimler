#!/bin/sh

ERL_LIB="/usr/lib/erlang/usr/include"

nim c -f --gc:none -d:release --noMain --app:lib --cincludes:$ERL_LIB  -o:nif.so nif.nim && iex niftest.ex
