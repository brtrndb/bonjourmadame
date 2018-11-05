#!/bin/sh
# Bertrand B.

# Script parameters.
PARAM_FOLDER="$HOME/Images/BM";
PARAM_CRON=false;
PARAM_DATE_START="`date +%F`";
PARAM_DATE_END="$PARAM_DATE_START";

URL_BM="http://www.bonjourmadame.fr";
URL_PING="www.google.com";
DATE_MIN="2015-12-01";
NULL="/dev/null";

usage() {
    echo "Usage: $(basename "$0") { -a | -t | -c | -h } [ -d date ] [ -f folder ]";
    echo "-a, --all:      Donwload all Madames.";
    echo "--start, --end: Start/end date.";
    echo "-t, --today:    Download today's Madame. This is the default option.";
    echo "-d, --date:     Download Madame for a specific date (YYYY-MM-DD). Note: lowest date is $DATE_MIN.";
    echo "-c, --cron:     Add a crontab entry every weekdays at 10:30AM.";
    echo "-f, --folder:   Target folder for photos. Default folder is $HOME/Images/BM.";
    echo "-h, --help:     Display usage.";
}

configure() {
    while [ "$#" -gt "0" ]; do
	case "$1" in
	    -c | --cron)
		PARAM_CRON=true;
		shift 1;
		;;
	    -t | --today)
		PARAM_DATE_START="`date +%F`";
		PARAM_DATE_END="$PARAM_DATE_START";
		shift 1;
		;;
	    -a | --all)
		PARAM_DATE_START="`date -d "$DATE_MIN" +%F`";
		PARAM_DATE_END="`date +%F`";
		shift 1;
		;;
	    --start)
		PARAM_DATE_START=$2;
		shift 2;
		;;
	    --end)
		PARAM_DATE_END=$2;
		shift 2;
		;;
	    -d | --date)
		PARAM_DATE_START=$2;
		PARAM_DATE_END=$2;
		shift 2;
		;;
	    -f | --folder)
		PARAM_FOLDER=$2;
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

mk_folder() {
    if [ "$PARAM_FOLDER" = "." ]; then
	PARAM_FOLDER=`pwd`;
    fi

    if [ ! -d "$PARAM_FOLDER" ]; then
	mkdir -vp $PARAM_FOLDER;
    fi
}

download_img() {
    PAGE_URL=$1;
    IMG_NAME=$2;

    LS=`ls $PARAM_FOLDER/$IMG_NAME* 2> $NULL`;
    if [ -f "$LS" ]; then
	echo "File for $IMG_NAME already exists.";
	return;
    fi;

    PAGE_HTML=`wget -q $PAGE_URL -O -`;
    IMG_URL=`echo $PAGE_HTML | grep -Eo "(http[s]?://[0-9]+.media.tumblr.com/[0-9a-f]*/tumblr[^\"]+)" | head -n 1` ;
    IMG_LEGEND=`echo $PAGE_HTML | grep -Eo "((<p>){2}.*(<\/p>){2})" | awk -F'(<p><p>)|(</p></p>)' '{print $2}' | awk '{gsub("<[^>]*>", "")}1' | recode html..utf8`;
    IMG_EXTENSION="${IMG_URL##*.}";
    IMG_PATH=$PARAM_FOLDER/$IMG_NAME.$IMG_EXTENSION;
    echo -n "$(basename $IMG_PATH):";
    wget -q $IMG_URL -O $IMG_PATH;
    echo " $IMG_LEGEND";
}

download_all() {
    DATE_START_F=$1;
    DATE_END_F=$2;
    DATE_START_S=`date -d "$DATE_START_F" +%s`;
    DATE_END_S=`date -d "$DATE_END_F" +%s`;
    COUNT=`echo "$(( ($DATE_END_S - $DATE_START_S) / (24 * 3600) + 1 ))"`;

    if [ "$COUNT" = "1" ]; then
	COUNT=0;
    fi

    echo "$(( COUNT + 1 )) Madame(s) will be downloaded.";
    for i in `seq 0 $(( COUNT ))`; do
	DATE_IMG_F=`date -d "$DATE_START_F + $(( i )) day" +%F`;
	DATE_IMG_S=`date -d "$DATE_IMG_F" +%s`;
	DATE_TODAY_S=`date +%s`;
	PAGE_URL=$URL_BM/page/$(( ($DATE_TODAY_S - $DATE_IMG_S) / (24 * 3600) + 1 ));
	IMG_NAME=BM-$DATE_IMG_F;
	echo -n "$(( i + 1 ))/$(( COUNT + 1 ))) "
	download_img $PAGE_URL $IMG_NAME;
    done
    echo "$(( COUNT + 1 )) Madame(s) were downloaded.";
}

bm() {
    CONNECTED=`ping -c 1 google.com > $NULL 2>&1 && echo $?`;
    if [ ! "0" -eq "$CONNECTED" ] ; then
	echo "There is no internet connection.";
	return;
    fi

    mk_folder;
    download_all $PARAM_DATE_START $PARAM_DATE_END;
}

setup_cron() {
    CRONTAB=`crontab -u $USER -l 2> $NULL | grep -v $(basename $0)`;
    CONF="30 10 * * Mon-Fri `readlink -f $0` -t";

    if [ -z "$CRONTAB" ]; then
	echo -e "$CONF\n" | crontab -u $USER -;
    else
	echo -e "$CRONTAB\n$CONF\n" | crontab -u $USER -;
    fi
    if [ "$?" = "0" ]; then
	echo "Cron created: $CONF.";
    else
	echo "Cron failed.";
    fi
}

run() {
    configure $*;
    if [ "$PARAM_CRON" = "true" ]; then
	setup_cron;
    else
	bm;
    fi
}

run $*;
