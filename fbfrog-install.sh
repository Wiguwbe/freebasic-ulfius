#!/bin/sh

set -e

wget https://github.com/Wiguwbe/fbfrog/archive/refs/heads/master.tar.gz

tar -xf master.tar.gz

pushd fbfrog-master

make

popd

rm master.tar.gz

# all cool?
