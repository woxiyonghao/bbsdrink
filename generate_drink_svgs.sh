#!/bin/bash
DIR="entry/src/main/resources/base/media"
mkdir -p $DIR

cat << 'SVGEOF' > $DIR/ic_drink_cola.svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="#333333"><path d="M7 4h10v2H7zM8 7h8v14H8z"/></svg>
SVGEOF

cat << 'SVGEOF' > $DIR/ic_drink_beer.svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="#333333"><path d="M20 10c-1.1 0-2 .9-2 2v6c0 1.1.9 2 2 2s2-.9 2-2v-6c0-1.1-.9-2-2-2zm-3-1v11H5V9c0-1.1.9-2 2-2h4V5h2v2h4z"/></svg>
SVGEOF

cat << 'SVGEOF' > $DIR/ic_drink_wine.svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="#333333"><path d="M21 3H3v2h2v4c0 3.3 2.7 6 6 6v5H8v2h8v-2h-3v-5c3.3 0 6-2.7 6-6V5h2V3zM17 9c0 2.2-1.8 4-4 4s-4-1.8-4-4V5h8v4z"/></svg>
SVGEOF

cat << 'SVGEOF' > $DIR/ic_drink_mate.svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="#333333"><path d="M12 2C6.5 2 2 6.5 2 12s4.5 10 10 10 10-4.5 10-10S17.5 2 12 2zm0 18c-4.4 0-8-3.6-8-8s3.6-8 8-8 8 3.6 8 8-3.6 8-8 8z"/></svg>
SVGEOF

cat << 'SVGEOF' > $DIR/ic_drink_cocktail.svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="#333333"><path d="M21 5V3H3v2l8 9v5H6v2h12v-2h-5v-5l8-9zM7.4 5h9.2l-3.6 4-2-2.2-3.6-1.8z"/></svg>
SVGEOF

cat << 'SVGEOF' > $DIR/ic_drink_sake.svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="#333333"><path d="M15 6V4h-6v2l-3 4v10h12V10l-3-4zM9 16v-2h6v2H9z"/></svg>
SVGEOF

cat << 'SVGEOF' > $DIR/ic_drink_bottle.svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="#333333"><path d="M17 10h-1V5c0-1.1-.9-2-2-2h-4c-1.1 0-2 .9-2 2v5H7c-1.1 0-2 .9-2 2v9c0 1.1.9 2 2 2h10c1.1 0 2-.9 2-2v-9c0-1.1-.9-2-2-2zM10 5h4v5h-4V5z"/></svg>
SVGEOF

chmod +x generate_drink_svgs.sh
./generate_drink_svgs.sh
