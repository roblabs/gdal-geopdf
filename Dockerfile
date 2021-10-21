# Usage
#  alias usgs='docker run -it --rm -v $(pwd):/data roblabs/usgs:usgs /bin/sh'
#  docker run -it --rm -v "$(pwd)":/data roblabs/usgs:usgs gdalinfo --version
#  docker run -it --rm -v "$(pwd)":/data roblabs/usgs:usgs gdalinfo --formats
#  docker run -it --rm -v "$(pwd)":/data roblabs/usgs:usgs gdalinfo --formats | grep PDF

# Build
#  docker build --no-cache -t roblabs/usgs:usgs .

# Please see the OSGEO GDAL Docker images — https://hub.docker.com/r/osgeo/gdal
FROM osgeo/gdal:alpine-normal-latest

# https://docs.docker.com/engine/reference/builder/#add
ADD usgs.sh /usr/local/bin/
ADD go-single.sh /usr/local/bin/
ADD go-webp-png.sh /usr/local/bin/
ADD version.sh /usr/local/bin/
RUN wget https://raw.githubusercontent.com/roblabs/gdal2tilesp/master/gdal2tilesp.py -P /usr/local/bin/
RUN chmod 755 /usr/local/bin/gdal2tilesp.py

# Externally accessible data is by default put in /data
# https://docs.docker.com/engine/reference/builder/#volume
# https://docs.docker.com/engine/reference/builder/#workdir
WORKDIR /data
VOLUME ["/data"]
