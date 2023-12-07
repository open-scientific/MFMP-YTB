#!/bin/bash
# quick curl script to test the API

APIKEY=REDACTED
CHANNELID=UCEy09JW5XAd95JmknU1JOeQ
PAGE=0
RUN=true
NEXTPAGE=""
LASTPAGE="none" 

while [ "$RUN" = true ]
do
    echo "Page $PAGE"
    echo "nextPage $NEXTPAGE"

    if [ -f "data/page-$PAGE.json" ] 
    then 
        echo "file exist" 
        #RUN=false
    else
        curl -f -X GET -H "Content-Type: application/json" "https://www.googleapis.com/youtube/v3/search?key=$APIKEY&channelId=$CHANNELID&part=snippet,id&order=date&maxResults=50&pageToken=$NEXTPAGE" -o data/page-$PAGE.json
        CRET=$? 
        NEXTPAGE=""
    fi
    
    if [ ! $CRET = 0 ]
    then
        echo "Curl ERROR"
        RUN=false
        exit $?
    fi

    NEXTPAGE=$(jq -r .nextPageToken data/page-$PAGE.json)
    
    if [ "$NEXTPAGE" = "null" ]
    then
        echo "No more pages"
        RUN=false
    fi
    
    if [ "$NEXTPAGE" = "" ]
    then
        echo "No more pages"
        RUN=false
    fi

    if [ "$NEXTPAGE" = "$LASTPAGE" ]
    then
        echo "No more pages"
        RUN=false
    fi
    
    LASTPAGE=$NEXTPAGE
    PAGE=$((PAGE+1))

    #press enter to continue
    read -p "Press [Enter] to continue..."
    echo ""
done

#PAGEDATA$($PAGE)=$(jq -r . data/page-$PAGE.json)
