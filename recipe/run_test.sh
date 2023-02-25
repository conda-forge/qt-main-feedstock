#!/bin/bash

set -ex

test -f ${PREFIX}/bin/qt6.conf

test "${HOST}" = "aarch64-conda-linux-gnu" && exit 0

ls
cd test
cmake .
make
ctest --output-on-failure
make clean
