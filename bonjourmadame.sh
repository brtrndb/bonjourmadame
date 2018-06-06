#!/bin/bash
# Bertrand B.

BM_URL="http://www.bonjourmadame.fr"
TARGET="$HOME/Images/BM";
NB_DL=0;
CRON=false;
DATE="";

usage() {
    echo "Usage: $(basename "$0") { -c | -t | -a | -h } [ -d date ] [ -f folder ]";
    echo "-c, --cron:   Add a crontab entry every weekdays at 10:30AM."
    echo "-t, --today:  Donwload today's Madame.";
    echo "-a, --all:    Donwload all Madames.";
    echo "-d, --date:   Download Madam for a specific date.";
    echo "-f, --folder: Target folder for pics.";
    echo "-h, --help:   Display usage.";
}

configure_bm() {
  while [ "$#" -gt "0" ]; do
    case "$1" in
      -c | --cron)
        CRON=true;
        shift 1;
      ;;
      -t | --today)
        NB_DL=0;
        shift 1;
      ;;
      -a | --all)
        NB_DL=1000;
        shift 1;
      ;;
      -d | --date)
        DATE=$2;
        shift 2;
      ;;
      -f | --folder)
        TARGET=$2;
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

create_folder_if_needed() {
  if [ "$TARGET" = "." ]; then
    TARGET=`pwd`;
  fi

  if [ ! -d "$TARGET" ]; then
    mkdir -vp $TARGET;
  fi
}

dl() {
  LS=`ls $TARGET/$2* 2> /dev/null`;
  if [ -f "$LS" ]; then
    echo "File for $2 already exists.";
    return;
  fi;

  IMG_URL=`wget -O - -q $1 | grep -Eo "(http[s]?://[0-9]+.media.tumblr.com/[0-9a-f]*/tumblr[^\"]+)" | head -n 1` ;
  IMG_EXTENSION="${IMG_URL##*.}";
  IMG_PATH=$TARGET/$2.$IMG_EXTENSION;
  wget -nv $IMG_URL -O $IMG_PATH;
}

dl_by_date() {
  TODAY=`date +%s`;
  DD=`date -d $DATE +%s`;
  NAME=BM-$DATE;
  URL=$BM_URL/page/`echo "($TODAY - $DD) / (24 * 3600)" | bc`;
  echo -n "BM-0: ";
  dl $URL $NAME;
}

dl_all() {
  TODAY=`date +%F`;
  for i in `seq 0 $NB_DL`; do
    NAME=BM-`date --date="$TODAY - $i day" +%F`;
    URL=$BM_URL/page/$i;
    echo -n "BM-$i: ";
    dl $URL $NAME;
  done
}

bm() {
  CONNECTED=`ping -c 1 google.com > /dev/null 2>&1 && echo $?`;
  if [ ! "0" -eq "$CONNECTED" ] ; then
    echo "There is no internet connection.";
    return;
  fi

  create_folder_if_needed;
  if [ -z "$DATE" ]; then
    dl_all;
  else
    dl_by_date;
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
  configure_bm $*;
  if [ "$CRON" = "true" ]; then
    bm_cron;
  else
    bm;
  fi
}

run $*;
