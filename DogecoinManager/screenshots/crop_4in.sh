#!/bin/bash

FILE="$1"
FILE_CROPPED=$(echo "$FILE" | sed 's/\.png/-cropped.png/')

convert "$FILE" +repage -gravity South -crop 640x1096+0+0 +repage "$FILE_CROPPED"
