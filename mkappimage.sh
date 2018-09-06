#! /bin/bash

export PREFIX=zyx

export PATH=/$PREFIX/bin:/work/inst/bin:$PATH
export LD_LIBRARY_PATH=/$PREFIX/lib:/$PREFIX/lib64:/work/inst/lib:$LD_LIBRARY_PATH
export PKG_CONFIG_PATH=/$PREFIX/lib/pkgconfig:/$PREFIX/lib64/pkgconfig:/$PREFIX/share/pkgconfig:/work/inst/lib/pkgconfig:$PKG_CONFIG_PATH

bash /sources/appimage/build-appimage.sh

bash /sources/appimage/package-appimage.sh