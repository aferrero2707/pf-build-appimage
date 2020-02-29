########################################################################
# Package the binaries built on Travis-CI as an AppImage
# By Simon Peter 2016
# For more information, see http://appimage.org/
########################################################################


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
automake fftw-devel libjpeg-turbo-devel cmake3 \
libwebp-devel libxml2-devel swig ImageMagick-c++-devel \
bc cfitsio-devel gsl-devel matio-devel libiptcdata-devel \
giflib-devel pugixml-devel wget curl git itstool \
bison flex unzip dbus-devel libXtst-devel \
mesa-libGL-devel mesa-libEGL-devel vala \
libxslt-devel docbook-xsl libffi-devel \
libvorbis-devel python-six curl \
openssl-devel readline-devel expat-devel libtool exiv2-devel \
pixman-devel libffi-devel gtkmm24-devel gtkmm30-devel libcanberra-devel \
lcms2-devel gtk-doc python-devel python-pip nano OpenEXR-devel libexif-devel) || exit 1

#(sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test && apt-get -y update && \
#(sudo apt-get -y update && sudo apt-get install -y libiptcdata0-dev wget curl fuse libfuse2 git)
#sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-5 60 --slave /usr/bin/g++ g++ /usr/bin/g++-5) || exit 1

#cd /work && wget https://cmake.org/files/v3.8/cmake-3.8.2.tar.gz && tar xzvf cmake-3.8.2.tar.gz && cd cmake-3.8.2 && ./bootstrap --prefix=/work/inst --parallel=2 && make -j 2 && make install
#cd /work && wget https://downloads.sourceforge.net/lcms/lcms2-2.8.tar.gz && tar xzvf lcms2-2.8.tar.gz && cd lcms2-2.8 && ./configure --prefix=/app && make -j 2 && make install

if [ ! -e /work/lensfun-0.3.2 ]; then
(cd /work && wget https://sourceforge.net/projects/lensfun/files/0.3.2/lensfun-0.3.2.tar.gz && tar xzvf lensfun-0.3.2.tar.gz && cd lensfun-0.3.2 && mkdir -p build && cd build && cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="/$PREFIX" ../ && make -j 2 && make install) || exit 1
fi

#mkdir -p /work/bak/include && mv /usr/include/x86_64-linux-gnu/tiff*.h /work/bak/include
#mkdir -p /work/bak/lib && mv /usr/lib/x86_64-linux-gnu/libtiff*.* /work/bak/lib

#VIPS_VERSION=8.5.9
VIPS_VERSION=8.7.4
if [ ! -e /work/vips-${VIPS_VERSION} ]; then
(cd /work && wget https://github.com/libvips/libvips/releases/download/v${VIPS_VERSION}/vips-${VIPS_VERSION}.tar.gz && \
tar xzf vips-${VIPS_VERSION}.tar.gz && cd vips-${VIPS_VERSION} && \
#(cd /work && cd vips-8.5.8 && \
./configure --prefix="/$PREFIX" --without-python --enable-introspection=no --disable-gtk-doc && make -j 3 install) || exit 1
fi

if [ ! -e /work/OpenColorIO-1.1.0 ]; then
(cd /work && rm -rf OpenColorIO-* && wget https://github.com/imageworks/OpenColorIO/archive/v1.1.0.tar.gz && \
tar xzf v1.1.0.tar.gz && cd OpenColorIO-1.1.0 && mkdir -p build && cd build && \
CXXFLAGS="-Wno-unused-function -Wno-deprecated-declarations" cmake3 -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="/$PREFIX" -DOCIO_BUILD_APPS=OFF -DOCIO_BUILD_NUKE=OFF -DOCIO_BUILD_DOCS=OFF -DOCIO_BUILD_TESTS=OFF -DOCIO_BUILD_GPU_TESTS=OFF -DOCIO_BUILD_PYTHON=OFF -DOCIO_BUILD_JAVA=OFF .. && \
make -j 3 install) || exit 1
fi

(mkdir -p /work/phf && cd /work/phf && rm -f CMakeCache.txt && cmake3 -DOCIO_ENABLED=ON -DCMAKE_BUILD_TYPE=Release -DBUNDLED_LENSFUN=OFF  -DCMAKE_INSTALL_PREFIX="/$PREFIX" -DUSE_GTKMM3=${USE_GTKMM3} /sources && make -j 2 install) || exit 1

#exit

