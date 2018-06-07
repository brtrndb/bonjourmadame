#!/bin/bash
# Bertrand B.

BASE_URL="http://www.bonjourmadame.fr"
FOLDER="$HOME/Images/BM";
COUNT=0;
CRON=false;
DATE="";
DATE_LOW="2015-11-30";

usage() {
    echo "Usage: $(basename "$0") { -c | -t | -a | -h } [ -d date ] [ -f folder ]";
    echo "-c, --cron:   Add a crontab entry every weekdays at 10:30AM."
    echo "-t, --today:  Donwload today's Madame.";
    echo "-a, --all:    Donwload all Madames.";
    echo "-d, --date:   Download Madame for a specific date. Note: lowest date is $DATE_LOW.";
    echo "-f, --folder: Target folder for pics.";
    echo "-h, --help:   Display usage.";
}

bm_configure() {
  while [ "$#" -gt "0" ]; do
    case "$1" in
      -c | --cron)
        CRON=true;
        shift 1;
      ;;
      -t | --today)
        COUNT=0;
        shift 1;
      ;;
      -a | --all)
        TODAY=`date --date="$TODAY" +%s`;
        DATE_LOW=`date --date="$DATE_LOW" +%s`;
        COUNT=`echo "(($TODAY - $DATE_LOW) / (24 * 3600) + 1)" | bc`;
        shift 1;
      ;;
      -d | --date)
        DATE=$2;
        shift 2;
      ;;
      -f | --folder)
        FOLDER=$2;
        shift 2;
      ;;
      -h | --help)
        usage;
        exit 0;
      ;;
      -* | --*)
        echo "Unknown option: $1. Ignored."
        shift 1;
      ;;
    esac
  done
}

bm_create_folder() {
  if [ "$FOLDER" = "." ]; then
    FOLDER=`pwd`;
  fi

  if [ ! -d "$FOLDER" ]; then
    mkdir -vp $FOLDER;
  fi
}

bm_download() {
  LS=`ls $FOLDER/$2* 2> /dev/null`;
  if [ -f "$LS" ]; then
    echo "File for $2 already exists.";
    return;
  fi;

  PAGE=`wget -O - -q $1`;
  IMG_URL=`echo $PAGE | grep -Eo "(http[s]?://[0-9]+.media.tumblr.com/[0-9a-f]*/tumblr[^\"]+)" | head -n 1` ;
  IMG_LEGEND=`echo $PAGE | grep -Eo "((<p>){2}.*(<\/p>){2})" | awk -F'(<p><p>)|(</p></p>)' '{print $2}' | awk '{gsub("<[^>]*>", "")}1' | recode html..utf8`;
  IMG_EXTENSION="${IMG_URL##*.}";
  IMG_PATH=$FOLDER/$2.$IMG_EXTENSION;
  echo -n "$2:";
  wget -q $IMG_URL -O $IMG_PATH;
  echo " $IMG_LEGEND";
}

bm_download_by_date() {
  NAME=BM-$DATE;
  TODAY=`date +%s`;
  DATE=`date -d $DATE +%s`;
  URL=$BASE_URL/page/`echo "($TODAY - $DATE) / (24 * 3600)" | bc`;
  bm_download $URL $NAME;
}

bm_download_all() {
  TODAY=`date +%F`;
  for i in `seq 1 $COUNT`; do
    NAME=BM-`date --date="$TODAY - $(( i - 1 )) day" +%F`;
    URL=$BASE_URL/page/$i;
    bm_download $URL $NAME;
  done
}

bm() {
  CONNECTED=`ping -c 1 google.com > /dev/null 2>&1 && echo $?`;
  if [ ! "0" -eq "$CONNECTED" ] ; then
    echo "There is no internet connection.";
    return;
  fi

  bm_create_folder;
  if [ -z "$DATE" ]; then
    bm_download_all;
  else
    bm_download_by_date;
  fi;
}

bm_cron() {
  CRONTAB=`crontab -u $USER -l 2> /dev/null | grep -v "bonjourmadame.sh -d"`;
  CONF="30 10 * * Mon-Fri $PWD/$0 -i"

  if [ -z "$CRONTAB" ]; then
    echo -e "$CONF" | crontab -u $USER -;
  else
    echo -e "$CRONTAB\n$CONF" | crontab -u $USER -;
  fi
  echo "Cron created: $CONF.";
}

run() {
  bm_configure $*;
  if [ "$CRON" = "true" ]; then
    bm_cron;
  else
    bm;
  fi
}

run $*;
