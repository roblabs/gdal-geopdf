# Usage
#  alias usgs='docker run -it --rm -v $(pwd):/data roblabs/usgs:usgs /bin/bash'
# Build
#  docker build -t roblabs/usgs:usgs .

# https://github.com/roblabs/gdal-docker
FROM roblabs/gdal:latest


# https://docs.docker.com/engine/reference/builder/#add
ADD usgs.sh ~/.local/bin/
ADD go-single.sh ~/.local/bin/
ADD go-webp-png.sh ~/.local/bin/
RUN wget https://raw.githubusercontent.com/roblabs/gdal2tilesp/WEBP-png/gdal2tilesp.py -P ~/.local/bin/
RUN chmod 755 ~/.local/bin/gdal2tilesp.py
