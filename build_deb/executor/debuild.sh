#!/bin/bash

debuild --no-lintian -uc -us
debuild -- clean

rm -f ../*.build ../*.buildinfo ../*.changes ../*.dsc ../*.tar.gz ../*.tar.bz2 ../*.zip