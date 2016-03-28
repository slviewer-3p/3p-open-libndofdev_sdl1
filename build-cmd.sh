#!/bin/bash

TOP="$(dirname "$0")"

# turn on verbose debugging output for parabuild logs.
set -x
# make errors fatal
set -e
# complain about unset env variables
set -u

PROJECT="libndofdev"
# 2nd line of CHANGELOG is most recent version number:
#         * 0.3 
# Tease out just the version number from that line.
VERSION="$(expr "$(sed -n 2p "$TOP/$PROJECT/CHANGELOG")" : ".* \([0-9]*\.[0-9]*\) *$")"
SOURCE_DIR="$PROJECT"

if [ -z "$AUTOBUILD" ] ; then 
    fail
fi

if [ "$OSTYPE" = "cygwin" ] ; then
    autobuild="$(cygpath -u $AUTOBUILD)"
else
    autobuild="$AUTOBUILD"
fi

# load autbuild provided shell functions and variables
set +x
eval "$("$autobuild" source_environment)"
set -x

# set LL_BUILD and friends
set_build_variables convenience Release

stage="$(pwd)"

build=${AUTOBUILD_BUILD_ID:=0}
echo "${VERSION}.${build}" > "${stage}/VERSION.txt"

case "$AUTOBUILD_PLATFORM" in
    windows*|darwin*)
        # Given forking and future development work, it seems unwise to
        # hardcode the actual URL of the current project's libndofdef
        # repository in this message. Try to determine the URL of this
        # libndofdev-linux repository and remove "-linux" as a suggestion.
        fail "Windows/Mac libndofdev is in a separate bitbucket repository\
${repo_url:+ -- try ${repo_url%-linux}}"
    ;;
    linux*)
        opts="-DTARGET_OS_LINUX -m$AUTOBUILD_ADDRSIZE $LL_BUILD"
        cmake ../libndofdev -DCMAKE_CXX_FLAGS="$opts" -DCMAKE_C_FLAGS="$opts" \
            -DCMAKE_OSX_ARCHITECTURES="$AUTOBUILD_CONFIGURE_ARCH" \
            -DWORD_SIZE:STRING=$AUTOBUILD_ADDRSIZE \
            -DCMAKE_BUILD_TYPE:STRING=Release
        make
    ;;
esac

mkdir -p "$stage/include/"
cp "$TOP/$SOURCE_DIR/src/ndofdev_external.h" "$stage/include/"
mkdir -p "$stage/LICENSES"
cp -v "$TOP/$SOURCE_DIR/COPYING"  "$stage/LICENSES/$PROJECT.txt"

pass
