#!/bin/sh
set -ex


if [[ "$CONDA_BUILD_CROSS_COMPILATION" = "1" ]]; then
  if [[ "${build_platform}" == "linux-64" ]]; then
    # There are probably equivalent CDTs to install if your build platform
    # is something else. However, it is most common in 2023 to use the x86_64
    # hardware to cross compile for other architectures.
    mamba install --yes \
      --prefix ${BUILD_PREFIX} \
      mesa-libgl-devel-${cdt_name}-x86_64  \
      mesa-libegl-devel-${cdt_name}-x86_64 \
      mesa-dri-drivers-${cdt_name}-x86_64  \
      libdrm-devel-${cdt_name}-x86_64 \
      libglvnd-glx-${cdt_name}-x86_64 \
      libglvnd-egl-${cdt_name}-x86_64
  fi
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
      -DCMAKE_UNITY_BUILD=ON -DCMAKE_UNITY_BUILD_BATCH_SIZE=32 \
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

  # Error: unknown architecture `nocona' on linux-aarch64
  if test "${target_platform}" = "linux-aarch64"
  then
    CFLAGS=${CFLAGS// -march=nocona/}
    CXXFLAGS=${CXXFLAGS// -march=nocona/}
  fi
fi

if [[ $(uname) == "Linux" ]]; then
  CMAKE_ARGS="${CMAKE_ARGS} -DFEATURE_egl=ON -DFEATURE_eglfs=ON"
fi

mkdir build && cd build
cmake -LAH -G "Ninja" ${CMAKE_ARGS} \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_FIND_FRAMEWORK=LAST \
  -DCMAKE_INSTALL_RPATH:STRING=${PREFIX}/lib \
  -DCMAKE_UNITY_BUILD=ON -DCMAKE_UNITY_BUILD_BATCH_SIZE=32 \
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
  -DFEATURE_quick3d_assimp=OFF \
  -DQT_BUILD_SUBMODULES="qtbase;\
qtdeclarative;\
qtimageformats;\
qtmultimedia;\
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
