#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
DSP="$DS/practice"

[ -n "$(ps -A | pgrep -f "$DSP/df.sh")" ] && killall "$DSP/df.sh" &
[ -n "$(ps -A | pgrep -f "$DSP/dmc.sh")" ] && killall "$DSP/dmc.sh" &
[ -n "$(ps -A | pgrep -f "$DSP/dlw.sh")" ] && killall "$DSP/dlw.sh" &
[ -n "$(ps -A | pgrep -f "$DSP/dls.sh")" ] && killall "$DSP/dls.sh" &
[ -n "$(ps -A | pgrep -f "$DSP/di.sh")" ] && killall "$DSP/di.sh" &
[ -n "$(ps -A | pgrep -f "$DSP/prct.sh")" ] && killall "$DSP/prct.sh" &
[ -n "$(ps -A | pgrep -f "$DSP/strt.sh")" ] && killall "$DSP/strt.sh" &
[ -n "$(ps -A | pgrep -f play)" ] && killall play &

cd "$DC_tlt/practice"
easy="$2"; ling="$3"; hard="$4"; all="$5"

if [ "$1" = df ]; then
    rm look_f fin fin1 fin2 fin3 ok.f
    echo "1" > .iconf
    echo "0" > l_f
    "$DSP/strt.sh" &
    exit 1
elif [ "$1" = dm ]; then
    rm look_mc mcin1 mcin2 mcin3 word1.idx ok.m
    echo "1" > .iconmc
    echo "0" > l_m
    "$DSP/strt.sh" &
    exit 1
elif [ "$1" = dw ]; then
    rm look_lw lwin lwin1 lwin2 lwin3 ok.w
    echo "1" > .iconlw
    echo "0" > l_w
    "$DSP/strt.sh" &
    exit 1
elif [ "$1" = ds ]; then
    rm look_ls lsin ok.s
    echo "1" > .iconls
    echo "0" > l_s
    "$DSP/strt.sh" &
    exit 1
elif [ "$1" = di ]; then
    rm look_i lsin ok.i
    echo "1" > .iconi
    echo "0" > l_i
    "$DSP/strt.sh" &
    exit 1
fi

stats() {
    
    n=1; c=1
    while [ "$n" -le 21 ]; do
        if [[ $v -le $c ]]; then
        echo "$n" > "$1"; break; fi
        ((c=c+5))
        let n++
    done
}

if [ "$1" = f ]; then

    cd "$DC_tlt/practice"
    [ -f l_f ] && echo $(($(cat l_f)+easy)) > l_f || echo "$easy" > l_f
    s=$(cat l_f)
    v=$((100*s/$all))
    stats .iconf
    "$DSP/strt.sh" 6 "$easy" "$ling" "$hard" & exit 1

elif [ "$1" = m ]; then

    cd "$DC_tlt/practice"
    [ -f l_m ] && echo $(($(cat l_m)+easy)) > l_m || echo "$easy" > l_m
    s=$(cat l_m)
    v=$((100*s/$all))
    stats .iconmc
    "$DSP/strt.sh" 7 "$easy" "$ling" "$hard" & exit 1

elif [ "$1" = w ]; then

    cd "$DC_tlt/practice"
    [ -f l_w ] && echo $(($(cat l_w)+easy)) > l_w || echo "$easy" > l_w
    s=$(cat l_w)
    v=$((100*s/$all))
    stats .iconlw
    "$DSP/strt.sh" 8 "$easy" "$ling" "$hard" & exit 1

elif [ "$1" = s ]; then

    cd "$DC_tlt/practice"
    [ -f l_s ] && echo $(($(cat l_s)+easy)) > l_s || echo "$easy" > l_s
    s=$(cat l_s)
    v=$((100*s/$all))
    stats .iconls
    "$DSP/strt.sh" 9 "$easy" "$ling" "$hard" & exit 1
    
elif [ "$1" = i ]; then

    cd "$DC_tlt/practice"
    [ -f l_i ] && echo $(($(cat l_i)+easy)) > l_i || echo "$easy" > l_i
    s=$(cat l_i)
    v=$((100*s/$all))
    stats .iconi
    "$DSP/strt.sh" 10 "$easy" "$ling" "$hard" & exit 1
fi