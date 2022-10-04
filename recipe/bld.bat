
set "MODS=qt3d"
set "MODS=%MODS%;qtbase"
set "MODS=%MODS%;qtcharts"
set "MODS=%MODS%;qtdatavis3d"
set "MODS=%MODS%;qtdeclarative"
set "MODS=%MODS%;qtimageformats"
set "MODS=%MODS%;qtmultimedia"
set "MODS=%MODS%;qtnetworkauth"
set "MODS=%MODS%;qtpositioning"
set "MODS=%MODS%;qtscxml"
set "MODS=%MODS%;qtsensors"
set "MODS=%MODS%;qtserialport"
set "MODS=%MODS%;qtshadertools"
set "MODS=%MODS%;qtsvg"
set "MODS=%MODS%;qttools"
set "MODS=%MODS%;qttranslations"

:: disabled gstreamer plugin: https://bugreports.qt.io/browse/QTBUG-107073


mkdir build && cd build

set "PATH=%SRC_DIR%\build\qtbase\lib\qt6\bin;%PATH%"

cmake -LAH -G "Ninja" ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DINSTALL_BINDIR=lib/qt6/bin ^
    -DINSTALL_PUBLICBINDIR=bin ^
    -DINSTALL_LIBEXECDIR=lib/qt6 ^
    -DINSTALL_DOCDIR=share/doc/qt6 ^
    -DINSTALL_ARCHDATADIR=lib/qt6 ^
    -DINSTALL_DATADIR=share/qt6 ^
    -DINSTALL_INCLUDEDIR=include/qt6 ^
    -DINSTALL_MKSPECSDIR=lib/qt6/mkspecs ^
    -DINSTALL_EXAMPLESDIR=share/doc/qt6/examples ^
    -DINSTALL_DATADIR=share/qt6 ^
    -DFEATURE_openssl_linked=ON ^
    -DFEATURE_qml_animation=OFF ^
    -DFEATURE_gstreamer=OFF ^
    -DFEATURE_system_freetype=ON ^
    -DFEATURE_system_sqlite=ON ^
    -DQT_BUILD_SUBMODULES="%MODS%" ^
    ..
if errorlevel 1 exit 1

cmake --build . --target install --config Release
if errorlevel 1 exit 1

xcopy /y /s qtbase\lib\qt6\bin\*.dll %LIBRARY_PREFIX%\bin
if errorlevel 1 exit 1

mkdir -p %LIBRARY_PREFIX%\bin
mklink /h %LIBRARY_PREFIX%\bin\qmake.exe  %LIBRARY_PREFIX%\lib/qt6\bin\qmake.exe
if errorlevel 1 exit 1
