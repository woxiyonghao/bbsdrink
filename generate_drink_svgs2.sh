#!/bin/bash
DIR="entry/src/main/resources/base/media"
mkdir -p $DIR

cat << 'SVGEOF' > $DIR/ic_drink_lemon.svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="#333333"><path d="M20 3H4v10c0 4.42 3.58 8 8 8s8-3.58 8-8V3zm-2 2v3H6V5h12zm-6 12c-2.76 0-5-2.24-5-5V10h10v2c0 2.76-2.24 5-5 5z"/></svg>
SVGEOF

cat << 'SVGEOF' > $DIR/ic_drink_sports.svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="#333333"><path d="M12 2L4 14h6v8l8-12h-6l6-8z"/></svg>
SVGEOF

cat << 'SVGEOF' > $DIR/ic_drink_sparkling.svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="#333333"><path d="M8 4h8v2H8zm-1 4h10v12c0 1.1-.9 2-2 2H9c-1.1 0-2-.9-2-2V8zm2 2v10h6V10H9zm1-5h4v1h-4z"/><circle cx="12" cy="14" r="1.5"/><circle cx="10" cy="18" r="1"/><circle cx="14" cy="17" r="1"/></svg>
SVGEOF

cat << 'SVGEOF' > $DIR/ic_drink_coconut.svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="#333333"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8 8 3.59 8 8-3.59 8-8 8z"/><circle cx="8.5" cy="9.5" r="1.5"/><circle cx="15.5" cy="9.5" r="1.5"/><circle cx="12" cy="13" r="1.5"/></svg>
SVGEOF

cat << 'SVGEOF' > $DIR/ic_drink_herbal.svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="#333333"><path d="M12 3c-4.97 0-9 4.03-9 9s4.03 9 9 9 9-4.03 9-9c0-.46-.04-.92-.1-1.36-.98 1.37-2.58 2.26-4.4 2.26-2.98 0-5.4-2.42-5.4-5.4 0-1.81.89-3.41 2.26-4.39C12.92 3.04 12.46 3 12 3z"/></svg>
SVGEOF

cat << 'SVGEOF' > $DIR/ic_drink_cocoa.svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="#333333"><path d="M20 3H4v10c0 2.21 1.79 4 4 4h6c2.21 0 4-1.79 4-4v-3h2c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm0 5h-2V5h2v3zM4 19h16v2H4v-2z"/></svg>
SVGEOF

cat << 'SVGEOF' > $DIR/ic_action_drink2.svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="#333333"><path d="M21 4H11V2H9v2H3v2h2v12c0 2.21 1.79 4 4 4h6c2.21 0 4-1.79 4-4V6h2V4zm-4 14H7V6h10v12zM9 11h2v6H9zm4 0h2v6h-2z"/></svg>
SVGEOF
