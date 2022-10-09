
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
set "MODS=%MODS%;qtwebchannel"
set "MODS=%MODS%;qtwebsockets"

mkdir build && cd build

:: have to set path for internal tools: https://bugreports.qt.io/browse/QTBUG-107009
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
    -DFEATURE_quick_particles=OFF -DFEATURE_quick_path=OFF -DFEATURE_qml_network=OFF ^
    -DFEATURE_gstreamer=OFF ^
    -DFEATURE_system_freetype=ON ^
    -DFEATURE_system_sqlite=ON ^
    -DFEATURE_designer=OFF -DFEATURE_linguist=OFF ^
    -DQT_BUILD_SUBMODULES="%MODS%" ^
    ..
if errorlevel 1 exit 1

cmake --build . --target install --config Release
if errorlevel 1 exit 1

:: we set INSTALL_BINDIR != /bin to avoid clobbering qt5 exes but still dlls in /bin
xcopy /y /s %LIBRARY_PREFIX%\lib\qt6\bin\*.dll %LIBRARY_PREFIX%\bin
if errorlevel 1 exit 1

:: symlink public exes with suffix
cd %LIBRARY_PREFIX%\bin
mklink qmake6.exe  ..\lib\qt6\bin\qmake.exe
mklink windeployqt6.exe ..\lib\qt6\bin\windeployqt.exe
if errorlevel 1 exit 1

