#!/bin/bash
# quick curl script to process the pages and extract data

PAGE=0
RUN=true

if [ -f "db/mfmp.db" ]
then 
    echo "Database exists"
else
    echo "Database does not exist, creating"
    sqlite3 db/mfmp.db "create table videos (videoId text primary key, title text, publishedAt text)"
fi

while [ "$RUN" = true ]
do
    if [! -f "data/page-$PAGE.json" ]
    then
        RUN=false
    fi
    
    echo "Page $PAGE"
    PAGEDATA=$(jq -r . data/page-$PAGE.json)
    #TOTALITEMS=$(echo $PAGEDATA | jq -r .pageInfo.totalResults data/page-$PAGE.json)
    ITEMS=$(echo $PAGEDATA | jq -r .pageInfo.resultsPerPage data/page-$PAGE.json)
    ITEM=0
    while [ ! "$ITEM" = "$ITEMS" ]
    do
        VIDEOID=$(echo $PAGEDATA | jq -r .items[$ITEM].id.videoId)
        TITLE=$(echo $PAGEDATA | jq -r .items[$ITEM].snippet.title)
        PUBLISHED=$(echo $PAGEDATA | jq -r .items[$ITEM].snippet.publishedAt)

        echo "Item: $ITEM VideoID: $VIDEOID TITLE: $TITLE DATE: $PUBLISHED"

        sqlite3 db/mfmp.db "insert or replace into videos (videoId, title, publishedAt) values ('$VIDEOID', '$TITLE', '$PUBLISHED')"
        ITEM=$(($ITEM+1))
        read -p "Press [Enter] to continue..."
    done 

    PAGE=$(($PAGE+1))
    read -p "Press [Enter] to continue..."
done

#sqlite3 db/mfmp.db "select * from videos"
