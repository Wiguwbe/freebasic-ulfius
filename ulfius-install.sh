#!/bin/sh

set -e

#VERSION=${1:-2.7.13}
BRANCH=${1:-freebasic}

wget https://github.com/Wiguwbe/ulfius/archive/refs/heads/${BRANCH}.tar.gz

tar -xf ${BRANCH}.tar.gz

pushd ulfius-${BRANCH}


# fake dir (not needed)
INSTALL_ROOT=/opt/ulfius
mkdir -p ${INSTALL_ROOT}/{include,lib}

# disable unwanted stuff, build & install
alias m='make CURLFLAG=1 GNUTLSFLAG=1 UWSCFLAG=1'
m && m DESTDIR=${INSTALL_ROOT} install
unalias m

popd
rm ${BRANCH}.tar.gz

# should be grand
