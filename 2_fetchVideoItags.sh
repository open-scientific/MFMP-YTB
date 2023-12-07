#!/bin/bash
# quick curl script to fetch each videos ITAG metadata

RUN=true

if [ -f "db/mfmp.db" ]
then 
    echo "Database exists"
    sqlite3 db/mfmp.db "select * from itags"  > /dev/null
    if [ ! "$?" = 0 ]
    then
        echo "Database is not valid, adding new table" 
        sqlite3 db/mfmp.db "create table itags (itag_id text primary key, video_id text, itag integer, fps integer, video_quality text, audio_quality text, audio_channels integer, size integer, bitrate integer, mime_type text, foreign key (video_id) references videos (videoId))"
# [
#   {
#     "Itag": 315,
#     "FPS": 60,
#     "VideoQuality": "2160p60",
#     "AudioQuality": "",
#     "AudioChannels": 0,
#     "Size": 84878428,
#     "Bitrate": 15778125,
#     "MimeType": "video/webm; codecs=\"vp9\""
#   },
    fi
else
    echo "Database does not exist, exiting, prior steps should have created it"
    RUN=false
fi

while [ "$RUN" = true ]
do 
    for videoID in `sqlite3 db/mfmp.db "select videoId from videos"`
    do  
        echo "Fetching $videoID"
        if [[ "$videoID" =~  [^.{11}] ]]
        then 
            CHECKTABLE=$(sqlite3 db/mfmp.db "select * from itags where video_id = '$videoID'")
            if [[ -n $CHECKTABLE ]] 
            then
                echo "Video items already loaded"
            else
                echo "Loading Data" 
                ITAGDATA=$(youtubedr info "/$videoID" -f json | jq '.Formats')
                if [ ! $? = 0 ]
                then
                    RUN2=false
                else 
                    RUN2=true
                fi
                
                ITEM=0
                while [ "$RUN2" = true ] 
                do 
                    echo "Loading Items" 
                    ITAGITEM=$(echo $ITAGDATA | jq '.['$ITEM']') 
                    if [ "$ITAGITEM" = "null" ]
                    then 
                        echo "No more items"
                        RUN2=false
                    fi

                    ITAG=$(echo $ITAGITEM | jq '.Itag')
                    FPS=$(echo $ITAGITEM | jq '.FPS')
                    VIDEO_QUALITY=$(echo $ITAGITEM | jq '.VideoQuality')
                    AUDIO_QUALITY=$(echo $ITAGITEM | jq '.AudioQuality')
                    AUDIO_CHANNELS=$(echo $ITAGITEM | jq '.AudioChannels')
                    SIZE=$(echo $ITAGITEM | jq '.Size')
                    BITRATE=$(echo $ITAGITEM | jq '.Bitrate')
                    MIME_TYPE=$(echo $ITAGITEM | jq '.MimeType')
                    itag_id="$videoID-$ITAG"
                    
                    if ! [ "$ITAG" = "null" ]
                    then 
                        # if ! [ "$FPS" = 0 ]
                        # then
                        #     if ! [ "$AUDIO_CHANNELS" =  0 ]
                        #     then 
                                sqlite3 db/mfmp.db "insert or replace into itags (itag_id, video_id, itag, fps, video_quality, audio_quality, audio_channels, size, bitrate, mime_type) values ('$itag_id', '$videoID', '$ITAG', '$FPS', '$VIDEO_QUALITY', '$AUDIO_QUALITY', '$AUDIO_CHANNELS', '$SIZE', '$BITRATE', '$MIME_TYPE')"
                        #     fi 
                        # fi 
                    else 
                        RUN2=false
                    fi
                    ITEM=$((ITEM+1))
                    #read -p "Press [Enter] to continue..."
                done
            fi
        fi 
        
        #read -p "Press [Enter] to continue..."
    done
    echo "Finished"
    RUN=false
done