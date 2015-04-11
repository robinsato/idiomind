#!/bin/bash
# -*- ENCODING: UTF-8 -*-

#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.
#
source /usr/share/idiomind/ifs/c.conf
source "$DS/ifs/mods/cmns.sh"
include "$DS/ifs/mods/add"
DSP="$DS/addons/Feeds"
DMC="$DM_tl/Feeds/cache"
DCP="$DM_tl/Feeds/.conf"
DT_r=$(mktemp -d $DT/XXXX)
downloads=5

tmplitem="<?xml version='1.0' encoding='UTF-8'?>
<xsl:stylesheet version='1.0'
xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
xmlns:itunes='http://www.itunes.com/dtds/podcast-1.0.dtd'
xmlns:media='http://search.yahoo.com/mrss/'
xmlns:atom='http://www.w3.org/2005/Atom'>
<xsl:output method='text'/>
<xsl:template match='/'>
<xsl:for-each select='/rss/channel/item'>
<xsl:value-of select='enclosure/@url'/><xsl:text>-!-</xsl:text>
<xsl:value-of select='media:cache[@type=\"audio/mpeg\"]/@url'/><xsl:text>-!-</xsl:text>
<xsl:value-of select='title'/><xsl:text>-!-</xsl:text>
<xsl:value-of select='media:cache[@type=\"audio/mpeg\"]/@duration'/><xsl:text>-!-</xsl:text>
<xsl:value-of select='itunes:summary'/><xsl:text>-!-</xsl:text>
<xsl:value-of select='description'/><xsl:text>EOL</xsl:text>
</xsl:for-each>
</xsl:template>
</xsl:stylesheet>"

tmplitem2="<?xml version='1.0' encoding='UTF-8'?>
<xsl:stylesheet version='1.0'
xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
xmlns:itunes='http://www.itunes.com/dtds/feed-1.0.dtd'
xmlns:media='http://search.yahoo.com/mrss/'
xmlns:atom='http://www.w3.org/2005/Atom'>
<xsl:output method='text'/>
<xsl:template match='/'>
<xsl:for-each select='/rss/channel/item'>
<xsl:value-of select='enclosure/@url'/><xsl:text>-!-</xsl:text>
<xsl:value-of select='media:cache[@type=\"image/jpeg\"]/@url'/><xsl:text>-!-</xsl:text>
<xsl:value-of select='title'/><xsl:text>-!-</xsl:text>
<xsl:value-of select='media:cache[@type=\"image/jpeg\"]/@duration'/><xsl:text>-!-</xsl:text>
<xsl:value-of select='itunes:summary'/><xsl:text>-!-</xsl:text>
<xsl:value-of select='description'/><xsl:text>EOL</xsl:text>
</xsl:for-each>
</xsl:template>
</xsl:stylesheet>"

tpc_sh='#!/bin/bash
source /usr/share/idiomind/ifs/c.conf
[ ! -f "$DM_tl/Feeds/.conf/8.cfg" ] \
&& echo "11" > "$DM_tl/Feeds/.conf/8.cfg"
echo "$tpc" > "$DC_s/4.cfg"
echo fd >> "$DC_s/4.cfg"
idiomind topic
exit 1'

sets=('channel' 'link' 'logo' 'ntype' \
'nmedia' 'ntitle' 'nsumm' 'nimage' 'url')
d=0

conditions() {
    
    [ ! -f "$DCP/1.cfg" ] && touch "$DCP/1.cfg"
    
    if [ -f "$DT/.uptp" ] && [ -z "$1" ]; then
        msg_2 "$(gettext "Wait till it finishes a previous process")\n" info OK gtk-stop
        ret=$(echo $?)
        [ $ret -eq 1 ] && "$DS/stop.sh" feed
        [ $ret -eq 0 ] && exit 1
    
    elif [[ -f "$DT/.uptp" && "$1" = A ]]; then
        exit 1
    fi
    
    if [ ! -d "$DM_tl/Feeds/cache" ]; then
        mkdir -p "DM_tl/Feeds/.conf"
        mkdir -p "DM_tl/Feeds/cache"
    fi
    
    if [ ! -f "$DM_tl/Feeds/tpc.sh" ] || \
    [ "$(wc -l < "$DM_tl/Feeds/tpc.sh")" -gt 8 ]; then
        echo "$tpc_sh" > "$DM_tl/Feeds/tpc.sh"
        chmod +x "$DM_tl/Feeds/tpc.sh"
        echo "14" > "$DM_tl/Feeds/.conf/8.cfg"
        cd "$DM_tl/Feeds/.conf/"
        touch 0.cfg 1.cfg 3.cfg 4.cfg .updt.lst
        "$DS/mngr.sh" mkmn
    fi

    nps="$(sed '/^$/d' < "$DCP/4.cfg" | wc -l)"
    if [ "$nps" -le 0 ]; then
    [ "$1" != A ] && msg "$(gettext "Missing URL. Please check the settings in the preferences dialog.")\n" info
    [ -f "$DT_r" ] && rm -fr "$DT_r" "$DT/.uptp" && exit 1; fi
        
    [ "$1" != A ] && internet || curl -v www.google.com 2>&1 \
    | grep -m1 "HTTP/1.1" >/dev/null 2>&1 || exit 1
}

mediatype () {

    if echo "${1}" | grep -q ".mp3"; then ex=mp3; tp=aud
    elif echo "${1}" | grep -q ".mp4"; then ex=mp4; tp=vid
    elif echo "${1}" | grep -q ".ogg"; then ex=ogg; tp=aud
    elif echo "${1}" | grep -q ".avi"; then ex=avi; tp=vid
    elif echo "${1}" | grep -q ".m4v"; then ex=m4v; tp=vid
    elif echo "${1}" | grep -q ".mov"; then ex=mov; tp=vid
    elif echo "${1}" | grep -o ".jpg"; then ex=jpg; tp=txt
    elif echo "${1}" | grep -o ".jpeg"; then ex=jpeg; tp=txt
    elif echo "${1}" | grep -o ".png"; then ex=png; tp=txt
    elif echo "${1}" | grep -o ".pdf"; then ex=pdf; tp=txt
    elif [ -n "${1}" ]; then ex=pdf; tp=others
    else 
        if [ "$ntype" =1 ]; then
            printf "err.FE2($n).err\n" >> "$DC_s/8.cfg"
            echo "Could not add some podcasts.\n$FEED" >> "$DM_tl/Feeds/.conf/feed.err"
            continue; fi
    fi
}


mkhtml() {

video="<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" />
<link rel=\"stylesheet\" href=\"/usr/share/idiomind/default/vwr.css\">
<video width=640 height=380 controls>
<source src=\"$fname.$ex\" type=\"video/mp4\">
Your browser does not support the video tag.</video><br><br>
<div class=\"title\"><h3>$title</h3></div><br>
<div class=\"summary\">$summary<br><br></div>"

audio="<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" />
<link rel=\"stylesheet\" href=\"/usr/share/idiomind/default/vwr.css\">
<br><div class=\"title\"><h2>$title</h2></div><br>
<div class=\"summary\"><audio controls><br>
<source src=\"$fname.$ex\" type=\"audio/mpeg\">
Your browser does not support the audio tag.</audio><br><br>
$summary<br><br></div>"

text="<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" />
<link rel=\"stylesheet\" href=\"/usr/share/idiomind/default/vwr.css\">
<body><br><div class=\"title\"><h2>$title</h2></div><br>
<div class=\"summary\"><div class=\"image\">
<img src=\"$fname.jpg\" alt=\"Image\" style=\"width:650px\"></div><br>
$summary<br><br></div>
</body>"

    if [ "$tp" = vid ]; then
        if [ $ex = m4v || $ex = mp4 ]; then
        t = mp4
        elif [ $ex = avi ]; then
        t = avi; fi
        echo -e "$video" > "$DMC/$fname.html"

    elif [ "$tp" = aud ]; then
        echo -e "$audio" > "$DMC/$fname.html"

    elif [ "$tp" = txt ]; then
        echo -e "text" > "$DMC/$fname.html"
    fi
}


get_media() {
    
    cd "$DT_r"
    
    #if [ "$ntype" = 1 ]; then
    
        #enclosure_url=$(curl -s -I -L -w %"{url_effective}" \
        #--url "$enclosure" | tail -n 1)
                        
        #mediatype "$enclosure_url"
                            
        #if [ ! -f "$DMC/$fname.$ex" ]; then
            #cd "$DT_r"; wget -q -c -T 30 -O "media.$ex" "$enclosure_url"
        #else
            #cd "$DT_r"; mv -f "$DMC/$fname.$ex" "media.$ex"
        #fi
        
        #mv -f "media.$ex" "$DMC/$fname.$ex"
        
        
        
    #elif [ "$ntype" = 2 ]; then
    
        #p=TRUE
        #if [ -n "$enclosure" ]; then
            #url=$(curl -s -I -L -w %"{url_effective}" \
            #--url "$enclosure" | tail -n 1)
        #else
            #imgemb=`sed -n 1p <<<"$sumlink" | grep -o 'img src="[^"]*' | grep -o '[^"]*$'`
            
            #url=$(curl -s -I -L -w %"{url_effective}" \
            #--url "$imgemb" | tail -n 1)
        #fi 
            
        #mediatype "$url"
        
        #wget -q -c -T 30 -O "media.$ex" "$url"
        
        ##echo "$sumlink" >> /home/robin/Desktop/ff
        
        
        #if [ "media.$ex" ]; then
            #/usr/bin/convert "media.$ex" "$DMC/$fname.jpg"
        #else
            #url="$(sed -n 1p <<<"$summary" | grep -o 'img src="[^"]*' | grep -o '[^"]*$')"
            #url=$(curl -s -I -L -w %"{url_effective}" --url "$url" | tail -n 1)
            #mediatype "$url"
            ##echo "media.$ex  $url" >> /home/robin/Desktop/ff
            #wget -q -c -T 30 -O "media.$ex" "$url"
            ##echo "media.$ex  $url" >> /home/robin/Desktop/ff
        #fi
        
        
        #if [ "media.$ex" ]; then
            #/usr/bin/convert "media.$ex" "$DMC/$fname.jpg"
        #else
            #cp /usr/share/idiomind/addons/Feeds/images/audio.png "$DMC/$fname.jpg"
            #p=""
        #fi
        p="TRUE"
        cp /usr/share/idiomind/addons/Feeds/images/audio.png "$DT_r/$img"
        
    #fi
}


get_thumbls () {

    # ------------------------------------------------------------------

        if [ "$tp" = aud ]; then
            
            cd "$DT_r"; p=TRUE; rm -f *.jpeg *.jpg
            
            eyeD3 --write-images="$DT_r" "media.$ex"
            
            if ls | grep '.jpeg'; then img="$(ls | grep '.jpeg')"
            else img="$(ls | grep '.jpg')"; fi
            
            if [ ! -f "$DT_r/$img" ]; then
            
                wget -q -O- "$FEED" | grep -o '<itunes:image href="[^"]*' \
                | grep -o '[^"]*$' | xargs wget -c
                
                if ls | grep '.jpeg'; then img="$(ls | grep '.jpeg')"
                elif ls | grep '.png'; then img="$(ls | grep '.png')"
                else img="$(ls | grep '.jpg')"; fi
            fi
            
            if [ ! -f "$DT_r/$img" ]; then
            cp -f "$DSP/images/audio.png" "$DMC/$fname.png"
            p=""; fi

        elif [ "$tp" = vid ]; then
            
            cd "$DT_r"; p=TRUE; rm -f *.jpeg *.jpg
            mplayer -ss 60 -nosound -noconsolecontrols \
            -vo jpeg -frames 3 "media.$ex" >/dev/null

            if ls | grep '.jpeg'; then img="$(ls | grep '.jpeg' | head -n1)"
            else img="$(ls | grep '.jpg' | head -n1)"; fi
            
            if [ ! -f "$DT_r/$img" ]; then
            cp -f "$DSP/images/video.png" "$DMC/$fname.png"
            p=""; fi
            
        elif [ "$tp" = txt ]; then
        
            cd "$DT_r"; p=""
        
            img="media.$ex"
        fi
        
    if [ "$p" = TRUE ] && [ -f "$DT_r/$img" ]; then
        
        convert "$DT_r/$img" -interlace Plane -thumbnail 62x54^ \
        -gravity center -extent 62x54 -quality 100% tmp.jpg
        convert tmp.jpg -bordercolor white \
        -border 2 \( +clone -background black \
        -shadow 70x3+2+2 \) +swap -background transparent \
        -layers merge +repage "$DMC/$fname.png"
        rm -f *.jpeg *.jpg
    fi
    
}
        

fetch_podcasts() {

    n=1
    while read FEED; do
        
        if [ ! -z "$FEED" ]; then

            if [ "$DCP/$n.rss" ]; then
                d=0
                while [[ $d -lt 8 ]]; do
                
                    get="${sets[$d]}"
                    val=$(sed -n $((d+1))p < "$DCP/$n.rss" \
                    | grep -o "$get"=\"[^\"]* | grep -o '[^"]*$')
                    declare "${sets[$d]}"="$val"
                    ((d=d+1))
                done
              
            else
                continue
            fi

            if [ "$ntype" = 1 ]; then

                podcast_items="$(xsltproc - "$FEED" <<< "$tmplitem" 2> /dev/null)"
                podcast_items="$(echo "$podcast_items" | tr '\n' ' ' \
                | tr -s '[:space:]' | sed 's/EOL/\n/g' | head -n "$downloads")"
                podcast_items="$(echo "$podcast_items" | sed '/^$/d')"
                
                while read -r item; do

                    fields="$(sed -r 's|-\!-|\n|g' <<<"$item")"
                    enclosure=$(sed -n "$nmedia"p <<<"$fields")
                    
                    if [ -z "$enclosure" ]; then
                    #echo "Missing enclosure.\n$FEED\n$enclosure" >> "$DM_tl/Feeds/.conf/feed.err" # FIX
                    continue; fi
                    
                    title=$(echo "$fields" | sed -n "$ntitle"p | sed 's/\://g' \
                    | sed 's/\&/&amp;/g' | sed 's/^\s*./\U&\E/g' \
                    | sed 's/<[^>]*>//g' | sed 's/^ *//; s/ *$//; /^$/d')
                    summary=$(echo "$fields" | sed -n "$nsumm"p \
                    | iconv -c -f utf8 -t ascii)
                    fname="$(nmfile "${title}")"
                    
                    if [ "$(echo "$title" | wc -c)" -ge 180 ] || [ -z "$title" ]; then
                    echo "Missing title.\n$FEED" >> "$DM_tl/Feeds/.conf/feed.err"
                    printf "err.FE4($n).err\n" >> "$DC_s/8.cfg"
                    continue; fi
                         
                    if ! grep -Fxo "$title" < "$DCP/1.cfg"; then
                    
                        get_media
                        get_thumbls
                        mkhtml

                        if [ -s "$DCP/1.cfg" ]; then
                        sed -i -e "1i$title\\" "$DCP/1.cfg"
                        else echo "$title" > "$DCP/1.cfg"; fi
                        if grep '^$' "$DCP/1.cfg"; then
                        sed -i '/^$/d' "$DCP/1.cfg"; fi
                        echo "$title" >> "$DCP/.11.cfg"
                        echo "$title" >> "$DT_r/log"
                    fi

                done <<<"$podcast_items"
                
            elif [ "$ntype" = 2 ]; then
            
                    feed_items="$(xsltproc - "$FEED" <<< "$tmplitem2" 2> /dev/null)"
                    feed_items="$(echo "$feed_items" | tr '\n' ' ' \
                    | tr -s '[:space:]' | sed 's/EOL/\n/g' | head -n "$downloads")"
                    feed_items="$(echo "$feed_items" | sed '/^$/d')"
                    
                     
                    
                    while read -r item; do

                        fields="$(echo "$item" | sed -r 's|-\!-|\n|g')"
                        
                        enclosure=$(echo "$fields" | sed -n "$nimage"p)
                        title=$(echo "$fields" | sed -n "$ntitle"p \
                        | iconv -c -f utf8 -t ascii | sed 's/\://g' \
                        | sed 's/\&/&amp;/g' | sed 's/^\s*./\U&\E/g' \
                        | sed 's/<[^>]*>//g' | sed 's/^ *//; s/ *$//; /^$/d')
                        sumlink=$(echo "$fields" | sed -n "$n_sum"p | sed '/^$/d')
                        summary=$(echo "$fields" | sed -n "$nsumm"p)
                        [ -z "$summary" ] && summary=$(echo "$fields" | sed -n $((nsumm+1))p)
                        summary=$(echo "$summary" \
                        | iconv -c -f utf8 -t ascii \
                        | sed 's/\&quot;/\"/g' | sed "s/\&#039;/\'/g" \
                        | sed '/</ {:k s/<[^>]*>//g; /</ {N; bk}}' \
                        | sed 's/<!\[CDATA\[\|\]\]>//g' \
                        | sed 's/ *<[^>]\+> */ /g' \
                        | sed 's/[<>£§]//g' | sed 's/&amp;/\&/g' \
                        | sed 's/\(\. [A-Z][^ ]\)/\.\n\1/g' | sed 's/\. //g' \
                        | sed 's/\(\? [A-Z][^ ]\)/\?\n\1/g' | sed 's/\? //g' \
                        | sed 's/\(\! [A-Z][^ ]\)/\!\n\1/g' | sed 's/\! //g' \
                        | sed 's/\(\… [A-Z][^ ]\)/\…\n\1/g' | sed 's/\… //g')
                        fname="$(nmfile "${title}")"

                        #if [ "$(echo "$title" | wc -c)" -ge 200 ]; then
                        #echo "Title too long.\n$FEED" >> "$DM_tl/Feeds/.conf/feed.err"
                        #printf "err.FE5($n).err\n" >> "$DC_s/8.cfg";
                        #continue; fi
                        if ! grep -Fxo "$title" < "$DCP/1.cfg"; then
                        
                            get_media
                            get_thumbls
                            mkhtml

                            if [ -s "$DCP/1.cfg" ]; then
                            sed -i -e "1i$title\\" "$DCP/1.cfg"
                            else echo "$title" > "$DCP/1.cfg"; fi
                            if grep '^$' "$DCP/1.cfg"; then
                            sed -i '/^$/d' "$DCP/1.cfg"; fi
                            echo "$title" >> "$DCP/.11.cfg"
                            echo "$title" >> "$DT_r/log"
                        fi

                    done <<< "$feed_items"
            fi
            
        else
            [ -f "$DCP/$n.rss" ] && rm "$DCP/$n.rss"
        fi
        
        let n++

    done < "$DCP/4.cfg"
}

remove_items() {
    
    n=50
    while [[ $n -le "$(wc -l < "$DCP/1.cfg")" ]]; do
        item="$(sed -n "$n"p "$DCP/1.cfg")"
        if ! grep -Fxo "$item" < "$DCP/2.cfg"; then
            fname="$(nmfile "${item}")"
            [ -f "$DMC/$fname".* ] && rm "$DMC/$fname".*
        fi
        grep -vxF "$item" "$DCP/1.cfg" > "$DT/item.tmp"
        sed '/^$/d' "$DT/item.tmp" > "$DCP/1.cfg"
        let n++
    done
}

check_index() {
    
    check_index1 "$DCP/1.cfg"
    if grep '^$' "$DCP/1.cfg"; then
    sed -i '/^$/d' "$DCP/1.cfg"; fi
    cp -f "$DCP/1.cfg" "$DCP/.11.cfg"
    
    df_img="$DSP/images/item.png"
    while read item; do
        fname="$(nmfile "${item}")"
        if ([ -f "$DMC/$fname.mp3" ] || [ -f "$DMC/$fname.mp4" ] || \
        [ -f "$DMC/$fname.jpg" ] || \
        [ -f "$DMC/$fname.jpeg" ] || [ -f "$DMC/$fname.png" ] || \
        [ -f "$DMC/$fname.ogg" ] || [ -f "$DMC/$fname.avi" ] || \
        [ -f "$DMC/$fname.m4v" ] || [ -f "$DMC/$fname.flv" ]); then
            continue
        else
            echo "$item" >> "$DT/cchk"; fi
        if [ ! -f "$DMC/$fname.png" ]; then
            cp "$df_img" "$DMC/$fname.png"
        fi
    done < "$DCP/1.cfg"
    
    if [ -f "$DT/cchk" ]; then
        while read item; do
            fname="$(nmfile "${item}")"
            grep -vxF "$item" "$DCP/.11.cfg" > "$DCP/.11.cfg.tmp"
            sed '/^$/d' "$DCP/.11.cfg.tmp" > "$DCP/.11.cfg"
            grep -vxF "$item" "$DCP/1.cfg" > "$DCP/1.cfg.tmp"
            sed '/^$/d' "$DCP/1.cfg.tmp" > "$DCP/1.cfg"
            [ -f "$DMC/$fname.png" ] && rm "$DMC/$fname.png"
        done < "$DT/cchk"
        [ -f "$DCP/*.tmp" ] && rm "$DCP/*.tmp"
    fi
}

conditions "$1"

if [ "$1" != A ]; then
    echo "$tpc" > "$DC_s/4.cfg"
    echo fd >> "$DC_s/4.cfg"
    echo "11" > "$DCP/8.cfg"
    (sleep 2 && notify-send -i idiomind "$(gettext "Checking for new episodes")" \
    "$(gettext "Updating") $nps $(gettext "feeds...")" -t 6000) &
fi

echo "updating" > "$DT/.uptp"

fetch_podcasts

[ -f "$DT_r/log" ] && nd="$(wc -l < "$DT_r/log")" || nd=0
rm -fr "$DT/.uptp"
echo "$(date "+%a %d %B")" > "$DM_tl/Feeds/.dt"

if [ "$nd" -gt 0 ]; then

    #remove_items
    
    #check_index
    
    [ "$1" != A ] && notify-send -i idiomind \
    "$(gettext "Feed update")" \
    "$(gettext "Has") $nd $(gettext "Update(s)")" -t 8000
    
else
    if [[ ! -n "$1" && "$1" != A ]]; then
    notify-send -i idiomind "$(gettext "Feed update")" \
    "$(gettext "No change since the last update")" -t 8000
    fi
fi

cfg="$DM_tl/Feeds/.conf/0.cfg"; if [ -f "$cfg" ]; then
sync="$(sed -n 2p < "$cfg" | grep -o 'sync="[^"]*' | grep -o '[^"]*$')"
if [ "$sync" = TRUE ]; then "$DSP/tls.sh" sync A; fi; fi

exit
