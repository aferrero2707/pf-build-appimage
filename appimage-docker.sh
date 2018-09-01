########################################################################
# Package the binaries built on Travis-CI as an AppImage
# By Simon Peter 2016
# For more information, see http://appimage.org/
########################################################################


PREFIX=zyx

strip_binaries()
{
  chmod u+w -R "$APPDIR"
  {
    find $APPDIR/usr -type f -name "rawtherapee*" -print0
    find "$APPDIR" -type f -regex '.*\.so\(\.[0-9.]+\)?$' -print0
  } | xargs -0 --no-run-if-empty --verbose -n1 strip
}


export PATH=/$PREFIX/bin:/work/inst/bin:$PATH
export LD_LIBRARY_PATH=/$PREFIX/lib:/work/inst/lib:$LD_LIBRARY_PATH
export PKG_CONFIG_PATH=/$PREFIX/lib/pkgconfig:/work/inst/lib/pkgconfig:$PKG_CONFIG_PATH
#export PATH=/work/inst/bin:$PATH
#export LD_LIBRARY_PATH=/work/inst/lib:$LD_LIBRARY_PATH
#export PKG_CONFIG_PATH=/work/inst/lib/pkgconfig:$PKG_CONFIG_PATH
export CMAKE_PREFIX_PATH=/$PREFIX

#(echo "/$PREFIX/lib" && cat /etc/ld.so.conf) > /temp-ld.so.conf
#cp /temp-ld.so.conf /etc/ld.so.conf
#ldconfig


cd /work
rm -f get-pip.py
wget https://bootstrap.pypa.io/get-pip.py
python get-pip.py
pip install six || exit 1

(yum update -y && yum install -y epel-release && yum update -y && yum install -y libtool-ltdl-devel autoconf automake libtools which json-c-devel json-glib-devel gtk-doc gperf libuuid-devel libcroco-devel intltool libpng-devel make \
automake fftw-devel libjpeg-turbo-devel \
libwebp-devel libxml2-devel swig ImageMagick-c++-devel \
bc cfitsio-devel gsl-devel matio-devel \
giflib-devel pugixml-devel wget curl git itstool \
bison flex unzip dbus-devel libXtst-devel \
mesa-libGL-devel mesa-libEGL-devel vala \
libxslt-devel docbook-xsl libffi-devel \
libvorbis-devel python-six curl \
openssl-devel readline-devel expat-devel libtool \
pixman-devel libffi-devel gtkmm24-devel gtkmm30-devel libcanberra-devel \
lcms2-devel gtk-doc python-devel python-pip nano OpenEXR-devel) || exit 1

#(sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test && apt-get -y update && \
#(sudo apt-get -y update && sudo apt-get install -y libiptcdata0-dev wget curl fuse libfuse2 git)
#sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-5 60 --slave /usr/bin/g++ g++ /usr/bin/g++-5) || exit 1

#cd /work && wget https://cmake.org/files/v3.8/cmake-3.8.2.tar.gz && tar xzvf cmake-3.8.2.tar.gz && cd cmake-3.8.2 && ./bootstrap --prefix=/work/inst --parallel=2 && make -j 2 && make install
#cd /work && wget https://downloads.sourceforge.net/lcms/lcms2-2.8.tar.gz && tar xzvf lcms2-2.8.tar.gz && cd lcms2-2.8 && ./configure --prefix=/app && make -j 2 && make install

(cd /work && rm -rf lensfun* && wget https://sourceforge.net/projects/lensfun/files/0.3.2/lensfun-0.3.2.tar.gz && tar xzvf lensfun-0.3.2.tar.gz && cd lensfun-0.3.2 && mkdir -p build && cd build && cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="/$PREFIX" ../ && make -j 2 && make install) || exit 1

#mkdir -p /work/bak/include && mv /usr/include/x86_64-linux-gnu/tiff*.h /work/bak/include
#mkdir -p /work/bak/lib && mv /usr/lib/x86_64-linux-gnu/libtiff*.* /work/bak/lib

(cd /work && rm -rf vips-8* && wget https://github.com/jcupitt/libvips/releases/download/v8.5.9/vips-8.5.9.tar.gz && \
tar xzf vips-8.5.9.tar.gz && cd vips-8.5.9 && \
#(cd /work && cd vips-8.5.8 && \
./configure --prefix="/$PREFIX" --without-python --enable-introspection=no --disable-gtk-doc && make -j install) || exit 1

#rm -rf /sources/build/appimage
(mkdir -p /sources/build/appimage && cd /sources/build/appimage && cmake -DCMAKE_BUILD_TYPE=Release -DBUNDLED_LENSFUN=OFF  -DCMAKE_INSTALL_PREFIX="/$PREFIX" -DUSE_GTKMM3=${USE_GTKMM3} /sources && make -j 2 install) || exit 1

exit

mkdir -p /sources/build/appimage
cd /sources/build/appimage
cp /sources/appimage/excludelist .

export ARCH=$(arch)

export APPIMAGEBASE=$(pwd)

APP=photoflow
LOWERAPP=${APP,,}

rm -rf $APP.AppDir
mkdir -p $APP.AppDir/usr/

(wget -q https://github.com/probonopd/AppImages/raw/master/functions.sh -O ./functions.sh) || cp /sources/appimage/functions.sh .
. ./functions.sh

cd $APP.AppDir

export APPDIR=$(pwd)

#sudo chown -R $USER /${PREFIX}/

#cp -r /${PREFIX}/* ./usr/
#rm -f ./usr/bin/$LOWERAPP.real
#mv ./usr/bin/$LOWERAPP ./usr/bin/$LOWERAPP.real

(mkdir -p ./usr/bin && cp -a /${PREFIX}/bin/$LOWERAPP ./usr/bin/$LOWERAPP.real) || exit 1


# Workaround for:
# python2.7: symbol lookup error: /usr/lib/x86_64-linux-gnu/libgtk-3.so.0: undefined symbol: gdk__private__

#cp /usr/lib/x86_64-linux-gnu/libg*k-3.so.0 usr/lib/x86_64-linux-gnu/

########################################################################
# Copy in the dependencies that cannot be assumed to be available
# on all target systems
########################################################################

copy_deps; copy_deps; copy_deps;

#exit

cp -L ./lib/x86_64-linux-gnu/*.* ./usr/lib; rm -rf ./lib/x86_64-linux-gnu
cp -L ./lib/*.* ./usr/lib; rm -rf ./lib;
cp -L ./usr/lib/x86_64-linux-gnu/*.* ./usr/lib; rm -rf ./usr/lib/x86_64-linux-gnu;
cp -L ./$PREFIX/lib/x86_64-linux-gnu/*.* ./usr/lib; rm -rf ./$PREFIX/lib/x86_64-linux-gnu;
cp -L ./$PREFIX/lib/*.* ./usr/lib; rm -rf ./$PREFIX/lib;

# Compile Glib schemas
( mkdir -p usr/share/glib-2.0/schemas/ ; cd usr/share/glib-2.0/schemas/ ; glib-compile-schemas . )


cp -a /usr/lib/x86_64-linux-gnu/gconv usr/lib

gdk_pixbuf_moduledir=$(pkg-config --variable=gdk_pixbuf_moduledir gdk-pixbuf-2.0)
gdk_pixbuf_cache_file=$(pkg-config --variable=gdk_pixbuf_cache_file gdk-pixbuf-2.0)
gdk_pixbuf_libdir_bundle=lib/x86_64-linux-gnu/gdk-pixbuf-2.0/2.10.0
gdk_pixbuf_cache_file_bundle=usr/${gdk_pixbuf_libdir_bundle}/loaders.cache

mkdir -p "usr/${gdk_pixbuf_libdir_bundle}"
cp -a "$gdk_pixbuf_moduledir" "usr/${gdk_pixbuf_libdir_bundle}"
cp -a "$gdk_pixbuf_cache_file" "usr/${gdk_pixbuf_libdir_bundle}"
#mkdir -p usr/lib/gdk-pixbuf-2.0/2.10.0
#cp -a /usr/lib/x86_64-linux-gnu/gdk-pixbuf-2.0/2.10.0/loaders usr/lib/gdk-pixbuf-2.0/2.10.0
#cp -a /usr/lib/x86_64-linux-gnu/gdk-pixbuf-2.0/2.10.0/loaders.cache usr/lib/gdk-pixbuf-2.0/2.10.0

for m in $(ls "usr/${gdk_pixbuf_libdir_bundle}"/loaders/*.so); do
  sofile=$(basename "$m")
  sed -i -e"s|${gdk_pixbuf_moduledir}/${sofile}|./${gdk_pixbuf_libdir_bundle}/loaders/${sofile}|g" "$gdk_pixbuf_cache_file_bundle"
done

cat "$gdk_pixbuf_cache_file_bundle"

ls usr/${gdk_pixbuf_libdir_bundle}/loaders
#exit

# Copy the pixmap theme engine
mkdir -p usr/lib/gtk-2.0/engines
gtk_libdir=$(pkg-config --variable=libdir gtk+-2.0)
pixmap_lib=$(find ${gtk_libdir}/gtk-2.0 -name libpixmap.so)
if [ x"${pixmap_lib}" != "x" ]; then
	cp -L "${pixmap_lib}" usr/lib/gtk-2.0/engines
fi


mkdir -p usr/share
cp -a /usr/share/mime usr/share

(mkdir -p usr/share && cp -a /$PREFIX/share/$LOWERAPP usr/share) || exit 1

#cp -a /$PREFIX/lib/* usr/lib
#cp -a /$PREFIX/lib64/* usr/lib64
#rm -rf $PREFIX
#rm -rf usr/lib/python*
#rm -rf usr/lib64/python*

ls usr/lib
move_lib
echo "After move_lib"
ls usr/lib

#exit

rm -rf usr/include usr/libexec usr/_jhbuild usr/share/doc

########################################################################
# Delete stuff that should not go into the AppImage
########################################################################

# Delete dangerous libraries; see
# https://github.com/probonopd/AppImages/blob/master/excludelist
move_blacklisted
#delete_blacklisted

stdcxxlib=$(ldconfig -p | grep 'libstdc++.so.6 (libc6,x86-64)'| awk 'NR==1{print $NF}')
echo "stdcxxlib: $stdcxxlib"
if [ x"$stdcxxlib" != "x" ]; then
    mkdir -p usr/optional/libstdc++
	cp -L "$stdcxxlib" usr/optional/libstdc++
fi

gomplib=$(ldconfig -p | grep 'libgomp.so.1 (libc6,x86-64)'| awk 'NR==1{print $NF}')
echo "gomplib: $gomplib"
if [ x"$gomplib" != "x" ]; then
    mkdir -p usr/optional/libstdc++
	cp -L "$gomplib" usr/optional/libstdc++
fi

fix_pango

########################################################################
# Determine the version of the app; also include needed glibc version
########################################################################

GLIBC_NEEDED=$(glibc_needed)
VERSION=$(date +%Y%m%d)_$(date +%H%M)-git-${TRAVIS_BRANCH}-gtk3-${TRAVIS_COMMIT}.glibc${GLIBC_NEEDED}
#VERSION=${RELEASE_VERSION}-glibc$GLIBC_NEEDED

########################################################################
# Patch away absolute paths; it would be nice if they were relative
########################################################################

pwd
echo "INSTALL_PREFIX before patching:"
strings ./usr/$LOWERAPP.real | grep INSTALL_PREFIX

find usr/ -type f -exec sed -i -e 's|/usr/|././/|g' {} \; -exec echo -n "Patched /usr in " \; -exec echo {} \; >& patch1.log
find usr/ -type f -exec sed -i -e "s|/${PREFIX}/|././/|g" {} \; -exec echo -n "Patched /${PREFIX} in " \; -exec echo {} \; >& patch2.log



# Copy deskop file and application icon
(mkdir -p usr/share/applications/ && cp /$PREFIX/share/applications/$LOWERAPP.desktop usr/share/applications) || exit 1
(mkdir -p usr/share/icons && cp -r /$PREFIX/share/icons/hicolor usr/share/icons) || exit 1


########################################################################
# Copy desktop and icon file to AppDir for AppRun to pick them up
########################################################################

#get_apprun
cp -a /sources/appimage/AppRun .
get_desktop
get_icon

########################################################################
# desktopintegration asks the user on first run to install a menu item
########################################################################

get_desktopintegration $LOWERAPP


# The fonts configuration should not be patched, copy back original one
if [ -e /$PREFIX/etc/fonts/fonts.conf ]; then
  cp /$PREFIX/etc/fonts/fonts.conf usr/etc/fonts/fonts.conf
else
  cp /$usr/etc/fonts/fonts.conf usr/etc/fonts/fonts.conf
fi

# Workaround for:
# ImportError: /usr/lib/x86_64-linux-gnu/libgdk-x11-2.0.so.0: undefined symbol: XRRGetMonitors
cp $(ldconfig -p | grep libgdk-x11-2.0.so.0 | cut -d ">" -f 2 | xargs) ./usr/lib/
cp $(ldconfig -p | grep libgtk-x11-2.0.so.0 | cut -d ">" -f 2 | xargs) ./usr/lib/


# Strip binaries.
echo "APPDIR: $APPDIR"
#strip_binaries



########################################################################
# AppDir complete
# Now packaging it as an AppImage
########################################################################

cd .. # Go out of AppImage

tar czf /sources/$APP.AppDir.tgz $APP.AppDir
#cd /
#tar czf /sources/$APP.tgz $PREFIX
