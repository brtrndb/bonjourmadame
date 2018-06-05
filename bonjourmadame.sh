#!/bin/bash
# Bertrand B.

BM_URL="http://www.bonjourmadame.fr/"

DEFAULT_FOLDER="$HOME/Images/BM";
DEFAULT_NAME=BM-`date +%F`;

CONNECTED=`ping -c 1 google.com > /dev/null 2>&1 && echo $?`;
TARGET_FOLDER=$DEFAULT_FOLDER;

usage () {
    echo "Usage: $(basename "$0") { -c | -i } [ target name ]";
    echo "-c, --cron:   Add a crontab entry every weekdays at 10:30AM."
    echo "-i, --image:  Donwload the daily Madame."
    echo "-h, --help:   Display usage."
}

prepare_folder() {
  if [ "$1" = "." ]; then
    TARGET_FOLDER=`pwd`;
  fi

  if [ ! -d "$TARGET_FOLDER" ]; then
    mkdir -p $TARGET_FOLDER;
  fi
}

dl() {
  if [ -z "$2" ]; then
    IMG_NAME=$DEFAULT_NAME;
  else
    IMG_NAME=$2;
  fi

  IMG_URL=`wget -O - -q $1 | grep -Eo "(http[s]?://[0-9]+.media.tumblr.com/[0-9a-f]*/tumblr[^\"]+)" | head -n 1` ;
  IMG_EXTENSION="${IMG_URL##*.}";
  IMG_PATH=$TARGET_FOLDER/$IMG_NAME.$IMG_EXTENSION;

  if [ ! -f "$IMG_PATH" ]; then
    wget -nv $IMG_URL -O $IMG_PATH;
  else
    echo "File [$IMG_PATH] already exists.";
  fi;
}


bm_single () {
  prepare_folder $1;
  if [ "0" -eq "$CONNECTED" ] ; then
    dl $BM_URL $2;
  else
    echo "There is no internet connection.";
  fi
}

bm_cron() {
  CRONTAB=`crontab -u $USER -l 2> /dev/null | grep -v "bonjourmadame.sh"`;
  CRON="30 10 * * Mon-Fri $PWD/$0 -i"
  if [ -z "$CRONTAB" ]; then
    echo -e "$CRON" | crontab -u $USER -;
  else
    echo -e "$CRONTAB\n$CRON" | crontab -u $USER -;
  fi
  echo "Cron created: $CRON";
}

run() {
  case "$1" in
    -c | --cron)
      bm_cron $0;
    ;;
    -i | --image)
      bm_single $2 $3;
    ;;
    *)
      usage;
    ;;
  esac
}

run $*;
