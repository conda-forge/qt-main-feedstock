#!/bin/sh
# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/gnuconfig/config.* ./qtwebengine/src/3rdparty/chromium/third_party/nasm/autoconf/helpers
cp $BUILD_PREFIX/share/gnuconfig/config.* ./qtwebengine/src/3rdparty/chromium/third_party/icu/source
cp $BUILD_PREFIX/share/gnuconfig/config.* ./qtwebengine/src/3rdparty/chromium/third_party/sqlite/src
cp $BUILD_PREFIX/share/gnuconfig/config.* ./qtwebengine/src/3rdparty/chromium/third_party/breakpad/breakpad/autotools
cp $BUILD_PREFIX/share/gnuconfig/config.* ./qtwebengine/src/3rdparty/chromium/third_party/farmhash/src

if test "$CONDA_BUILD_CROSS_COMPILATION" = "1"
then
  (
    mkdir -p build_native && cd build_native

    export CC=$CC_FOR_BUILD
    export CXX=$CXX_FOR_BUILD
    export LDFLAGS=${LDFLAGS//$PREFIX/$BUILD_PREFIX}
    export PKG_CONFIG_PATH=${PKG_CONFIG_PATH//$PREFIX/$BUILD_PREFIX}
    export CFLAGS=${CFLAGS//$PREFIX/$BUILD_PREFIX}
    export CXXFLAGS=${CXXFLAGS//$PREFIX/$BUILD_PREFIX}

    # hide host libs
    mkdir -p $BUILD_PREFIX/${HOST}
    mv $BUILD_PREFIX/${HOST} _hidden

    cmake -LAH -G "Ninja" \
      -DCMAKE_PREFIX_PATH=${BUILD_PREFIX} \
      -DCMAKE_IGNORE_PREFIX_PATH="${PREFIX}" \
      -DCMAKE_FIND_FRAMEWORK=LAST \
      -DCMAKE_INSTALL_RPATH:STRING=${BUILD_PREFIX}/lib \
      -DFEATURE_system_sqlite=ON \
      -DFEATURE_framework=OFF \
      -DFEATURE_gssapi=OFF \
      -DFEATURE_qml_animation=OFF \
      -DQT_BUILD_SUBMODULES="qtbase;qtdeclarative;qtshadertools;qttools" \
      -DCMAKE_RANLIB=$BUILD_PREFIX/bin/${CONDA_TOOLCHAIN_BUILD}-ranlib \
      -DFEATURE_opengl=OFF \
      -DFEATURE_linguist=OFF \
      -DCMAKE_INSTALL_PREFIX=${BUILD_PREFIX} \
    ..
    cmake --build . --target install
    mv _hidden $BUILD_PREFIX/${HOST}
  )
  rm -r build_native
  CMAKE_ARGS="${CMAKE_ARGS} -DQT_HOST_PATH=${BUILD_PREFIX} -DQT_FORCE_BUILD_TOOLS=ON -DBUILD_WITH_PCH=OFF"
fi

mkdir build && cd build
cmake -LAH -G "Ninja" ${CMAKE_ARGS} \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_FIND_FRAMEWORK=LAST \
  -DCMAKE_INSTALL_RPATH:STRING=${PREFIX}/lib \
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
  -DFEATURE_gstreamer_gl=OFF \
  -DFEATURE_openssl_linked=ON \
  -DFEATURE_designer=OFF -DFEATURE_linguist=OFF \
  -DQT_BUILD_SUBMODULES="qtbase;\
qtdeclarative;\
qtimageformats;\
qtmultimedia;\
qtnetworkauth;\
qtpositioning;\
qtscxml;\
qtsensors;\
qtserialport;\
qtshadertools;\
qtsvg;\
qttools;\
qttranslations;\
qtwebchannel;\
qtwebsockets" \
  ..
cmake --build . --target install

cd ${PREFIX}
mkdir -p bin
for links in ${SRC_DIR}/build/qt*/user_facing_tool_links.txt
do
  while read _line; do ln -sf $_line; done < ${links}
done
