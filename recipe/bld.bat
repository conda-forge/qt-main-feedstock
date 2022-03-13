
mkdir build && cd build
cmake -LAH -G "Ninja" ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DINSTALL_INCLUDEDIR=include/qt6 ^
    -DINSTALL_MKSPECSDIR=lib/qt6/mkspecs ^
    -DINSTALL_DATADIR=share/qt6 ^
    -DQT_BUILD_SUBMODULES="qt3d;qtbase;qtcharts;qtdatavis3d;qtdeclarative;qtimageformats;qtmultimedia;qtnetworkauth;qtremoteobjects;qtshadertools;qtsvg;qttools;qttranslations" ^
    ..
if errorlevel 1 exit 1

cmake --build . --target install --config Release
if errorlevel 1 exit 1

