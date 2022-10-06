
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

type qtbase\user_facing_tool_links.txt

::xcopy /y /s %LIBRARY_PREFIX%\lib\qt6\bin\*.dll %LIBRARY_PREFIX%\bin
mkdir -p %LIBRARY_PREFIX%\bin
cd %LIBRARY_PREFIX%\bin
for %%x in (3DAnimation 3DCore 3DExtras 3DInput 3DLogic 3DRender Concurrent Core DBus Designer DesignerComponents Gui Help JsonRpc) do mklink Qt6%%x.dll ..\lib\qt6\bin\Qt6%%x.dll
for %%x in (LabsFolderListModel LabsQmlModels LabsSettings LanguageServer Multimedia MultimediaWidgets Network NetworkAuth OpenGL) do mklink Qt6%%x.dll ..\lib\qt6\bin\Qt6%%x.dll
for %%x in (OpenGLWidgets Positioning PrintSupport Qml QmlCompiler QmlCore QmlLocalStorage QmlModels QmlWorkerScript QmlXmlListModel) do mklink Qt6%%x.dll ..\lib\qt6\bin\Qt6%%x.dll
for %%x in (Scxml ScxmlQml Sensors SerialPort ShaderTools SpatialAudio Sql StateMachine StateMachineQml Svg SvgWidgets Test UiTools Widgets Xml) do mklink Qt6%%x.dll ..\lib\qt6\bin\Qt6%%x.dll
mklink qmake6.exe  ..\lib\qt6\bin\qmake.exe
mklink windeployqt6.exe ..\lib\qt6\bin\windeployqt.exe
if errorlevel 1 exit 1


