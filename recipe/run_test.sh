#!/bin/bash

set -ex


# If qt6.conf is not part of the package, it won't work when installed side by side with Qt5.
# See https://github.com/conda-forge/qt-main-feedstock/issues/99
test -f ${PREFIX}/bin/qt6.conf

ls
cd test
cmake .
make
ctest --output-on-failure
make clean
