# Usage
#  alias usgs='docker run -it --rm -v $(pwd):/data roblabs/usgs:usgs /bin/bash'
# Build
#  docker build -t roblabs/usgs:latest .

# https://github.com/roblabs/gdal-docker
FROM roblabs/gdal:latest


# https://docs.docker.com/engine/reference/builder/#add
ADD usgs.sh /tmp/
ADD go-single.sh /tmp/
ADD go-webp-png.sh /tmp/
RUN wget https://raw.githubusercontent.com/roblabs/gdal2tilesp/WEBP-png/gdal2tilesp.py
