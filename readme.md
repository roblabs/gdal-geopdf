# GeoPDFs

This project shows how to process GeoPDFs from the [USGS](https://viewer.nationalmap.gov/basic/) and [USFS](https://data.fs.usda.gov/geodata/rastergateway/states-regions/states.php).  

## US Topo

### Process Examples

#### `gdalinfo`
```bash
# get GeoPDF of Crater Lake West
wget https://prd-tnm.s3.amazonaws.com/StagedProducts/Maps/USTopo/1/26110/8414580.pdf

gdalinfo -mdd LAYERS 8414580.pdf

```

Inspecting the response from `gdalinfo` with the option `-mdd` yields some interesting metadata.

##### PDF Dimensions

* PDF dimensions

```
Size is 3412, 4350
```

* Opening in a usual PDF viewer shows the image dimensions

```
22.75 × 29 inches
```

* Doing the math yields 150 pixels per inch.

#### `gdal_translate`

* Convert to GeoTIFF,

``` bash
DPI=300
gdal_translate 8414580.pdf 8414580.$DPI.tif \
  -co COMPRESS=LZW \
  --config GDAL_PDF_DPI $DPI

# Extract
gdalwarp 8414580.$DPI.tif 8414580.$DPI.wizard-island.tif \
  -t_srs EPSG:4326 -dstalpha \
  -co COMPRESS=LZW \
  -te -122.17833 42.92361 -122.13799 42.95766


gdal_translate 8414580.pdf 8414580.$DPI.Shaded_Relief.tif \
  -co COMPRESS=LZW \
    --config GDAL_PDF_LAYERS "Map_Collar.Map_Elements,Map_Frame.Terrain.Shaded_Relief" \
  --config GDAL_PDF_DPI $DPI

gdalwarp 8414580.$DPI.Shaded_Relief.tif 8414580.$DPI.Shaded_Relief.wizard-island.tif \
  -co COMPRESS=LZW \
  -t_srs EPSG:4326 -dstalpha \
  -te -122.17833 42.92361 -122.13799 42.95766

```


### Links

* Larry Moore, USGS, 2016 — [Converting US Topo GeoPDF Layers to GeoTIFF](https://nationalmap.gov/ustopo/documents/ustopo2gtif_current.pdf)
* Andrew Burnes, FOSS4G North America, 2016 — [Using GDAL
to Translate
US Topo GeoPDFs](https://2016.foss4g-na.org/sites/default/files/slides/using-gdal-to-translate-us-topo-geopdf.pdf)
* [roblabs/gdal](https://hub.docker.com/r/roblabs/gdal/)

### Background
> The term “US Topo” refers specifically to quadrangle topographic maps published in 2009 and later. [source][1]

Excerpt from October 2017

> In 2017, the US Topo map production system was redesigned and modernized to provide a system that facilitates long term goals for more efficient production and continued product improvements. The new system produces maps in a format that uses a different georeferencing mechanism compliant with ISO 32000. The new products can continue to be viewed and printed with Adobe Reader or any comparable PDF viewing software. [source][2]





[1]: https://nationalmap.gov/ustopo/index.html
[2]: https://nationalmap.gov/ustopo/about.html
