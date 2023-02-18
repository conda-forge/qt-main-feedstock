#!/bin/bash
set -ex

# test for presence of sql plugin
test   -f "${PREFIX}/plugins/sqldrivers/libqsqlite${SHLIB_EXT}"
if [[ $(uname) == "Linux" ]]; then
    # gtk3 platform theme only useful for Linux
    test -f "${PREFIX}/plugins/platformthemes/libqgtk3${SHLIB_EXT}"
fi

ls
cd test
ln -s ${GXX} g++
cp ../xcrun .
cp ../xcodebuild .
export PATH=${PWD}:${PATH}
qmake hello.pro
make
./hello
# Only test that this builds
make clean

qmake test_qmimedatabase.pro
make
./test_qmimedatabase
make clean
