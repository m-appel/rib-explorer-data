#!/bin/bash
set -euo pipefail
# This script needs to be executed from the rib-explorer-data folder, else the
# files will be copied to a wrong place.

if [ ! $# -eq 1 ]; then
    echo "usage: $0 <path/to/rib-explorer>"
    exit 1
fi

RIB_EXPLORER_PATH="$1"
if [ ! -d "$RIB_EXPLORER_PATH" ]; then
    echo "error: specified path is not a directory"
    exit 1
fi

DATE_LONG=$(date --utc +%Y-%m-%dT00:00)
DATE_SHORT=$(date --utc +%Y%m%d)
NEW_FILE="$DATE_SHORT.min_3.merged.pickle.bz2"
SYMLINK_NAME=latest.pickle.bz2

pushd "$RIB_EXPLORER_PATH" > /dev/null
docker compose run --rm ribexplorer-volume all "$DATE_LONG" 4 8 3
docker compose run --rm ribexplorer-volume clean
popd
cp "$RIB_EXPLORER_PATH/merged/$NEW_FILE" data/
cp "$RIB_EXPLORER_PATH/stats/$DATE_SHORT"* stats/
rm $SYMLINK_NAME
ln -s "data/$NEW_FILE" "$SYMLINK_NAME"

git add .
git commit --author "rib-bot <malte@iij.ad.jp>" -m "Add dump $DATE_SHORT"
git push origin main
