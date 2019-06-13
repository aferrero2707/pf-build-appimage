#!/usr/bin/env bash
HERE="$(dirname "$(readlink -f "${0}")")"
export APPDIR="$HERE"

#export APPIMAGE_CHECKRT_DEBUG=1

source "$APPDIR/apprun-helper.sh"
save_environment
make_temp_libdir
link_libraries
echo "AILIBDIR=$AILIBDIR"
fix_libxcb_dri3
fix_stdlibcxx
#fix_fontconfig
fix_library "libfontconfig"
fix_library "libfreetype"
#exit

init_environment
init_gtk

#export PATH="${PATH}:/sbin:/usr/sbin"
#export LD_LIBRARY_PATH="$AILIBDIR:/usr/lib:$LD_LIBRARY_PATH"
#export XDG_DATA_DIRS="${APPDIR}/usr/share/:${APPDIR}/usr/share/:${XDG_DATA_DIRS}: /usr/local/share/:/usr/share/"
#export GTK_PATH="${APPDIR}/usr/lib/gtk-2.0:${GTK_PATH}"
#export PANGO_LIBDIR="${APPDIR}/usr/lib"
#export GCONV_PATH="${APPDIR}/usr/lib/gconv"
#export GDK_PIXBUF_MODULEDIR="${APPDIR}/usr/lib/gdk-pixbuf-2.0/loaders"
#export GDK_PIXBUF_MODULE_FILE="${APPDIR}/usr/lib/gdk-pixbuf-2.0/loaders.cache"
export PF_DATA_DIR="${APPDIR}/usr/share"

export APPIMAGE_OWD=$(pwd)

#echo "PF_DATA_DIR=${PF_DATA_DIR}"


#ldd "$HERE/photoflow.real"
#echo -n "$HERE/photoflow.real "
#echo "$@"
#cd $HERE
#cd ..
ldd "$APPDIR/usr/bin/photoflow.bin"
echo "OWD: $OWD"
#cd $OWD
#cd "$HERE/.."
"$APPDIR/usr/bin/photoflow.wrapper" "$@"
#gdb -ex "run" $HERE/photoflow.real
