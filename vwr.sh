#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
wth=$(sed -n 5p $DC_s/18.cfg)
eht=$(sed -n 6p $DC_s/18.cfg)
ap=$(sed -n 14p < $DC_s/1.cfg)
echo "_" >> "$DC_a/stats/.tmp" &
re='^[0-9]+$'
now="$2"
nuw="$3"
listen="▷"

[ "$1" = v1 ] && ind="$DC_tlt/1.cfg"
[ "$1" = v2 ] && ind="$DC_tlt/2.cfg"
if ! [[ $nuw =~ $re ]]; then
    nuw=$(cat "$ind" \
    | grep -Fxon "$now" \
    | sed -n 's/^\([0-9]*\)[:].*/\1/p')
    nll=" "
fi
item="$(sed -n "$nuw"p "$ind")"
if [ -z "$item" ]; then
    item="$(sed -n 1p "$ind")"
    nuw=1
fi
fname="$(echo -n "$item" | md5sum | rev | cut -c 4- | rev)"
[ "$(echo "$item" | wc -c)" -le 50 ] && align=center || align=left


if ( [ -f "$DM_tlt/words/$fname.mp3" ] || [ "$5" = w_fix ] ); then

    tgs=$(eyeD3 "$DM_tlt/words/$fname.mp3")
    trgt="$item"
    src=$(echo "$tgs" | grep -o -P '(?<=IWI2I0I).*(?=IWI2I0I)')
    exmp=$(echo "$tgs" | grep -o -P '(?<=IWI3I0I).*(?=IWI3I0I)' | tr '_' '\n')
    mrk=$(echo "$tgs" | grep -o -P '(?<=IWI4I0I).*(?=IWI4I0I)')
    [[ $(echo "$exmp" | sed -n 2p) ]] \
    && dfnts="--field=$(echo "$exmp" | sed -n 2p)\\n:lbl"
    [[ $(echo "$exmp" | sed -n 3p) ]] \
    && ntess="--field=$(echo "$exmp" | sed -n 3p)\\n:lbl"
    hlgt=$(echo $trgt | awk '{print tolower($0)}')
    exmp1=$(echo "$(echo "$exmp" | sed -n 1p)" | sed "s/"${trgt,,}"/<span background='#FDFBCF'>"${trgt,,}"<\/\span>/g")
    [[ "$(echo "$tgs" | grep -o -P '(?<=IWI4I0I).*(?=IWI4I0I)')" = TRUE ]] \
    && trgt=$(echo "* "$trgt"")
    [ "$ap" = TRUE ] && (killall play & sleep 1 && play "$DM_tlt/words/$fname.mp3") &
    yad --form --window-icon=idiomind --scroll --text-align=$align \
    --skip-taskbar --center --title=" " --borders=20 \
    --quoted-output --on-top --selectable-labels \
    --text="<span font_desc='Purisa Bold 22'>$trgt</span>\n\n<i>$src</i>\n" \
    --field="":lbl \
    --field="<i><span color='#7D7D7D'>$exmp1</span></i>:lbl" "$dfnts" "$ntess" \
    --width="$wth" --height="$eht" --center \
    --button=gtk-edit:4 --button="$listen":"play '$DM_tlt/words/$fname.mp3'" \
    --button=gtk-go-up:3 --button=gtk-go-down:2 >/dev/null 2>&1
    
    
elif ( [ -f "$DM_tlt/$fname.mp3" ] || [ "$5" = s_fix ] ); then

    tgs=$(eyeD3 "$DM_tlt/$fname.mp3")
    [[ $(sed -n 11p $DC_s/1.cfg) = TRUE ]] \
    && trgt=$(echo "$tgs" | grep -o -P '(?<=IGMI3I0I).*(?=IGMI3I0I)') \
    || trgt=$(echo "$tgs" | grep -o -P '(?<=ISI1I0I).*(?=ISI1I0I)')
    src=$(echo "$tgs" | grep -o -P '(?<=ISI2I0I).*(?=ISI2I0I)')
    lwrd=$(echo "$tgs" | grep -o -P '(?<=IPWI3I0I).*(?=IPWI3I0I)' | tr '_' '\n')
    [[ "$(echo "$tgs" | grep -o -P '(?<=ISI4I0I).*(?=ISI4I0I)')" = TRUE ]] \
    && trgt=$(echo "<b>*</b> "$trgt"")
    [[ ! -f "$DM_tlt/$fname.mp3" ]] && exit 1
    [ "$ap" = TRUE ] && (killall play & sleep 1 && play "$DM_tlt/$fname.mp3") &
    echo "$lwrd" | yad --list --print-column=0 --no-headers \
    --window-icon=idiomind --scroll --text-align=$align \
    --skip-taskbar --center --title=" " --borders=20 \
    --on-top --selectable-labels --expand-column=0 \
    --text="<span font_desc='Purisa Bold 15'>$trgt</span>\n\n<i>$src</i>\n\n" \
    --width="$wth" --height="$eht" --center \
    --column="":TEXT --column="":TEXT \
    --button=gtk-edit:4 --button="$listen":"$DS/ifs/tls.sh listen_sntnc '$fname'" \
    --button=gtk-go-up:3 --button=gtk-go-down:2 \
    --dclick-action="$DS/ifs/tls.sh dclik" >/dev/null 2>&1
    
else
    ff=$(($nuw + 1))
    echo "_" >> "$DT/sc"
    [ $(cat $DT/sc | wc -l) -ge 5 ] && rm -f "$DT/sc" & exit 1 \
    || "$DS/vwr.sh" "$1" "$nll" "$ff" & exit 1
fi

        ret=$?
        if [ $ret -eq 4 ]; then
            "$DS/mngr.sh" edt "$1" "$fname" "$nuw"
        elif [ $ret -eq 2 ]; then
            ff=$(($nuw + 1))
            "$DS/vwr.sh" "$1" "$nll" $ff &
        elif [ $ret -eq 3 ]; then
            ff=$(($nuw - 1))
            "$DS/vwr.sh" "$1" "$nll" $ff &
        else 
            printf "vwr.$(cat "$DC_a/stats/.tmp" | wc -l).vwr\n" >> \
            "$DC_s/30.cfg" &
            rm "$DC/addons/stats/.tmp" & exit 1
        fi
