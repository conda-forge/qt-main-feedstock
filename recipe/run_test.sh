#!/bin/bash

set -e

ls
cd test
cmake .
make
ctest --output-on-failure
make clean
