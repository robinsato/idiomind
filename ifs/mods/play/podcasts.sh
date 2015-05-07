#!/bin/bash
# -*- ENCODING: UTF-8 -*-

if [ ! -n "$_videos" ]; then
_videos="$(sed -n 9p "$DC_s/1.cfg" \
| grep -o videos=\"[^\"]* | grep -o '[^"]*$')"
_news="$(sed -n 18p "$DC_s/1.cfg" \
| grep -o news=\"[^\"]* | grep -o '[^"]*$')"
_saved="$(sed -n 19p "$DC_s/1.cfg" \
| grep -o saved=\"[^\"]* | grep -o '[^"]*$')"
export _videos _news _saved
fi

if [ -f "$DM_tl/Podcasts/cache/$fname.item" ]; then
channel="$(sed -n 1p "$DM_tl/Podcasts/cache/$fname.item" \
| grep -o channel=\"[^\"]* | grep -o '[^"]*$')"
if [ "$_videos" = "TRUE" ] && ([ "$_news" = "TRUE" ] || [ "$_saved" = "TRUE" ]); then
find "$DM_tl/Podcasts/cache"/ -type f \( -name "*.avi" -o -name "*.mp4" -o -name "*.m4v" \) > "$DT/index.m3u"
"$DS/stop.sh" 3 && mplayer -fs -playlist "$DT/index.m3u"
else
[ -f "$DM_tl/Podcasts/cache/$fname.mp3" ] && file="$DM_tl/Podcasts/cache/$fname.mp3" && t=3
[ -f "$DM_tl/Podcasts/cache/$fname.ogg" ] && file="$DM_tl/Podcasts/cache/$fname.ogg" && t=3
[ -f "$DM_tl/Podcasts/cache/$fname.m4v" ] && file="$DM_tl/Podcasts/cache/$fname.m4v" && t=4
[ -f "$DM_tl/Podcasts/cache/$fname.mp4" ] && file="$DM_tl/Podcasts/cache/$fname.mp4" && t=4
[ -f "$DM_tl/Podcasts/cache/$fname.avi" ] && file="$DM_tl/Podcasts/cache/$fname.avi" && t=4

if [ "$t" = 3 ]; then
trgt="$title"
srce="$channel"
play=play
icon=idiomind
elif [ "$t" = 4 ]; then
trgt="$title"
srce="$channel"
play=mplayer
icon=idiomind
fi
fi
else
stop_loop "$DM_tl/Podcasts/cache/$fname.item"
fi
