#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

VERSION=1.00

if [ "$ALIEN_INSTALL_TYPE" == "system" ]; then

  cd $(mktemp -d)
  curl -LO https://github.com/PerlAlien/dontpanic/archive/$VERSION.tar.gz
  tar xvf $VERSION.tar.gz
  cd dontpanic-$VERSION
  ./configure --prefix=/usr
  make
  make install

fi
