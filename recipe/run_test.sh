#!/bin/bash

set -ex


# If qt6.conf is not part of the package, it won't work when installed side by side with Qt5.
# See https://github.com/conda-forge/qt-main-feedstock/issues/99
test -f ${PREFIX}/bin/qt6.conf

ls
cd test

# cmake
cmake -B build .
make -C build
ctest --test-dir build --output-on-failure
make -C build clean

# qmake
ln -sv ${CXX} ${PREFIX}/bin/g++
export LDFLAGS="-L${PREFIX}/lib"
qmake6 main.pro
