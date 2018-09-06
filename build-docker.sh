#! /bin/bash

export PF_BRANCH=stable
#rm -rf RawTherapee
if [ ! -e PhotoFlow ]; then
	git clone https://github.com/aferrero2707/PhotoFlow.git --branch $PF_BRANCH --single-branch
fi
rm -rf PhotoFlow/appimage
mkdir -p PhotoFlow/appimage
cp -a *.sh PhotoFlow/appimage
cd PhotoFlow
docker run -it -v $(pwd):/sources -e "PF_BRANCH=$PF_BRANCH" photoflow/docker-centos7-gtk bash #/sources/ci/appimage-centos7.sh
