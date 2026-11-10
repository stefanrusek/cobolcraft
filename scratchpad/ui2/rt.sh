#!/bin/sh
# usage: rt.sh testname  -> builds and runs one client test from repo root
R=/Users/stefanrusek/Code/cobolcraft-lane-client
cd $R/client && make -s lib BUILD=$R/build >/dev/null 2>&1 || { make lib BUILD=$R/build 2>&1 | tail -20; exit 2; }
make -s $R/build/client/tests/$1 BUILD=$R/build 2>&1 | tail -20 || exit 2
cd $R && ./build/client/tests/$1 2>&1 | tail -${2:-30}; echo "exit=$?"
