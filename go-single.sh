#  Usage
#    ./go-single.sh  7542116.crop.tif 7542116


in=$1
file=$2     # use as a friendly name


# in=warners-ranch_crop.tif
gdalbuildvrt tmp/$file.vrt $in

## only useful when converting many geotiffs into a vrt
#gdal_translate -of GTiff $in.tmp.vrt $in.tmp.tif
# gdal_translate -of vrt $in.tmp.vrt $in.vrt

#  wget https://raw.githubusercontent.com/roblabs/gdal2tilesp/WEBP-png/gdal2tilesp.py
# ./go-webp-png.sh $file WEBP 7 8       # Test

./go-webp-png.sh $file WEBP 7 14      # Max 14 for mobile
# ./go-webp-png.sh $file WEBP 7 15      # Max 15 for hosting on Mapbox.com/studio
# ./go-webp-png.sh $file WEBP 7 16      # Max test
#
# ./go-webp-png.sh $file PNG  7 14      # Max 15 for hosting on Mapbox.com/studio
# ./go-webp-png.sh $file PNG  7 15      # Max 14 for mobile
# ./go-webp-png.sh $file PNG  7 16      # Max 14 for mobile
