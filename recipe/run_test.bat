@ECHO ON


:: If qt6.conf is not part of the package, it won't work when installed side by side with Qt5.
:: See https://github.com/conda-forge/qt-main-feedstock/issues/99
if not exist %LIBRARY_BIN%\qt6.conf exit 1
if not exist %PREFIX%\qt6.conf exit 1

pushd test

cmake -G"NMake Makefiles" -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" .
if errorlevel 1 exit 1

cmake --build . --config Release
if errorlevel 1 exit 1

ctest -C Release --output-on-failure
if errorlevel 1 exit 1
