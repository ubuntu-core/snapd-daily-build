#!/bin/sh
set -ex

git clone https://github.com/snapcore/snapd ${SNAPCORE_PATH}

cd ${SNAPD_PATH}
GIT_COMMIT=$(git log --pretty=format:"%H" | head -1)
sudo apt update
sudo apt build-dep -y ./

# ensure bundled dependencies are ok
go get -u github.com/kardianos/govendor
$GOPATH/bin/govendor sync

rm -rf ../*.deb ../*.changes ../*.dsc ../*.tar.xz ../*.upload

dch --distribution xenial -m --local +ppa$TRAVIS_BUILD_NUMBER.$(echo $GIT_COMMIT|cut -b1-8)- Daily release to the PPA

echo $BUILD_PASSWORD > ./build_password
echo $BUILD_KEY > ./build_key
gpg ---import ./build_key
echo "gpg --sign --batch --passphrase-file ./build_password \$@" > sign.sh
chmod +x sign.sh
dpkg-buildpackage -S --force-sign -kDB810A52 -p./sign.sh
lintian

# dput ppa:snappy-dev/edge ../*.changes
dput ppa:testppa/testppa2 ../*.changes
