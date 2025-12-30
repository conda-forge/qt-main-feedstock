#!/bin/sh
set -ex

if [[ "$build_platform" != "$target_platform" ]]; then
  # This flag is used in conjunction with QT_FORCE_BUILD_TOOLS=ON
  # https://github.com/qt/qtbase/commit/acfbe3b7795c741b269fc23ed2c51c5937cd7f4f
  export QT_HOST_PATH="$BUILD_PREFIX"
  CMAKE_ARGS="${CMAKE_ARGS} -DQT_FORCE_BUILD_TOOLS=ON"

  # allows to run qmake on arm64 too: https://doc.qt.io/qt-6/macos.html
  if test `uname` = "Darwin"; then
    CMAKE_ARGS="${CMAKE_ARGS} -DCMAKE_OSX_ARCHITECTURES=x86_64;arm64"
  fi
fi

if [[ $(uname) == "Linux" ]]; then
  CMAKE_ARGS="${CMAKE_ARGS} -DFEATURE_egl=ON -DFEATURE_eglfs=ON -DFEATURE_xcb=ON -DFEATURE_xcb_xlib=ON -DFEATURE_xkbcommon=ON"
  CMAKE_ARGS="${CMAKE_ARGS} -DFEATURE_vulkan=ON"
  CMAKE_ARGS="${CMAKE_ARGS} -DFEATURE_wayland=ON"
fi

if test `uname` = "Darwin"; then
  # else cmake erroneously finds ${SDKROOT}/usr/lib/libnetwork.tbd
  CMAKE_ARGS="${CMAKE_ARGS} -DFWNetworkInternal:FILEPATH=${SDKROOT}/System/Library/Frameworks/Network.framework"
fi

QT_SUBMODULES="qtbase;\
qtdeclarative;\
qtimageformats;\
qtshadertools;\
qtsvg;\
qttools;\
qttranslations;\
qt5compat;\
qtwebchannel;\
qtwebsockets"

cmake -LAH -G "Ninja" ${CMAKE_ARGS} \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_FIND_FRAMEWORK=LAST \
  -DCMAKE_INSTALL_RPATH:STRING=${PREFIX}/lib \
  -DCMAKE_UNITY_BUILD=ON \
  -DCMAKE_UNITY_BUILD_BATCH_SIZE=32 \
  -DINSTALL_BINDIR=lib/qt6/bin \
  -DINSTALL_PUBLICBINDIR=bin \
  -DINSTALL_LIBEXECDIR=lib/qt6 \
  -DINSTALL_DOCDIR=share/doc/qt6 \
  -DINSTALL_ARCHDATADIR=lib/qt6 \
  -DINSTALL_DATADIR=share/qt6 \
  -DINSTALL_INCLUDEDIR=include/qt6 \
  -DINSTALL_MKSPECSDIR=lib/qt6/mkspecs \
  -DINSTALL_EXAMPLESDIR=share/doc/qt6/examples \
  -DFEATURE_system_sqlite=ON \
  -DFEATURE_framework=OFF \
  -DFEATURE_linux_v4l=OFF \
  -DFEATURE_gssapi=OFF \
  -DFEATURE_enable_new_dtags=OFF \
  -DFEATURE_openssl_linked=OFF \
  -DQT_BUILD_SUBMODULES=${QT_SUBMODULES} \
  -B build .
cmake --build build --target install

cd ${PREFIX}
mkdir -p bin
for links in ${SRC_DIR}/build/qt*/user_facing_tool_links.txt
do
  while read _line; do ln -sf $_line; done < ${links}
done
qmake6 --version

# You can find the expected values of these files in the log
# For example Translations will be listed as
# INSTALL_TRANSLATIONSDIR
# This file should be in the location of the user's executable
# for conda, this becomes PREFIX/bin/
# https://doc.qt.io/qt-6/qt-conf.html
cat << EOF >${PREFIX}/bin/qt6.conf
[Paths]
Prefix = ${PREFIX}
Documentation = ${PREFIX}/share/doc/qt6
Headers = ${PREFIX}/include/qt6
Libraries = ${PREFIX}/lib
LibraryExecutables = ${PREFIX}/lib/qt6
Binaries = ${PREFIX}/lib/qt6/bin
Plugins = ${PREFIX}/lib/qt6/plugins
QmlImports = ${PREFIX}/lib/qt6/qml
ArchData = ${PREFIX}/lib/qt6
Data = ${PREFIX}/share/qt6
Translations = ${PREFIX}/share/qt6/translations
Examples = ${PREFIX}/share/doc/qt6/examples
Tests = ${PREFIX}/tests
EOF
