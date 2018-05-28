#!/bin/bash
# Bertrand B.

# Usage:
# $1 = Target directory.
# $2 = Photo filename.

BM_URL="http://www.bonjourmadame.fr/"

DEFAULT_FOLDER="$HOME/Images/BM";
DEFAULT_NAME=BM-`date +%F`;
CONNECTED=`ping -c 1 google.com > /dev/null 2>&1 && echo $?`;

if [ "0" -eq "$CONNECTED" ] ; then
  if [ -z "$1" ]; then
    TARGET_FOLDER=$DEFAULT_FOLDER;
  elif [ "$1" = "." ]; then
    TARGET_FOLDER=`pwd`;
  fi

  if [ -z "$2" ]; then
    IMG_NAME=$DEFAULT_NAME;
  fi

  if [ ! -d "$TARGET_FOLDER" ]; then
    mkdir -p $TARGET_FOLDER;
  fi

  IMG_URL=`wget -O - -q $BM_URL | grep -Eo "(http[s]?://[0-9]+.media.tumblr.com/[0-9a-f]*/tumblr[^\"]+)" | head -n 1` ;
  IMG_EXTENSION="${IMG_URL##*.}";
  IMG_PATH=$TARGET_FOLDER/$IMG_NAME.$IMG_EXTENSION;

  if [ ! -f "$IMG_PATH" ]; then
    wget -nv $IMG_URL -O $IMG_PATH;
  else
    echo "File [$IMG_PATH] already exists.";
  fi;
else
  echo "There is no internet connection.";
fi
