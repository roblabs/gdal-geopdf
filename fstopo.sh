# Heavy with Script Kiddie
# Usage
# ./fstopo.sh 58260077e4b01fad86e7025e.json ; cat test.json | json fstopo.cmd | sh
cp $1 test.json

json -I -f test.json -e 'this.fstopo={}'
json -I -f test.json -e 'this.fstopo.minY = {}'
json -I -f test.json -e 'this.fstopo.maxX = {}'

json -I -f test.json -e 'this.fstopo.minY.data=this.spatial.boundingBox.minY'
json -I -f test.json -e 'this.fstopo.minY.degrees=Math.floor( this.fstopo.minY.data) '
json -I -f test.json -e 'this.fstopo.minY.minutes=Math.floor( 60 * (this.fstopo.minY.data - this.fstopo.minY.degrees) )'

json -I -f test.json -e 'this.fstopo.maxX.data=this.spatial.boundingBox.maxX * -1'
json -I -f test.json -e 'this.fstopo.maxX.degrees=Math.floor( this.fstopo.maxX.data) '
json -I -f test.json -e 'this.fstopo.maxX.minutes=Math.floor( 60 * (this.fstopo.maxX.data - this.fstopo.maxX.degrees) ) '

json -I -f test.json -e 'this.fstopo.boxName="" + this.fstopo.minY.degrees + this.fstopo.minY.minutes + this.fstopo.maxX.degrees + this.fstopo.maxX.minutes'

json -I -f test.json -e 'this.fstopo.titleOriginal=this.title'
json -I -f test.json -e 'this.fstopo.titleSplit1=this.title.split(",")'
json -I -f test.json -e 'this.fstopo.titleSplit2=this.fstopo.titleSplit1[0]'
json -I -f test.json -e 'this.fstopo.titleSplit3=this.fstopo.titleSplit2.split("USGS US Topo 7.5-minute map for ")[1]'
json -I -f test.json -e 'this.fstopo.title=this.fstopo.titleSplit3.replace(/ /gi, "_")'

json -I -f test.json -e 'this.fstopo.file=this.fstopo.boxName + "_" + this.fstopo.title + "_FSTopo.pdf"'
json -I -f test.json -e 'this.fstopo.folder="" + this.fstopo.minY.degrees + this.fstopo.maxX.degrees + "/fstopo"'
json -I -f test.json -e 'this.fstopo.url="https://data.fs.usda.gov/geodata/rastergateway/data/" + this.fstopo.folder + "/" + this.fstopo.file'

json -I -f test.json -e 'this.fstopo.cmd="wget -N " + this.fstopo.url'
