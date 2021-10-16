#!/bin/sh
gdalinfo --formats

echo ""
echo "PDF --formats"
gdalinfo --formats | grep PDF

echo ""
echo "gdalinfo --version"
gdalinfo --version
