
set "MODS=qtbase"
set "MODS=%MODS%;qtdeclarative"
set "MODS=%MODS%;qtimageformats"
set "MODS=%MODS%;qtshadertools"
set "MODS=%MODS%;qtsvg"
set "MODS=%MODS%;qttools"
set "MODS=%MODS%;qttranslations"
set "MODS=%MODS%;qt5compat"
set "MODS=%MODS%;qtwebchannel"
set "MODS=%MODS%;qtwebsockets"

:: Support systems with neither capable OpenGL (desktop mode) nor DirectX 11 (ANGLE mode) drivers
:: https://github.com/ContinuumIO/anaconda-issues/issues/9142
if not exist "%LIBRARY_BIN%" mkdir "%LIBRARY_BIN%"
copy opengl32sw\opengl32sw.dll  %LIBRARY_BIN%\opengl32sw.dll
if errorlevel 1 exit /b 1
if not exist %LIBRARY_BIN%\opengl32sw.dll exit /b 1

set OPENGLVER=dynamic

:: have to set path for internal tools: https://bugreports.qt.io/browse/QTBUG-107009
set "PATH=%SRC_DIR%\build\qtbase\bin;%PATH%"

cmake -LAH -G "Ninja" ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DCMAKE_UNITY_BUILD=ON -DCMAKE_UNITY_BUILD_BATCH_SIZE=32 ^
    -DINSTALL_BINDIR=bin ^
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
    -DFEATURE_system_freetype=ON ^
    -DFEATURE_system_sqlite=ON ^
    -DFEATURE_vulkan=ON ^
    -DINPUT_opengl=%OPENGLVER% ^
    -DQT_BUILD_SUBMODULES="%MODS%" ^
    -DQT_CREATE_VERSIONED_HARD_LINK=OFF ^
    -B build .
if errorlevel 1 exit 1

cmake --build build --target install --config Release
if errorlevel 1 exit 1

:: we move exes in bin/qt6 to avoid clobbering qt5 exes
mkdir %LIBRARY_BIN%\qt6
move %LIBRARY_BIN%\*.exe %LIBRARY_BIN%\qt6
if errorlevel 1 exit 1

:: link public exe with a script
for %%F in (qmake qtpaths qtdiag androiddeployqt windeployqt) do (
    echo @echo off > %LIBRARY_BIN%\%%F6.bat
    echo %%~dp0..\bin\qt6\%%F.exe %%* >> %LIBRARY_BIN%\%%F6.bat
    type %LIBRARY_BIN%\%%F6.bat
)

:: You can find the expected values of these files in the log
:: For example Translations will be listed as
:: INSTALL_TRANSLATIONSDIR
:: This file should be in the location of the user's executable
:: for conda, this becomes LIBRARY_BIN
:: https://doc.qt.io/qt-6/qt-conf.html
echo [Paths]                                                     > %LIBRARY_BIN%\qt6.conf
echo Prefix = %PREFIX:\=/%                                      >> %LIBRARY_BIN%\qt6.conf
echo Documentation = %LIBRARY_PREFIX:\=/%/share/doc/qt6         >> %LIBRARY_BIN%\qt6.conf
echo Headers = %LIBRARY_INC:\=/%/qt6                            >> %LIBRARY_BIN%\qt6.conf
echo Libraries = %LIBRARY_LIB:\=/%                              >> %LIBRARY_BIN%\qt6.conf
echo LibraryExecutables = %LIBRARY_LIB:\=/%/qt6                 >> %LIBRARY_BIN%\qt6.conf
echo Binaries = %LIBRARY_BIN:\=/%/qt6                           >> %LIBRARY_BIN%\qt6.conf
echo Plugins = %LIBRARY_LIB:\=/%/qt6/plugins                    >> %LIBRARY_BIN%\qt6.conf
echo QmlImports = %LIBRARY_LIB:\=/%/qt6/qml                     >> %LIBRARY_BIN%\qt6.conf
echo ArchData = %LIBRARY_LIB:\=/%/qt6                           >> %LIBRARY_BIN%\qt6.conf
echo Data = %LIBRARY_PREFIX:\=/%/share/qt6                      >> %LIBRARY_BIN%\qt6.conf
echo Translations = %LIBRARY_PREFIX:\=/%/share/qt6/translations >> %LIBRARY_BIN%\qt6.conf
echo Examples = %LIBRARY_PREFIX:\=/%/share/doc/qt6/examples     >> %LIBRARY_BIN%\qt6.conf
echo Tests = %LIBRARY_PREFIX:\=/%/tests                         >> %LIBRARY_BIN%\qt6.conf
echo HostData = %LIBRARY_PREFIX:\=/%/lib/qt6                    >> %LIBRARY_BIN%\qt6.conf
echo HostBinaries = %LIBRARY_BIN:\=/%/qt6                       >> %LIBRARY_BIN%\qt6.conf
echo HostLibraryExecutables = %LIBRARY_LIB:\=/%/qt6             >> %LIBRARY_BIN%\qt6.conf
echo HostLibraries = %LIBRARY_LIB:\=/%                          >> %LIBRARY_BIN%\qt6.conf
:: Some things go looking in the prefix root (pyqt, for example)
copy "%LIBRARY_BIN%\qt6.conf" "%PREFIX%\qt6.conf"
