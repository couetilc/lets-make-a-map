#!/bin/bash
export PATH=~/development/lets-make-a-map/node_modules/.bin/:$PATH
shp2json cb_2014_36_tract_500k.shp -o ny.json
geoproject 'd3.geoTransverseMercator().rotate([74 + 30 / 60, -38 - 50 / 60]).fitSize([4000,4000], d)' < ny.json > ny-projection.json
geo2svg -w 4000 -h 4000 < ny-projection.json > ny-projection.svg
