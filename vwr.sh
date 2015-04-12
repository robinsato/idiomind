#!/bin/bash
# -*- ENCODING: UTF-8 -*-

echo "_" >> "$DT/stats.tmp" &
[[ "$1" = 1 ]] && index="$DC_tlt/1.cfg"
[[ "$1" = 2 ]] && index="$DC_tlt/2.cfg"
re='^[0-9]+$'
now="$2"
nuw="$3"
listen="$(gettext "Listen")"

if ! [[ $nuw =~ $re ]]; then
nuw=$(grep -Fxon "$now" < "$index" | sed -n 's/^\([0-9]*\)[:].*/\1/p')
nll=" "; fi

item="$(sed -n "$nuw"p "$index")"
if [ -z "$item" ]; then
item="$(sed -n 1p "$index")"
nuw=1; fi

fname="$(echo -n "$item" | md5sum | rev | cut -c 4- | rev)"
align=left
fs=22; bs=20

if [ -f "$DM_tlt/words/$fname.mp3" ]; then
    word_view

elif [ -f "$DM_tlt/$fname.mp3" ]; then
    sentence_view
    
else
    ff=$((nuw+1))
    echo "_" >> "$DT/sc"
    [ $(wc -l < "$DT/sc") -ge 5 ] && rm -f "$DT/sc" & exit 1 \
    || "$DS/vwr.sh" "$1" "$nll" "$ff" & exit 1
fi
    ret=$?
        
    if [ $ret -eq 4 ]; then
    "$DS/mngr.sh" edit "$1" "$nuw"
    elif [ $ret -eq 2 ]; then
    ff=$((nuw-1))
    "$DS/vwr.sh" "$1" "$nll" $ff &
    elif [ $ret -eq 3 ]; then
    ff=$((nuw+1))
    "$DS/vwr.sh" "$1" "$nll" $ff &
    else 
    printf "vwr.$(wc -l < "$DT/stats.tmp").vwr\n" >> "$DC_s/8.cfg"
    rm -f "$DT/stats.tmp" & exit 1
    fi
