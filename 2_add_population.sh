#!/bin/bash
export PATH=./node_modules/.bin/:$PATH
ndjson-split 'd.features' < ny-projection.json > ny-projection.ndjson
ndjson-map 'd.id = d.properties.GEOID.slice(2), d' < ny-projection.ndjson > ny-projection-id.ndjson
ndjson-cat cb_2014_36_tract_B01003.json \
    | ndjson-split 'd.slice(1)' \
    | ndjson-map '{id: d[2] + d[3], B01003: +d[0]}' \
    > cb_2014_36_tract_B01003.ndjson
ndjson-join 'd.id' \
    ny-projection-id.ndjson \
    cb_2014_36_tract_B01003.ndjson \
    > ny-projection-join.ndjson
ndjson-map 'd[0].properties = {density: Math.floor(d[1].B01003 / d[0].properties.ALAND * 2589975.2356)}, d[0]' \
    < ny-projection-join.ndjson \
    > ny-projection-density.ndjson
ndjson-reduce \
    < ny-projection-density.ndjson \
    | ndjson-map '{type: "FeatureCollection", features: d}' \
    > ny-projection-density.json
ndjson-reduce 'p.features.push(d), p' '{type: "FeatureCollection", features: []}' \
    < ny-projection-density.ndjson \
    > ny-projection-density.json
ndjson-map -r d3 \
    '(d.properties.fill = d3.scaleSequential(d3.interpolateViridis).domain([0, 4000]) (d.properties.density), d)' \
    < ny-projection-density.ndjson \
    > ny-projection-color.ndjson
geo2svg -n --stroke none -p 1 -w 4000 -h 4000 \
    < ny-projection-color.ndjson \
    > ny-projection-color.svg
