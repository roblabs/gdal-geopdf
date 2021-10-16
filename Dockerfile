# Usage
#  alias usgs='docker run -it --rm -v $(pwd):/data roblabs/usgs:usgs /bin/sh'
#  docker run -it --rm -v "$(pwd)":/data roblabs/usgs:usgs gdalinfo --version
#  docker run -it --rm -v "$(pwd)":/data roblabs/usgs:usgs gdalinfo --formats
#  docker run -it --rm -v "$(pwd)":/data roblabs/usgs:usgs gdalinfo --formats | grep PDF

# Build
#  docker build -t roblabs/usgs:usgs .

# https://github.com/roblabs/gdal-docker
FROM roblabs/gdal:latest


# https://docs.docker.com/engine/reference/builder/#add
ADD usgs.sh /usr/local/bin/
ADD go-single.sh /usr/local/bin/
ADD go-webp-png.sh /usr/local/bin/
ADD version.sh /usr/local/bin/
RUN wget https://raw.githubusercontent.com/roblabs/gdal2tilesp/WEBP-png/gdal2tilesp.py -P /usr/local/bin/
RUN chmod 755 /usr/local/bin/gdal2tilesp.py
