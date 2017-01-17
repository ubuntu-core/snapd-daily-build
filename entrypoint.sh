#!/bin/bash
#set -e

git clone https://github.com/snapcore/snapd ${SNAPD_PATH}

cd ${SNAPD_PATH}
GIT_COMMIT=$(git log --pretty=format:"%H" | head -1)
sudo apt update
sudo apt build-dep -y ./

# ensure bundled dependencies are ok
go get -u github.com/kardianos/govendor
$GOPATH/bin/govendor sync

rm -rf ../*.deb ../*.changes ../*.dsc ../*.tar.xz ../*.upload

dch --distribution xenial -m --local +ppa${TRAVIS_BUILD_NUMBER}.$(echo $GIT_COMMIT|cut -b1-8)- Daily release to the PPA

echo -n "$BUILD_PASSWORD" > ${PWD}/build_password
echo -n "$BUILD_KEY" > ${PWD}/build_key
gpg-agent --daemon --enable-ssh-support
gpg --import ${PWD}/build_key
echo "gpg --sign --batch --passphrase-file ${PWD}/build_password \$@" > ${PWD}/sign.sh
chmod +x sign.sh
dpkg-buildpackage -S --force-sign -kDB810A52 -p${PWD}/sign.sh
lintian

# dput ppa:snappy-dev/edge ../*.changes
dput ppa:testppa/testppa2 ../*.changes
