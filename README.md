# MFMP-YTB

Tool to backup videos from 3rd party YT Channel, specifically https://www.youtube.com/@MFMP/videos without account owner or such permissions.

[ ] Github Action > Collect metadata and upsert to db-file to distribute from this repo.
[ ] Script video archive process to run in users local environment.

## Metadata backup

https://console.cloud.google.com/apis/library/youtube.googleapis.com
Goto Credentials > Create credentials > API Key

APIKEY=REDACTED
CHANNELID=UCEy09JW5XAd95JmknU1JOeQ
https://www.googleapis.com/youtube/v3/search?key=REDACTED&channelId=UCEy09JW5XAd95JmknU1JOeQ&part=snippet,id&order=date&maxResults=50

maxResults limited to 50 per page, ?howto use nextPageToken/prevPageToken, add param pageToken to request.
Looks to have past live events and shorts in the list of items.

.nextPageToken
.pageInfo.totalResults

.items[].id.videoId
.items[].snippet.title
.items[].snippet.publishedAt

Oldest video seems to be 'OHMA : 10 Yen vs Ohmasa Gas	2019-07-27T00:24:55Z'
Yet we have a null videoID of 'Martin Fleischmann Memorial Project	2012-08-21T13:43:40Z' 

Is the data API time limited?

Only ITAGS with audio and video are 22 720p and 18 360p. 

## Video backup

### youtubedr tool

VIDEO=CbwGT-jplxI
youtubedr download $VIDEO -q $(youtubedr info $VIDEO -f json | jq '.Formats[0].Itag') #Rely on first item being highest quality (Nope since it has no audio track)

Limited to 720p 

### youtube-dl tool

https://github.com/ytdl-org/youtube-dl


# Appendix

Found this similar ref:https://github.com/w0d4/yt-backup
