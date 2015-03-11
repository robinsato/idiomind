#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
#--text=" <small> $(gettext "Playing:") datos de usauario de podcasts evitar</small>\n \
#<small> $(gettext "Next:") datos de usauario de podcasts evitar </small>" \

itms="Words
Sentences
Marks
Practice
News episodes
Saved epidodes"

if [ "$1" = time ]; then

    c=$(mktemp "$DT"/c.XXX)
    bcl=$(cat "$DC_s/2.cfg")
    if [ -z "$bcl" ]; then
        echo 8 > "$DC_s/2.cfg"
        bcl=$(sed -n 1p "$DC_s/2.cfg"); fi
    yad --mark="8 s":8 --mark="60 s":60 \
    --mark="120 s":120 --borders=20 --scale \
    --max-value=128 --value="$bcl" --step 1 \
    --name=idiomind --on-top --skip-taskbar \
    --window-icon=idiomind --borders=5 \
    --title=" " --width=280 --height=240 \
    --min-value=0 --button="Ok":0 > $c
    [ "$?" -eq 0 ] && cat "$c" > "$DC_s/2.cfg"
    rm -f "$c"; exit 1

elif [ -z "$1" ]; then

    echo "$tpc"
    tlng="$DC_tlt/1.cfg"
    winx="$DC_tlt/3.cfg"
    sinx="$DC_tlt/4.cfg"
    [ -z "$tpc" ] && exit 1
    if [ "$(cat "$sinx" | wc -l)" -gt 0 ]; then
        in1=$(grep -Fxvf "$sinx" "$tlng")
    else
        in1=$(cat "$tlng")
    fi
    if [ "$(cat "$winx" | wc -l)" -gt 0 ]; then
        in2=$(grep -Fxvf "$winx" "$tlng")
    else
        in2=$(cat "$tlng")
    fi
    in3=$(cat "$DC_tlt/6.cfg")
    cd "$DC_tlt/practice"
    in4=$(cat w6 | sed '/^$/d' | sort | uniq)
    in5=$(cat "$DM_tl/Feeds/.conf/1.cfg" | sed '/^$/d')
    in6=$(cat "$DM_tl/Feeds/.conf/2.cfg" | sed '/^$/d')
    u=$(echo "$(whoami)")
    infs=$(echo "$snts Sentences" | wc -l)
    infw=$(echo "$wrds Words" | wc -l)

    [ ! -d "$DT/p" ] && mkdir "$DT/p"; cd "$DT/p"
    
    function setting_1() {
        n=1
        while [ $n -le 6 ]; do
                arr="in$n"
                [[ -z ${!arr} ]] && echo "$DS/images/addi.png" \
                || echo "$DS/images/add.png"
            echo "  <span font_desc='Verdana 10'>$(gettext "$(echo "$itms" | sed -n "$n"p)")</span>"
            echo $(sed -n "$n"p "$DC_s/5.cfg" | cut -d '|' -f 3)
            let n++
        done
    }

    c=$(echo $(($RANDOM%100000))); KEY=$c
    slct1=$(mktemp "$DT"/slct1.XXXX)
    slct2=$(mktemp "$DT"/slct2.XXXX)
    [ -f "$DT/.p_" ] && btn="gtk-media-stop:2" || btn="Play:0"
    setting_1 | yad --list  --separator="|" \
    --expand-column=2 --print-all \
    --no-headers --name=idiomind --center \
    --column=IMG:IMG --column=TXT:TXT --column=CHK:CHK \
    --class=Idiomind --align=right --center  \
    --width=380 --height=310 --title="Playlists" --on-top \
    --window-icon=idiomind --borders=5 --always-print-result \
    --button="Cancel":1 --button="$btn" --skip-taskbar > "$slct1"
    ret=$?
    
    if [ "$ret" -eq 1 ]; then exit 1; fi
    
    if [ "$ret" -eq 0 ]; then
    
        mv -f "$slct1" "$DC_s/5.cfg"
        mv -f "$slct2" "$DC_s/11.cfg"
        cd "$DT/p"; > ./indx; n=1
        
        while read set; do
            if grep TRUE <<< "$set"; then
                lst="in$n"
                echo "${!lst}" >> ./indx
            fi
            let n++
        done < "$DC_s/5.cfg"

    elif [ "$ret" -eq 2 ]; then
        rm -f "$slct"
        [ -d "$DT/p" ] && rm -fr "$DT/p"
        [ -f "$DT/.p_" ] && rm -f "$DT/.p_"
        /usr/share/idiomind/stop.sh play & exit
    else
        if  [ ! -f "$DT/.p_" ]; then
            [ -d "$DT/p" ] && rm -fr "$DT/p"
        fi
        mv -f "$slct2" "$DC_s/11.cfg"
        rm -f "$slct1" "$slct2"
        exit 1
    fi

    rm -f "$slct"
    "$DS/stop.sh" playm

    if ! [ "$(cat "$DC_s/5.cfg" | head -n7 | grep -o "TRUE")" ]; then
        notify-send "$(gettext "Exiting")" "$(gettext "Nothing specified to play")" -i idiomind -t 3000 &&
        sleep 5
        "$DS/stop.sh" play
    fi

    if [ -z "$(cat "$DT/p/indx")" ]; then
        notify-send -i idiomind "$(gettext "Exiting")" "$(gettext "Nothing to play")" -t 3000 &
        rm -f "$DT/.p_" &
        "$DS/stop.sh" play & exit 1
    fi
    
    printf "plyrt.$tpc.plyrt\n" >> "$DC_s/30.cfg" &
    sleep 1
    "$DS/bcle.sh" & exit
fi
