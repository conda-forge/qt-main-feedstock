pushd test

cmake -G"NMake Makefiles" -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" .
if errorlevel 1 exit 1

cmake --build . --config Release
if errorlevel 1 exit 1

ctest -C Release --output-on-failure
if errorlevel 1 exit 1
