set -ex

ls -lah
ls -lah qt-build

mkdir -p "$PREFIX/lib/qt5/plugins/platformthemes"
install \
    qt-build/qtbase/plugins/platformthemes/libqgtk3.so \
    "$PREFIX/plugins/platformthemes/libqgtk3.so"
