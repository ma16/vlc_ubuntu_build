#!/bin/bash -ex

if [[ $# -ne 3 ]] ; then
  echo "arguments: download-dir patch-dir install-dir" 1>&2
  exit -1
fi 

DOWNLOADS=$(readlink -f $1)
PATCHES=$(readlink -f $2)
INST=$(readlink -f $3)
VLC="$PWD/vlc-2.2.4"
CONTRIB="$VLC/contrib"

# you may want to enable parallel makes..
export MAKEFLAGS="$MAKEFLAGS"

rm -fr vlc-2.2.4
tar xf "$DOWNLOADS/vlc-2.2.4.tar.xz"

# make extras.tools; build time ~4m (4cores)
cd "$VLC/extras/tools"
for f in `cat "$PATCHES/extras.tools/files.download"` ; do ln -s "$DOWNLOADS/$f" . ; done
./bootstrap
make m4
patch -p1 m4/lib/stdio.in.h "$PATCHES/extras.tools/patch.m4.lib.stdio.in.h"
patch -p1 tools.mak "$PATCHES/extras.tools/patch.tools.mak"
make

# make contrib.xorg (kernel support required); build time ~15m (1core)
cd "$INST" && rm -fr x86_64-linux-gnu
cd "$CONTRIB" && rm -fr xorg && mkdir xorg && cd xorg
ln -s "$PATCHES/contrib.xorg/Makefile" .
# [note] must not use -j since dependencies are not fully met
MAKEFLAGS_BAK="$MAKEFLAGS"
unset MAKEFLAGS
make PREFIX="$INST/x86_64-linux-gnu" DOWNLOADS="$DOWNLOADS"
export MAKEFLAGS="$MAKEFLAGS_BAK"
cd "$INST" && tar cf xorg.x86_64-linux-gnu.tar x86_64-linux-gnu && rm -fr x86_64-linux-gnu

# make contrib.keysyms (HAVE_XCB_KEYSYMS)
#   requires contrib.xorg build
cd "$INST" && rm -fr x86_64-linux-gnu && tar xf xorg.x86_64-linux-gnu.tar
cd "$CONTRIB" && rm -fr xcb-util-keysyms-0.4.0 && tar xf "$DOWNLOADS/xcb-util-keysyms-0.4.0.tar.bz2" && cd xcb-util-keysyms-0.4.0
./configure --prefix="$INST/x86_64-linux-gnu" PKG_CONFIG_PATH="$INST/x86_64-linux-gnu/lib/pkgconfig:$INST/x86_64-linux-gnu/share/pkgconfig"
make install
cd "$INST"
rm -f `tar tf xorg.x86_64-linux-gnu.tar | awk '!/\/$/'`
tar cf keysyms.x86_64-linux-gnu.tar x86_64-linux-gnu && rm -fr x86_64-linux-gnu

# make contrib.alsa (kernel support required); build time ~1m (4cores)
cd "$INST" && rm -fr x86_64-linux-gnu
cd "$CONTRIB" && rm -fr alsa-lib-1.1.3 && tar xf "$DOWNLOADS/alsa-lib-1.1.3.tar.bz2" && cd alsa-lib-1.1.3
./configure --prefix="$INST/x86_64-linux-gnu"
make install
cd "$INST" && tar cf alsa.x86_64-linux-gnu.tar x86_64-linux-gnu && rm -fr x86_64-linux-gnu

# VLC provided make rules...
cd "$CONTRIB/src"
sed -i 's/--disable-shared/--enable-shared/' main.mak
sed -i 's/--disable-shared/--enable-shared/' ffmpeg/rules.mak
sed -i 's/--static/--shared/' zlib/rules.mak
# ...patched to make shared
for BUILD in ffmpeg libxml2 lua ; do
rm -fr "$INST/x86_64-linux-gnu"
cd "$CONTRIB"
rm -fr tarballs && ln -s "$DOWNLOADS" tarballs
rm -fr native && mkdir native && cd native
../bootstrap --prefix="$INST/x86_64-linux-gnu"
make ".$BUILD"
cd "$INST" && tar cf $BUILD.x86_64-linux-gnu.tar x86_64-linux-gnu && rm -fr x86_64-linux-gnu
done

# make contrib.qt5; build time ~45m (4cores)
#   requires contrib.xorg
cd "$INST" && rm -fr x86_64-linux-gnu && tar xf xorg.x86_64-linux-gnu.tar
cd "$CONTRIB" && rm -fr qt-everywhere-opensource-src-5.8.0 && tar xf "$DOWNLOADS/qt-everywhere-opensource-src-5.8.0.tar.xz" && cd qt-everywhere-opensource-src-5.8.0
./configure -release -no-sql-sqlite -no-gif -qt-libjpeg -no-openssl -no-opengl -opensource -confirm-license -prefix "$INST/x86_64-linux-gnu" -nomake examples -skip qtwebengine -I"$INST/x86_64-linux-gnu/include" -L"$INST/x86_64-linux-gnu/lib" --no-reduce-relocations
make && make install
# ...it seems that make and install have to be called separately
# modifications according to linux-from-scratch...
find "$INST/x86_64-linux-gnu/lib/pkgconfig" -name "*.pc" -exec perl -pi -e "s, -L$PWD/?\S+,,g" {} \;
find "$INST/x86_64-linux-gnu" -name qt_lib_bootstrap_private.pri -exec sed -i -e "s:$PWD/qtbase:/$INST/x86_64-linux-gnu/lib/:g" {} \;
find "$INST/x86_64-linux-gnu" -name \*.prl -exec sed -i -e '/^QMAKE_PRL_BUILD_DIR/d' {} \;
for file in moc uic rcc qmake lconvert lrelease lupdate; do ln -sfrvn "$INST/x86_64-linux-gnu/bin/$file" "$INST/x86_64-linux-gnu/bin/$file-qt5" ; done
# save qt5 installation...
cd "$INST"
rm -f `tar tf xorg.x86_64-linux-gnu.tar | awk '!/\/$/'`
tar cf qt5.x86_64-linux-gnu.tar x86_64-linux-gnu && rm -fr x86_64-linux-gnu

# build VLC; build time ~2:30m (4cores)
cd "$INST" && rm -fr x86_64-linux-gnu && for f in *tar ; do tar xf $f ; done
cd "$VLC"
patch -p1 -b < "$PATCHES/patch.vlc"
./configure --prefix="$INST/x86_64-linux-gnu" --enable-debug CXXFLAGS="-std=c++11" `cat "$PATCHES/options" | xargs` CPPFLAGS="-I$INST/x86_64-linux-gnu/include" LDFLAGS="-L$INST/x86_64-linux-gnu/lib" PATH="$PATH:$INST/x86_64-linux-gnu/bin" PKG_CONFIG_PATH="$INST/x86_64-linux-gnu/lib/pkgconfig:$INST/x86_64-linux-gnu/share/pkgconfig"
# --enable-alsa --enable-avcodec --enable-libxml2 --enable-option-checking --enable-qt --enable-swscale --enable-vlc --enable-xcb
make && make install
cd "$INST"
rm -f vlc.x86_64-linux-gnu.tar
for f in *tar ; do rm -f `tar tf "$f" | awk '!/\/$/'` ; done
tar cf vlc.x86_64-linux-gnu.tar x86_64-linux-gnu && rm -fr x86_64-linux-gnu

