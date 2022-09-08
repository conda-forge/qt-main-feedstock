#!/bin/bash

set -e

test "${HOST}" = "aarch64-conda-linux-gnu" && exit 0

ls
cd test
cmake .
make
ctest --output-on-failure
make clean
