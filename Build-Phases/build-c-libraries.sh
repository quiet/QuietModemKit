#!/usr/bin/env bash
set -e

ABSPATH=$SRCROOT
SRCPATH=$SRCROOT
SYSROOTPATH="$BUILT_PRODUCTS_DIR/sysroot"
TOPBUILDPATH="$BUILT_PRODUCTS_DIR"
BUILDTYPE="${CONFIGURATION}-${PLATFORM_NAME}"
LIBPATH="$ABSPATH/lib/${BUILDTYPE}/"
INCLUDEPATH="$ABSPATH/include/${BUILDTYPE}/"
LICENSEPATH="$ABSPATH/licenses"

if [ ! -d "$SYSROOTPATH/usr" ]; then
    mkdir -p "$SYSROOTPATH/usr"
fi

export SYSROOT="$SYSROOTPATH/$target"
#export PATH="$ios:$CLANGPATH:$PATH"
BUILDPATH="$TOPBUILDPATH/$target"
mkdir -p "$BUILDPATH"

mkdir -p "$BUILDPATH/libcorrect"
cd "$BUILDPATH/libcorrect"
cmake -DCMAKE_TOOLCHAIN_FILE="$SRCPATH/Build-Phases/apple.toolchain.cmake" -DCMAKE_BUILD_TYPE=Release "$SRCPATH/libcorrect" -DCMAKE_INSTALL_PREFIX="$SYSROOT/usr" && make && make shim && make install

mkdir -p "$BUILDPATH/liquid-dsp"
cd "$BUILDPATH/liquid-dsp"
cmake -DCMAKE_TOOLCHAIN_FILE="$SRCPATH/Build-Phases/apple.toolchain.cmake" -DCMAKE_BUILD_TYPE=Release "$SRCPATH/liquid-dsp" -DCMAKE_INSTALL_PREFIX="$SYSROOT/usr" -DCMAKE_PREFIX_PATH="$SYSROOT" -DCMAKE_SHARED_LINKER_FLAGS="-L$SYSROOT/usr/lib" -DLIQUID_BUILD_EXAMPLES="off" -DLIQUID_BUILD_SANDBOX="off" && make liquid-static liquid-shared && make install

mkdir -p "$BUILDPATH/jansson"
cd "$BUILDPATH/jansson"
cmake -DCMAKE_TOOLCHAIN_FILE="$SRCPATH/Build-Phases/apple.toolchain.cmake" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$SYSROOT/usr" -DJANSSON_BUILD_SHARED_LIBS=on -DJANSSON_WITHOUT_TESTS=on -DJANSSON_EXAMPLES=off -DJANSSON_BUILD_DOCS=off "$SRCPATH/jansson" && make && make install
cmake -DCMAKE_TOOLCHAIN_FILE="$SRCPATH/Build-Phases/apple.toolchain.cmake" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$SYSROOT/usr" -DJANSSON_BUILD_SHARED_LIBS=off -DJANSSON_WITHOUT_TESTS=on -DJANSSON_EXAMPLES=off -DJANSSON_BUILD_DOCS=off "$SRCPATH/jansson" && make && make install

mkdir -p "$BUILDPATH/quiet"
cd "$BUILDPATH/quiet"
cmake -DCMAKE_TOOLCHAIN_FILE="$SRCPATH/Build-Phases/apple.toolchain.cmake" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$SYSROOT/usr" -DCMAKE_PREFIX_PATH="$SYSROOT" "$SRCPATH/quiet" && make && make install

mkdir -p "$BUILDPATH/quiet-lwip"
cd "$BUILDPATH/quiet-lwip"
cmake -DCMAKE_TOOLCHAIN_FILE="$SRCPATH/Build-Phases/apple.toolchain.cmake" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$SYSROOT/usr" -DCMAKE_PREFIX_PATH="$SYSROOT" "$SRCPATH/quiet-lwip" && make && make install

mkdir -p "$LIBPATH"
mkdir -p "$INCLUDEPATH"
# lipo -create -output "$LIBPATH/$1/libfec.a" "$SYSROOTPATH/$1/usr/lib/libfec.a" "$SYSROOTPATH/$1-sim/usr/lib/libfec.a"
# lipo -create -output "$LIBPATH/$1/libliquid.a" "$SYSROOTPATH/$1/usr/lib/libliquid.a" "$SYSROOTPATH/$1-sim/usr/lib/libliquid.a"
# lipo -create -output "$LIBPATH/$1/libjansson.a" "$SYSROOTPATH/$1/usr/lib/libjansson.a" "$SYSROOTPATH/$1-sim/usr/lib/libjansson.a"
# lipo -create -output "$LIBPATH/$1/libquiet.a" "$SYSROOTPATH/$1/usr/lib/libquiet.a" "$SYSROOTPATH/$1-sim/usr/lib/libquiet.a"
cp "$SYSROOTPATH/usr/lib/libfec.a" "$LIBPATH"
cp "$SYSROOTPATH/usr/lib/libliquid.a" "$LIBPATH"
cp "$SYSROOTPATH/usr/lib/libjansson.a" "$LIBPATH"
cp "$SYSROOTPATH/usr/lib/libquiet.a" "$LIBPATH"
cp "$SYSROOTPATH/usr/lib/libquiet_lwip.a" "$LIBPATH"
cp "$SYSROOTPATH/usr/include/fec.h" "$INCLUDEPATH"
cp -R "$SYSROOTPATH/usr/include/liquid" "$INCLUDEPATH"
cp "$SYSROOTPATH/usr/include/jansson.h" "$INCLUDEPATH"
cp "$SYSROOTPATH/usr/include/jansson_config.h" "$INCLUDEPATH"
cp "$SYSROOTPATH/usr/include/quiet.h" "$INCLUDEPATH"
cp -R "$SYSROOTPATH/usr/include/quiet-lwip" "$INCLUDEPATH"


#cp "$SYSROOTPATH/usr/include/quiet.h" "$PUBLIC_HEADERS_FOLDER_PATH"


mkdir -p "$LICENSEPATH"
cp "$SRCPATH/libcorrect/LICENSE" "$LICENSEPATH/libcorrect"
cp "$SRCPATH/liquid-dsp/LICENSE" "$LICENSEPATH/liquid-dsp"
cp "$SRCPATH/jansson/LICENSE" "$LICENSEPATH/jansson"
cp "$SRCPATH/quiet/LICENSE" "$LICENSEPATH/quiet"
cp "$SRCPATH/quiet-lwip/LICENSE" "$LICENSEPATH/quiet-lwip"

echo
echo "Build complete. Built libraries are in $LIBPATH"
echo "and includes in $INCLUDEPATH. Third-party licenses"
echo "are in $LICENSEPATH."
