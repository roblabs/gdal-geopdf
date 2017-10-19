export FORMAT=$2
export format_lower=png
export MIN=$3
export MAX=$4
export INPUT_FILE=tmp/$1.vrt

# Usage
# ./go-webp.sh whitney WEBP 7 15
# ./go-webp.sh whitney WEBP 7 14


# cmd="docker run --rm -v $(pwd):/data geodata/gdal ./gdal2tilesp.py -z $MIN-$MAX -f $FORMAT $INPUT_FILE"
cmd="./gdal2tilesp.py -z $MIN-$MAX -f $FORMAT $INPUT_FILE"
echo $cmd; sh -c "${cmd}"


for i in $(seq $MIN $MAX);
do

  if (( $i == $MAX )); then
    echo $i
    break;
  fi

  # cmd="docker run --rm -v $(pwd):/data geodata/gdal ./gdal2tilesp.py -z  $i -w all -e -f $FORMAT $INPUT_FILE"
  cmd="./gdal2tilesp.py -z  $i -w all -e -f $FORMAT $INPUT_FILE"
  echo $cmd; sh -c "${cmd}"

done



# Update attribution
# json -I -f $1/metadata.json -e 'this.name="'$0 $1 $2 $3 $4'"'
# json -I -f $1/metadata.json -e 'this.center="'$0 $1 $2 $3 $4'"'
# json -I -f $1/metadata.json -e 'this.mtime="'$0 $1 $2 $3 $4'"'
# json -I -f $1/metadata.json -e 'this.id="'$0 $1 $2 $3 $4'"'
json -I -f $1/metadata.json -e 'this.attribution="<a href=\"https://usgs.gov\" target=\"_blank\">© USGS</a>"'


mb-util --silent --image_format=$format_lower $1 $1-$FORMAT-$format_lower-$MIN-$MAX.mbtiles
sudo mv $1-$FORMAT-$format_lower-$MIN-$MAX.mbtiles mbtiles/$1-$FORMAT-$format_lower-$MIN-$MAX.mbtiles

sudo mv $1 tmp/$1-$FORMAT-$format_lower-$MIN-$MAX

# mapbox --access-token=$MAPBOX_SUPER_TOKEN upload \
#  7541782-WEBP-png-7-15 CA_Palomar_Observatory-7541782-WEBP-png-7-15.mbtiles

echo "mapbox --access-token=$MAPBOX_SUPER_TOKEN upload \
  $1-$FORMAT-$format_lower-$MIN-$MAX \
  $1-$FORMAT-$format_lower-$MIN-$MAX.mbtiles"
