#!/bin/bash

# sudo yum install -y docker
#   sudo usermod -a -G docker $USER  # relogin


getJsonPDF() {
  echo
  echo "########## getJsonPDF"
  # json & PDF
  ## 1. Set Values from the National Map
  metadata=https://www.sciencebase.gov/catalog/item/$sourceId
  echo $metadata;

  ### Get JSON
  if [ -f json/$sourceId.json ]
  then
      echo $sourceId.json exists, skipping
  else
      echo the file does not exist
      curl $metadata?format=json > json/$sourceId.json
  fi

  ## 2.  Manually extract name
  cat json/$sourceId.json | json files[0].name > /tmp/name.txt

  ###
  # Grab the webLinks property, look for a title==GeoPDF, then extract the property called 'uri'
  # [{"type":"download","uri":"https://prd-tnm.s3.amazonaws.com/StagedProducts/Maps/USTopo/1/22300/7538398.pdf",
  #   "rel":"related","title":"GeoPDF","hidden":false,"length":26432815}]
  cat json/$sourceId.json | json webLinks | json -c 'this.title == "GeoPDF"' | json -a uri  > /tmp/pdfUrl.txt
  pdfUrl=$(cat /tmp/pdfUrl.txt)

  ### base is equivalent to the root file name (with out the .pdf extension)
  filename=$(basename $pdfUrl)
  base="${filename%.*}"; echo $base
  echo $base > /tmp/base.txt

  ## 3.  after setting `name`, then echo to file for use by containers
  export base=$(cat /tmp/base.txt)
  export name=$(cat /tmp/name.txt)
  echo $name-$base

  if [ -f pdf/$base.pdf ]
  then
      echo File pdf/$base.pdf exists, skipping
  else
      echo pdf/$base.pdf does not exist
      wget -N $pdfUrl -P pdf
      cp pdf/$base.pdf pdf/$name-$base.pdf
      ls -l pdf/$name-$base.pdf
  fi

  # 4. get bounding box
  # After knowing the dimensions of the GeoTIFF, then extract just the map (no collar)
  # Edit the gdalwarp section with the output
  cat json/$sourceId.json | json spatial.boundingBox.minX > /tmp/xmin.txt;
  cat json/$sourceId.json | json spatial.boundingBox.minY > /tmp/ymin.txt;
  cat json/$sourceId.json | json spatial.boundingBox.maxX > /tmp/xmax.txt;
  cat json/$sourceId.json | json spatial.boundingBox.maxY > /tmp/ymax.txt;

  xmin=$(cat /tmp/xmin.txt);
  ymin=$(cat /tmp/ymin.txt);
  xmax=$(cat /tmp/xmax.txt);
  ymax=$(cat /tmp/ymax.txt);
  echo bbox = $xmin, $ymin, $xmax, $ymax # -116.75, 33.125, -116.625, 33.25
}

# 5.  Convert to GeoTiff
## 6. Crop to Bounding box
# Crop out just the map data
#  -te xmin ymin xmax ymax:
makeTopo() {
  echo
  echo "########## makeTopo"
  if [ -f $FRIENDLY_TMP_FOLDER/$name-$base.topo.$DPI.tif ]
  then
      echo $FRIENDLY_TMP_FOLDER/$name-$base.topo.$DPI.tif exists, skipping
  else
    gdal_translate pdf/$name-$base.pdf $FRIENDLY_TMP_FOLDER/$name-$base.topo.$DPI.tif \
      -co COMPRESS=LZW \
      --config GDAL_PDF_LAYERS "all" \
      --config GDAL_PDF_DPI $DPI \
      --config GDAL_PDF_LAYERS_OFF "Map_Frame.Projection_and_Grids,Map_Frame.PLSS,Map_Frame.Terrain,Images"

    gdalwarp -t_srs EPSG:4326 -dstalpha \
      -co COMPRESS=LZW \
      $FRIENDLY_TMP_FOLDER/$name-$base.topo.$DPI.tif $FRIENDLY_TMP_FOLDER/$name-$base.topo.crop.$DPI.tif \
      -te $xmin $ymin $xmax $ymax
  fi

}

makeFSTopo() {
  echo
  echo "########## makeFSTopo"
  if [ -f $FRIENDLY_TMP_FOLDER/$FSTOPO.$FSTOPO_DPI.tif ]
  then
    echo FSTopo exists = $FRIENDLY_TMP_FOLDER/$FSTOPO.$FSTOPO_DPI.tif
    echo " "
  else
    echo FSTopo, creating $FRIENDLY_TMP_FOLDER/$FSTOPO.$FSTOPO_DPI.tif

    gdal_translate pdf/$FSTOPO $FRIENDLY_TMP_FOLDER/$FSTOPO.$FSTOPO_DPI.tif \
      -co COMPRESS=LZW \
      --config GDAL_PDF_LAYERS_OFF "Quadrangle.Contour_Labels,Quadrangle.Contours,Quadrangle.UTM_Grid,Quadrangle.PLSS" \
      --config GDAL_PDF_DPI $FSTOPO_DPI

    gdalwarp -t_srs EPSG:4326 -dstalpha \
      -co COMPRESS=LZW \
      $FRIENDLY_TMP_FOLDER/$FSTOPO.$FSTOPO_DPI.tif $FRIENDLY_TMP_FOLDER/$FSTOPO.$FSTOPO_DPI.crop.tif \
      -te $xmin $ymin $xmax $ymax
  fi
}

### USGS TOPO Raster images
makeOrthoImage() {
  echo
  echo "########## makeOrthoImage"
  gdal_translate pdf/$name-$base.pdf $FRIENDLY_TMP_FOLDER/$name-$base.ortho.$DPI.tif \
    -co COMPRESS=LZW \
    --config GDAL_PDF_LAYERS "Images.Orthoimage" \
    --config GDAL_PDF_DPI $DPI

  gdalwarp -t_srs EPSG:4326 -dstalpha \
    -co COMPRESS=LZW \
    $FRIENDLY_TMP_FOLDER/$name-$base.ortho.$DPI.tif $FRIENDLY_TMP_FOLDER/$name-$base.ortho.crop.$DPI.tif \
    -te $xmin $ymin $xmax $ymax
}


makeShaded_Relief() {
  echo
  echo "########## makeShaded_Relief"
  echo $FRIENDLY_TMP_FOLDER/$name-$base.relief.$DPI.tif
  if [ -f $FRIENDLY_TMP_FOLDER/$name-$base.relief.$DPI.tif ]
  then
      echo   SKIPPING, exists = $FRIENDLY_TMP_FOLDER/$name-$base.relief.$DPI.tif
  else
      echo   SHADED RELIEF, creating $FRIENDLY_TMP_FOLDER/$name-$base.relief.$DPI.tif

      gdal_translate pdf/$name-$base.pdf $FRIENDLY_TMP_FOLDER/$name-$base.relief.$DPI.tif \
        -co COMPRESS=LZW \
        --config GDAL_PDF_LAYERS "Map_Collar.Map_Elements,Map_Frame.Terrain.Shaded_Relief" \
        --config GDAL_PDF_DPI $DPI \

      gdalwarp -t_srs EPSG:4326 -dstalpha \
      -co COMPRESS=LZW \
      $FRIENDLY_TMP_FOLDER/$name-$base.relief.$DPI.tif $FRIENDLY_TMP_FOLDER/$name-$base.relief.crop.$DPI.tif \
        -te $xmin $ymin $xmax $ymax
  fi
}

makeWebP() {
  Run GDAL
  ./go-single.sh  $FRIENDLY_TMP_FOLDER/$name-$base.relief.crop.$DPI.tif $name-$base.$DPI   ###########
}


export FRIENDLY_TMP_FOLDER="."
echo FRIENDLY_TMP_FOLDER = $FRIENDLY_TMP_FOLDER >&2


while getopts "D:F:N:P:S:TRWO" opt; do
  case $opt in
    D)
      export DPI="$OPTARG"
      echo DPI = $DPI >&2
      ;;
    F)
      export FSTOPO="$OPTARG"
      echo FSTOPO = $FSTOPO >&2
      makeFSTopo
      ;;
    O)
      makeOrthoImage
      ;;
    P)
      export FSTOPO_DPI="$OPTARG"
      echo FSTOPO_DPI = $FSTOPO_DPI >&2
      ;;
    N)
      export FRIENDLY_TMP_FOLDER="tmp/$OPTARG"
      echo FRIENDLY_TMP_FOLDER = $FRIENDLY_TMP_FOLDER >&2
      mkdir -p $FRIENDLY_TMP_FOLDER
      ;;
    R)
      echo "-R for Shaded Relief" >&2
      makeShaded_Relief
      ;;
    S)
      echo "-S for sourceId from the USGS" >&2
      export sourceId="$OPTARG"
      echo sourceId = $sourceId >&2
      getJsonPDF
      ;;
    T)
      echo "-T to produce a topo" >&2
      makeTopo
      ;;
    W)
      echo "-W for .mbtiles and WEBP process" >&2
      makeWebP
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      echo "Usage" >&2
      echo "  # from source at 300 Dpi, makeTopo, makeShaded_Relief" >&2
      echo "  sh usgs.sh -S 5825aec2e4b01fad86dd149c -D 300 -T -R" >&2

      echo "" >&2
      echo "  # from source at 300 Dpi, makeTopo, makeShaded_Relief, makeOrthoImage" >&2
      echo "  sh usgs.sh -S 5825aec2e4b01fad86dd149c -D 300 -T -R -O" >&2

      echo "" >&2
      echo "  # Test with all main parameters" >&2
      echo "  sh usgs.sh -N foofoo -S 5825aec2e4b01fad86dd149c -D 25 -T -R -O" >&2

      echo "" >&2
      echo "  # Test UStopo and FSTopo" >&2
      echo "  sh usgs.sh -N tempFolder -S 5825df9be4b01fad86e2db0a -D 100 -R -P 100 -F 415207845_Stickney_FSTopo.pdf" >&2
      ;;
  esac
done
