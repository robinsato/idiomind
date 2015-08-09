#!/bin/bash
# -*- ENCODING: UTF-8 -*-

play_word() {

    if [ -f "${DM_tls}/${2,,}.mp3" ]; then
    play "${DM_tls}/${2,,}.mp3" &
    elif [ -f "${DM_tlt}/$3.mp3" ]; then
    play "${DM_tlt}/$3.mp3" &
    elif [ -n "$synth" ]; then
    echo "${2}." | $synth &
    else
    echo "${2}." | espeak -v $lg -s 150 &
    fi
} >/dev/null 2>&1

play_sentence() {

    if [ -f "${DM_tlt}/$2.mp3" ]; then
    play "${DM_tlt}/$2.mp3" &
    elif [ -n "$synth" ]; then
    
    echo "${trgt}." | $synth &
    else
    echo "${trgt}." | espeak -v $lg -s 150 &
    fi
} >/dev/null 2>&1

play_file() {

    if [ -f "${2}" ]; then
    mplayer "${2}" -noconsolecontrols -title "${3}"
    elif [ -n "$synth" ]; then
    echo "${3}." | $synth
    else
    echo "${3}." | espeak -v $lg -s 150
    fi
} >/dev/null 2>&1

play_list() {
    
    if [ -z "${tpc}" ]; then source "$DS/ifs/mods/cmns.sh"
    msg "$(gettext "No topic is active")\n" info & exit 1; fi

    tpc="$(sed -n 1p "$HOME/.config/idiomind/s/4.cfg")"
    touch "${DC_tlt}/practice/log.3"
    DC_tlt="${DM_tl}/${tpc}/.conf"
    DC_tlp="${DM_tl}/Podcasts/.conf"
    [[ -n "$(< "${DC_tlt}/10.cfg")" ]] && cfg=1 || cfg=0
    
    lbls=( 'Words' 'Sentences' 'Marked items' 'Difficult words' \
    'New episodes <i><small>Podcasts</small></i>' \
    'Saved episodes <i><small>Podcasts</small></i>' )
    sets=( 'words' 'sntcs' 'marks' 'wprct' 'nsepi' 'svepi' \
    'rplay' 'audio' 'ntosd' 'loop' 'rword' 'video' )
    in=( 'in0' 'in1' 'in2' 'in3' 'in4' 'in5' )
    iteml=( "$(gettext "No repeat")" "$(gettext "Words")" "$(gettext "Sentences")" )
    
    in0="$(grep -Fxvf "${DC_tlt}/4.cfg" "${DC_tlt}/1.cfg" |wc -l)"
    in1="$(grep -Fxvf "${DC_tlt}/3.cfg" "${DC_tlt}/1.cfg" |wc -l)"
    in2="$(grep -Fxvf "${DC_tlt}/2.cfg" "${DC_tlt}/6.cfg" |wc -l)"
    in3="$(grep -Fxvf "${DC_tlt}/4.cfg" "${DC_tlt}/practice/log.3" |wc -l)"
    [ -f "$DM_tl/Podcasts/.conf/1.lst" ] && \
    in4="$(wc -l < "$DM_tl/Podcasts/.conf/1.lst")" || in5=0
    [ -f "$DM_tl/Podcasts/.conf/2.lst" ] && \
    in5="$(wc -l < "$DM_tl/Podcasts/.conf/2.lst")" || in6=0
    [ ! -d "$DT" ] && mkdir "$DT"; cd "$DT"

    if [ ${cfg} = 1 ]; then

        n=0
        while [ ${n} -le 11 ]; do
            get="${sets[$n]}"
            if [ ${n} = 4 -o ${n} = 5 -o ${n} = 11 ]; then
            cfg="$DC_tlp/podcasts.cfg"; else cfg="${DC_tlt}/10.cfg"; fi
            val=$(grep -o "$get"=\"[^\"]* "${cfg}" |grep -o '[^"]*$')
            declare ${sets[$n]}="$val"
            ((n=n+1))
        done
        
    else
        n=0; > "${DC_tlt}/10.cfg"
        while [ ${n} -le 11 ]; do
        echo -e "${sets[$n]}=\"0\"" >> "${DC_tlt}/10.cfg"
        ((n=n+1))
        done
    fi

    function setting_1() {
        n=0; 
        while [ ${n} -le 5 ]; do
            arr="in${n}"
            [[ ${!arr} -lt 1 ]] && echo "$DS/images/addi.png" || echo "$DS/images/add.png"
            echo "  <span font_desc='Arial 11'>$(gettext "${lbls[$n]}")</span>"
            echo "${!sets[${n}]}"
            let n++
        done
    }

    title="$tpc"
    if grep -E 'vivid|wily' <<<"`lsb_release -a`" >/dev/null 2>&1; then
    btn1="gtk-media-play:0"; else
    btn1="$(gettext "Play"):0"; fi
    
    if [ ! -f "$DT/.p_" ]; then
        btn2="--center"
    else
        tpp="$(sed -n 1p "$DT/.p_")"
        btn2="--button=gtk-media-stop:2"
        if [ -n "$tpp" -a ! -f "$DT/list.m3u" ]; then
        [ "$tpp" != "$tpc" ] && title="$(gettext "Playing:") $tpp"
        fi
    fi
    
    set="$(echo "${iteml[${rword}]}")"
    unset iteml[${rword}]
    lst=`for i in "${iteml[@]}"; do echo -n "!$i"; done`
    lst_opts1="$set$lst"
    tab1=$(mktemp "$DT/XXX.p")
    tab2=$(mktemp "$DT/XXX.p")
    c=$((RANDOM%100000)); KEY=$c
    
    setting_1 | yad --plug=$KEY --tabnum=1 --list \
    --print-all --always-print-result --separator="|" \
    --expand-column=2 --no-headers --borders=0 \
    --column=IMG:IMG \
    --column=TXT:TXT \
    --column=CHK:CHK > $tab1 &
    yad --plug=$KEY --form --tabnum=2 --borders=5 \
    --align=right --scroll \
    --separator='|' --always-print-result --print-all \
    --field="$(gettext "Repeat")":CHK "$rplay" \
    --field="$(gettext "Play audio")":CHK "$audio" \
    --field="$(gettext "Use desktop notifications")":CHK "$ntosd" \
    --field="$(gettext "Pause between items (sec)")":SCL "$loop" \
    --field="$(gettext "Repeat sounding out")":CB "$lst_opts1" \
    --field="":LBL "" \
    --field="$(gettext "Podcasts: Only play videos")":CHK "$video" > $tab2 &
    yad --notebook --key=$KEY --title="$title" \
    --name=Idiomind --class=Idiomind \
    --always-print-result --print-all \
    --window-icon="$DS/images/icon.png" \
    --align=right --fixed --center --on-top \
    --tab-pos=bottom --tab-borders=0 \
    --tab=" $(gettext "Lists") " \
    --tab="$(gettext "Options")" \
    --width=420 --height=315 --borders=0 \
    "$btn2" --button="$btn1"
    ret=$?

        tab1=$(< $tab1); tab2=$(< $tab2)
        rm -f "$DT"/*.p
        
        f=1; n=0
        while [ ${n} -le 11 ]; do
        
        if [ ${n} -lt 4 ]; then
        val=$(sed -n $((${n}+1))p <<<"${tab1}" |cut -d "|" -f3)
        [ -n "${val}" ] && sed -i "s/${sets[${n}]}=.*/${sets[${n}]}=\"$val\"/g" \
        "${DC_tlt}/10.cfg"
        if [ "$val" = TRUE ]; then
        count=$((count+$(egrep -cv '#|^$' <<<"${!in[${n}]}"))); fi
        
        elif [ ${n} = 4 -o ${n} = 5 ]; then
        val=$(sed -n $((${n}+1))p <<<"${tab1}" |cut -d "|" -f3)
        [ -n "${val}" ] && sed -i "s/${sets[${n}]}=.*/${sets[${n}]}=\"$val\"/g" \
        "${DC_tlp}/podcasts.cfg"
        if [ "$val" = TRUE ]; then
        count=$((count+$(egrep -cv '#|^$' <<<"${!in[${n}]}"))); fi
        
        elif [ ${n} -lt 10 ]; then
        val="$(cut -d "|" -f${f} <<<"${tab2}")"
        [ -n "${val}" ] && sed -i "s/${sets[${n}]}=.*/${sets[${n}]}=\"$val\"/g" \
        "${DC_tlt}/10.cfg"; let f++
            
        elif [ ${n} = 10 ]; then
        pval="$(cut -d "|" -f5 <<<"${tab2}")"
        if [[ "$pval" = "$(gettext "Words")" ]]; then  val=1
        elif [[ "$pval" = "$(gettext "Sentences")" ]]; then  val=2
        else  val=0; fi
        [ -n "${val}" ] && sed -i "s/${sets[${n}]}=.*/${sets[${n}]}=\"$val\"/g" \
        "${DC_tlt}/10.cfg"
         
        elif [ ${n} = 11 ]; then
        val="$(cut -d "|" -f7 <<<"${tab2}")"
        [ -n "${val}" ] && sed -i "s/${sets[${n}]}=.*/${sets[${n}]}=\"$val\"/g" \
        "${DC_tlp}/podcasts.cfg"
        fi
        
        ((n=n+1))
        done

        if [ $ret -eq 0 ]; then
        
            if [ ${count} -lt 1 ]; then
            notify-send "$(gettext "Nothing to play")" \
            "$(gettext "Exiting...")" -i idiomind -t 3000 &
            "$DS/stop.sh" 2 & exit 1; fi

            "$DS/stop.sh" 2 &
            if [ -d "${DM_tlt}" ] && [ -n "${tpc}" ]; then
            if grep TRUE <<<"$words$sntcs$marks$wprct"; then
            echo -e "$tpc" > "$DT/.p_"; else > "$DT/.p_"; fi
            else "$DS/stop.sh" 2 && exit 1; fi
            
            echo -e "ply.${tpc}.ply" >> "$DC_s/log" &
            sleep 1; "$DS/bcle.sh" &

        elif [ $ret -eq 2 ]; then

            [ -f "$DT/.p_" ] && rm -f "$DT/.p_"
            [ -f "$DT/index.m3u" ] && rm -f "$DT/index.m3u"
            "$DS/stop.sh" 2 &
        fi

    rm -f "$DT"/*.p
    exit 0
}

case "$1" in
    play_word)
    play_word "$@" ;;
    play_sentence)
    play_sentence "$@" ;;
    play_file)
    play_file "$@" ;;
    play_list)
    play_list "$@" ;;
esac
