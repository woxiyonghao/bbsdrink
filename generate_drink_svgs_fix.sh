#!/bin/bash
DIR="entry/src/main/resources/base/media"

# Herbal / Tea (Local Florist / Flower)
cat << 'SVGEOF' > $DIR/ic_drink_herbal.svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="#333333">
  <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8 8 3.59 8 8-3.59 8-8 8zM11 6h2v6h-2zm0 8h2v2h-2z"/>
</svg>
SVGEOF

# Supplement (Flask/Bottle)
cat << 'SVGEOF' > $DIR/ic_drink_bottle.svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="#333333">
  <path d="M20 2H4v2h16V2zm-9 19c-1.1 0-2-.9-2-2V9c0-1.1.9-2 2-2s2 .9 2 2v10c0 1.1-.9 2-2 2z"/>
</svg>
SVGEOF

# Action Drink (Checkmark)
cat << 'SVGEOF' > $DIR/ic_action_drink2.svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="#333333">
  <path d="M9 16.2L4.8 12l-1.4 1.4L9 19 21 7l-1.4-1.4L9 16.2z"/>
</svg>
SVGEOF

