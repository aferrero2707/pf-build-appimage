########################################################################
# Package the binaries built on Travis-CI as an AppImage
# By Andrea Ferrero 2018
# For more information, see http://appimage.org/
########################################################################


APP=photoflow
LOWERAPP=${APP,,}


########################################################################
# Get the helper scripts and load the helper functions
########################################################################
(mkdir -p /work && cd /work && rm -rf appimage-helper-scripts && \
git clone https://github.com/aferrero2707/appimage-helper-scripts.git) || exit 1
source /work/appimage-helper-scripts/functions.sh


########################################################################
# Create the root AppImage folder
########################################################################
export APPIMAGEBASE=/work/appimage
export APPDIR="${APPIMAGEBASE}/$APP.AppDir"
(rm -rf "${APPIMAGEBASE}" && mkdir -p "${APPIMAGEBASE}/$APP.AppDir/usr") || exit 1
cp /work/appimage-helper-scripts/excludelist "${APPIMAGEBASE}"


########################################################################
# Copy executable and config files
########################################################################
(mkdir -p "$APPDIR/usr/bin" && cp -a /${PREFIX}/bin/$LOWERAPP "$APPDIR/usr/bin/$LOWERAPP.real") || exit 1
(mkdir -p "$APPDIR/usr/share" && cp -a /${PREFIX}/share/$LOWERAPP "$APPDIR/usr/share") || exit 1
(mkdir -p "$APPDIR/usr/share/applications" && cp /$PREFIX/share/applications/$LOWERAPP.desktop "$APPDIR/usr/share/applications") || exit 1
cd /$PREFIX/share/icons/hicolor
for f in *; do
  ls $f/apps/$LOWERAPP.png
  if [ -e $f/apps/$LOWERAPP.png ]; then
    mkdir -p "$APPDIR/usr/share/icons/hicolor/$f/apps" || exit 1
    cp $f/apps/$LOWERAPP.png "$APPDIR/usr/share/icons/hicolor/$f/apps" || exit 1
  fi
done


########################################################################
# Get into the AppImage
########################################################################
cd "$APPDIR"



########################################################################
# Copy in the dependencies that cannot be assumed to be available
# on all target systems
########################################################################
copy_deps2; copy_deps2; copy_deps2;
move_lib
echo "After move_lib"
ls usr/lib

# Bundle GTK2 stuff
/work/appimage-helper-scripts/bundle-gtk2.sh


# Copy the shared MIME database
if [ -e /usr/share/mime ]; then
  (mkdir -p "$APPDIR/usr/share" && cp -a /usr/share/mime "$APPDIR/usr/share") || exit 1
fi


########################################################################
# Delete stuff that should not go into the AppImage
########################################################################

# Delete dangerous libraries; see
# https://github.com/probonopd/AppImages/blob/master/excludelist
delete_blacklisted2
# Put the gcc libraries in optional folders
copy_gcc_libs


########################################################################
# Determine the version of the app; also include needed glibc version
########################################################################

VERSION=$(date +%Y%m%d)_$(date +%H%M)-git-${TRAVIS_BRANCH}-${TRAVIS_COMMIT}
#VERSION=${RELEASE_VERSION}-glibc$GLIBC_NEEDED


########################################################################
# Patch away absolute paths; it would be nice if they were relative
########################################################################

#patch_files "usr"
#patch_files "$PREFIX"


########################################################################
# Copy desktop and icon file to AppDir for AppRun to pick them up
########################################################################

#get_apprun
cp -a /sources/appimage/AppRun.sh AppRun
cp -a /work/appimage-helper-scripts/apprun-helper.sh "./apprun-helper.sh" || exit 1
get_desktop
get_icon


########################################################################
# desktopintegration asks the user on first run to install a menu item
########################################################################

get_desktopintegration $LOWERAPP


# Workaround for:
# ImportError: /usr/lib/x86_64-linux-gnu/libgdk-x11-2.0.so.0: undefined symbol: XRRGetMonitors
cp $(ldconfig -p | grep libgdk-x11-2.0.so.0 | cut -d ">" -f 2 | xargs) ./usr/lib/
cp $(ldconfig -p | grep libgtk-x11-2.0.so.0 | cut -d ">" -f 2 | xargs) ./usr/lib/


# Strip binaries.
#strip_binaries



########################################################################
# AppDir complete
# Now packaging it as an AppImage
########################################################################

cd .. # Go out of AppImage


########################################################################
# Determine the version of the app; also include needed glibc version
########################################################################

VERSION=git-${TRAVIS_BRANCH}-$(date +%Y%m%d)_$(date +%H%M)-${TRAVIS_COMMIT}
#VERSION=${RELEASE_VERSION}-glibc$GLIBC_NEEDED


mkdir -p ../out/
ARCH="x86_64"
export NO_GLIBC_VERSION=true
export DOCKER_BUILD=true
generate_type2_appimage

pwd
ls ../out/*

########################################################################
# Upload the AppDir
########################################################################

#transfer ../out/*
echo ""
echo "AppImage has been uploaded to the URL above; use something like GitHub Releases for permanent storage"

mkdir -p /sources/out
cp ../out/* /sources/out
