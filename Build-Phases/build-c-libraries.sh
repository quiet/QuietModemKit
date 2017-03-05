#!/usr/bin/env bash
set -e

ABSPATH=$SRCROOT
SRCPATH=$SRCROOT
SYSROOTPATH="$BUILD_DIR/sysroot"
TOPBUILDPATH="$BUILD_DIR"
LIBPATH="$ABSPATH/ios/lib"
INCLUDEPATH="$ABSPATH/ios/include"
LICENSEPATH="$ABSPATH/ios/licenses"

if [ ! -d "$SYSROOTPATH/usr" ]; then
    mkdir -p "$SYSROOTPATH/usr"
fi


        export SYSROOT="$SYSROOTPATH/$target"
        #export PATH="$ios:$CLANGPATH:$PATH"
        BUILDPATH="$TOPBUILDPATH/$target"
        mkdir -p "$BUILDPATH"

        rm -rf "$BUILDPATH/libcorrect"
        mkdir -p "$BUILDPATH/libcorrect"
        cd "$BUILDPATH/libcorrect"
        cmake -DCMAKE_TOOLCHAIN_FILE="$SRCPATH/Build-Phases/apple.toolchain.cmake" -DCMAKE_BUILD_TYPE=Release "$SRCPATH/libcorrect" -DCMAKE_INSTALL_PREFIX="$SYSROOT/usr" && make && make shim && make install

        rm -rf "$BUILDPATH/liquid-dsp"
        mkdir -p "$BUILDPATH/liquid-dsp"
        cd "$BUILDPATH/liquid-dsp"
        cmake -DCMAKE_TOOLCHAIN_FILE="$SRCPATH/Build-Phases/apple.toolchain.cmake" -DCMAKE_BUILD_TYPE=Release "$SRCPATH/liquid-dsp" -DCMAKE_INSTALL_PREFIX="$SYSROOT/usr" -DCMAKE_PREFIX_PATH="$SYSROOT" -DCMAKE_SHARED_LINKER_FLAGS="-L$SYSROOT/usr/lib" -DLIQUID_BUILD_EXAMPLES="off" -DLIQUID_BUILD_SANDBOX="off" && make liquid-static liquid-shared && make install

        rm -rf "$BUILDPATH/jansson"
        mkdir -p "$BUILDPATH/jansson"
        cd "$BUILDPATH/jansson"
        cmake -DCMAKE_TOOLCHAIN_FILE="$SRCPATH/Build-Phases/apple.toolchain.cmake" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$SYSROOT/usr" -DJANSSON_BUILD_SHARED_LIBS=on "$SRCPATH/jansson" && make && make install
        cmake -DCMAKE_TOOLCHAIN_FILE="$SRCPATH/Build-Phases/apple.toolchain.cmake" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$SYSROOT/usr" -DJANSSON_BUILD_SHARED_LIBS=off "$SRCPATH/jansson" && make && make install

        rm -rf "$BUILDPATH/quiet"
        mkdir -p "$BUILDPATH/quiet"
        cd "$BUILDPATH/quiet"
        cmake -DCMAKE_TOOLCHAIN_FILE="$SRCPATH/Build-Phases//apple.toolchain.cmake" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$SYSROOT/usr" -DCMAKE_PREFIX_PATH="$SYSROOT" "$SRCPATH/quiet" && make && make install

        exit 0

    mkdir -p "$LIBPATH/$1"
    mkdir -p "$INCLUDEPATH/$1"
    case "$1" in
        ios | tv | watch)
            lipo -create -output "$LIBPATH/$1/libfec.a" "$SYSROOTPATH/$1/usr/lib/libfec.a" "$SYSROOTPATH/$1-sim/usr/lib/libfec.a"
            lipo -create -output "$LIBPATH/$1/libliquid.a" "$SYSROOTPATH/$1/usr/lib/libliquid.a" "$SYSROOTPATH/$1-sim/usr/lib/libliquid.a"
            lipo -create -output "$LIBPATH/$1/libjansson.a" "$SYSROOTPATH/$1/usr/lib/libjansson.a" "$SYSROOTPATH/$1-sim/usr/lib/libjansson.a"
            lipo -create -output "$LIBPATH/$1/libquiet.a" "$SYSROOTPATH/$1/usr/lib/libquiet.a" "$SYSROOTPATH/$1-sim/usr/lib/libquiet.a"
            ;;
        osx)
            cp "$SYSROOTPATH/$1/usr/lib/libfec.a" "$LIBPATH/$1/libfec.a"
            cp "$SYSROOTPATH/$1/usr/lib/libliquid.a" "$LIBPATH/$1/libliquid.a"
            cp "$SYSROOTPATH/$1/usr/lib/libjansson.a" "$LIBPATH/$1/libjansson.a"
            cp "$SYSROOTPATH/$1/usr/lib/libquiet.a" "$LIBPATH/$1/libquiet.a"
            ;;
    esac
    cp "$SYSROOTPATH/$1/usr/include/fec.h" "$INCLUDEPATH/$1"
    cp -R "$SYSROOTPATH/$1/usr/include/liquid" "$INCLUDEPATH/$1"
    cp "$SYSROOTPATH/$1/usr/include/jansson.h" "$INCLUDEPATH/$1"
    cp "$SYSROOTPATH/$1/usr/include/jansson_config.h" "$INCLUDEPATH/$1"
    cp "$SYSROOTPATH/$1/usr/include/quiet.h" "$INCLUDEPATH/$1"



mkdir -p "$LICENSEPATH"
cp "$SRCPATH/libcorrect/LICENSE" "$LICENSEPATH/libcorrect"
cp "$SRCPATH/liquid-dsp/LICENSE" "$LICENSEPATH/liquid-dsp"
cp "$SRCPATH/jansson/LICENSE" "$LICENSEPATH/jansson"
cp "$SRCPATH/quiet/LICENSE" "$LICENSEPATH/quiet"

echo
echo "Build complete. Built libraries are in $LIBPATH"
echo "and includes in $INCLUDEPATH. Third-party licenses"
echo "are in $LICENSEPATH."
