#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/default/c.conf
source "$DS/ifs/cmns.sh"
source $DS/default/sets.cfg
lgt=${tlangs[$tlng]}
lgs=${slangs[$slng]}

function dwld() {
    err() {
        cleanups "$DT/download" &
        msg "$(gettext "A problem has occurred while fetching data, try again later.")\n" \
        dialog-information
    }
    sleep 0.5
    msg "$(gettext "When the download completes the files will be added to topic directory.")" \
    dialog-information "$(gettext "Downloading")"
    kill -9 $(pgrep -f "yad --form --columns=1")
    mkdir "$DT/download"
    ilnk=$(grep -o 'ilnk="[^"]*' "$DM_tl/${2}/.conf/id.cfg" |grep -o '[^"]*$')
    tlng=$(grep -o 'tlng="[^"]*' "$DM_tl/${2}/.conf/id.cfg" |grep -o '[^"]*$')
    [ -z "${ilnk}" ] &&  err

    url1="http://idiomind.sourceforge.net/dl.php/?lg=${tlng,,}&fl=${ilnk}"
    if wget -S --spider "${url1}" 2>&1 |grep 'HTTP/1.1 200 OK'; then
        URL="${url1}"
    else err & exit
    fi
    wget -q -c -T 80 -O "$DT/download/${ilnk}.tar.gz" "${URL}"
    [ $? != 0 ] && err && exit 1
    
    if [ -f "$DT/download/${ilnk}.tar.gz" ]; then
        cd "$DT/download"/
        tar -xzvf "$DT/download/${ilnk}.tar.gz"
        
        if [ -d "$DT/download/files" ]; then
            total_lbl="$(gettext "Total")"
            audio_lbl="$(gettext "Audio files")"
            image_lbl="$(gettext "Images")"
            others_lbl="$(gettext "Others")"
            tmp="$DT/download/files"
            total=$(find "${tmp}" -maxdepth 5 -type f |wc -l)
            naud=$(find "${tmp}" -maxdepth 5 -name '*.mp3' |wc -l)
            nimg=$(find "${tmp}" -maxdepth 5 -name '*.jpg' |wc -l)
            hfiles="$(cd "${tmp}"; ls -d ./.[^.]* |less |wc -l)"
            exfiles="$(find "${tmp}" -maxdepth 5 -perm -111 -type f |wc -l)"
            others=$((hfiles+exfiles))
            mv -f "${tmp}/conf/info" "${DC_tlt}/info"
            check_dir "$DM_t/$tlng/.share/images" "$DM_t/$tlng/.share/audio"
            mv -n "${tmp}/share"/*.mp3 "$DM_t/$tlng/.share/audio"/
            while read -r img; do
                if [ -e "${tmp}/images/${img,,}.jpg" ]; then
                    if [ -e "$DM_t/$tlng/.share/images/${img,,}-0.jpg" \
                    -o $(wc -w <<<"${img}") -gt 1 ]; then
                        img_path="${DM_tlt}/images/${img,,}.jpg"
                    else 
                        img_path="${DM_tls}/images/${img,,}-0.jpg"
                    fi
                    mv -f "${tmp}/images/${img,,}.jpg" "${img_path}"
                fi
            done < "${DC_tlt}/3.cfg"
            rm -fr "${tmp}/share" "${tmp}/conf" "${tmp}/images"
            mv -f "${tmp}"/*.mp3 "${DM_tlt}"/
            echo "${tpc}" >> "$DM_tl/.share/3.cfg"
            echo -e "$total_lbl $total\n$audio_lbl $naud\n$image_lbl $nimg\n$others_lbl $others" > "${DC_tlt}/download"
            "$DS/ifs/tls.sh" colorize 0
            rm -fr "$DT/download"
        else
            err & exit
        fi
    else
        err & exit
    fi
    exit
}

function upld() {
    if [ -d "$DT/upload" -o -d "$DT/download" ]; then
        [ -e "$DT/download" ] && t="$(gettext "Downloading")..." || t="$(gettext "Uploading")..."
        msg_4 "$(gettext "Wait until it finishes a previous process")\n" \
        dialog-warning OK "$(gettext "Stop")" "$t"
        ret="$?"
        if [ $ret -eq 1 ]; then
            cleanups "$DT/upload" "$DT/download"
            "$DS/stop.sh" 5
        fi
        exit 1
    fi
    
    conds_upload() {
        if [ $((cfg3+cfg4)) -lt 8 ]; then
            msg "$(gettext "Insufficient number of items to perform the action").\t\n " \
            dialog-information "$(gettext "Information")" & exit 1
        fi
        if [ -z "${autr_mod}" -o -z "${pass_mod}" ]; then
            msg "$(gettext "Sorry, Authentication failed.")\n" \
            dialog-information "$(gettext "Information")" & exit 1
        fi
        if [ -z "${ctgy}" ]; then
            msg "$(gettext "Please select a category.")\n " \
            dialog-information
            "$DS/ifs/upld.sh" upld "${tpc}" & exit 1
        fi
        [ -d "$DT" ] && cd "$DT" || exit 1
        [ -d "$DT/upload" ] && rm -fr "$DT/upload"
        
        if [ "${tpc}" != "${1}" ]; then
            msg "$(gettext "Sorry, this topic is currently not active.")\n " \
            dialog-information & exit 1
        fi
        internet
    }

    dlg_getuser() {
        yad --form --title="$(gettext "Share")" \
        --text="$text_upld" \
        --name=Idiomind --class=Idiomind \
        --always-print-result \
        --window-icon=idiomind --buttons-layout=end \
        --align=right --center --on-top \
        --width=490 --height=440 --borders=12 \
        --field=" :LBL" "" \
        --field="$(gettext "Category"):CB" "" \
        --field="$(gettext "Skill Level"):CB" "" \
        --field="\n$(gettext "Description/Notes"):TXT" "${note}" \
        --field="$(gettext "Author")" "$autr" \
        --field="\t\t$(gettext "Password")" "$pass" \
        --field="<a href='$linkac'>$(gettext "Get account to share")</a> \n":LBL \
        --button="$(gettext "Export")":2 \
        --button="$(gettext "Close")":4
    }
    
    dlg_upload() {
        yad --form --title="$(gettext "Share")" \
        --text="$text_upld" \
        --name=Idiomind --class=Idiomind \
        --always-print-result \
        --window-icon=idiomind --buttons-layout=end \
        --align=right --center --on-top \
        --width=490 --height=440 --borders=12 --field=" :LBL" "" \
        --field="$(gettext "Category"):CBE" "$_Categories" \
        --field="$(gettext "Skill Level"):CB" "$_levels" \
        --field="\n$(gettext "Description/Notes"):TXT" "${note}" \
        --field="$(gettext "Author")" "$autr" \
        --field="\t\t$(gettext "Password")" "$pass" \
        --field=" ":LBL "" \
        --button="$(gettext "Export")":2 \
        --button="$(gettext "Upload")":0 \
        --button="$(gettext "Cancel")":4
    }

    dlg_dwld_content() {
        naud="$(grep -o 'naud="[^"]*' "${DC_tlt}/id.cfg" |grep -o '[^"]*$')"
        nimg="$(grep -o 'nimg="[^"]*' "${DC_tlt}/id.cfg" |grep -o '[^"]*$')"
        fsize="$(grep -o 'nsze="[^"]*' "${DC_tlt}/id.cfg" |grep -o '[^"]*$')"
        cmd_dwl="$DS/ifs/upld.sh 'dwld' "\"${tpc}\"""
        info="<b>$(gettext "Downloadable content available")</b>"
        info2="$(gettext "Audio files:") $naud\n$(gettext "Images:") $nimg\n$(gettext "Size:") $fsize"
        yad --form --columns=1 --title="$(gettext "Share")" \
        --name=Idiomind --class=Idiomind \
        --always-print-result \
        --image="dialog-information" \
        --window-icon=idiomind --buttons-layout=end \
        --align=left --center --on-top \
        --width=480 --height=180 --borders=10 \
        --text="$info" \
        --field="$info2:lbl" " " \
        --button="$(gettext "Export")":2 \
        --button="$(gettext "Download")":"${cmd_dwl}" \
        --button="$(gettext "Cancel")":4
    } 
    
    dlg_export() {
        yad --form --title="$(gettext "Share")" \
        --separator="|" \
        --name=Idiomind --class=Idiomind \
        --window-icon=idiomind --buttons-layout=end \
        --align=left --center --on-top \
        --width=480 --height=180 --borders=10 \
        --field="<b>$(gettext "Downloaded files")</b>:lbl" " " \
        --field="$(< "${DC_tlt}/download"):lbl" " " \
        --field=" :lbl" " " \
        --button="$(gettext "Export")":2 \
        --button="$(gettext "Cancel")":4
    }
    
    sv_data() {
        if [ "${autr}" != "${autr_mod}" -o "${pass}" != "${pass_mod}" ]; then
            echo -e "autr=\"$autr_mod\"\npass=\"$pass_mod\"" > "$DC_s/3.cfg"
        fi
        if [ "${note}" != "${note_mod}"  ]; then
            echo -e "\n${note_mod}" > "${DC_tlt}/info"
        fi
    }
    
    emrk='!'
    for val in "${Categories[@]}"; do
        declare clocal="$(gettext "${val}")"
        list="${list}${emrk}${clocal}"
    done
    
    LANGUAGE_TO_LEARN="${tlng^}"
    linkc="http://idiomind.net/${tlng,,}"
    linkac='http://idiomind.net/community/?q=user/register'
    ctgy="$(grep -o 'ctgy="[^"]*' "${DC_tlt}/id.cfg" |grep -o '[^"]*$')"
    text_upld="<span font_desc='Arial 12'>$(gettext "Share online with other ${LANGUAGE_TO_LEARN} learners!")</span>\n<a href='$linkc'>$(gettext "Topics shared")</a> Beta\n"
    _Categories="${ctgy}${list}"
    _levels="!$(gettext "Beginner")!$(gettext "Intermediate")!$(gettext "Advanced")"
    note=$(< "${DC_tlt}/info")
    autr="$(grep -o 'autr="[^"]*' "$DC_s/3.cfg" |grep -o '[^"]*$')"
    pass="$(grep -o 'pass="[^"]*' "$DC_s/3.cfg" |grep -o '[^"]*$')"

    # dialogs
    if [[ -e "${DC_tlt}/download" ]]; then
        if [[ ! -s "${DC_tlt}/download" ]]; then
            dlg="$(dlg_dwld_content)"
            ret=$?
        else
            dlg="$(dlg_export)"
            ret=$?
        fi
    else
        shopt -s extglob
        if [ -z "${autr##+([[:space:]])}" -o -z "${pass##+([[:space:]])}" ]; then
            dlg="$(dlg_getuser)"
            ret=$?
        elif [ -n "${autr}" -o -n "${pass}" ]; then
            dlg="$(dlg_upload)"
            ret=$?
            
        fi
        dlg="$(grep -oP '(?<=|).*(?=\|)' <<<"$dlg")"
        ctgy=$(echo "${dlg}" |cut -d "|" -f2)
        levl=$(echo "${dlg}" |cut -d "|" -f3)
        note_mod=$(echo "${dlg}" |cut -d "|" -f4)
        autr_mod=$(echo "${dlg}" |cut -d "|" -f5)
        pass_mod=$(echo "${dlg}" |cut -d "|" -f6)
        # get data
        for val in "${Categories[@],}"; do
            [ "${ctgy^}" = "$(gettext "${val^}")" ] && export ctgy="${val// /_}"
        done
        [ "$levl" = $(gettext "Beginner") ] && levl=0
        [ "$levl" = $(gettext "Intermediate") ] && levl=1
        [ "$levl" = $(gettext "Advanced") ] && levl=2
    fi
    
    if [ $ret = 1 -o $ret = 4 ]; then
        sv_data
    elif [ $ret = 2 ]; then
        sv_data
        if [ -d "$DT/export" ]; then
            msg_4 "$(gettext "Wait until it finishes a previous process").\n" \
            dialog-information OK "$(gettext "Stop")" "$(gettext "Information")"
            ret=$?
            if [ $ret -eq 1 ]; then
                [ -d "$DT/export" ] && rm -fr "$DT/export"
            fi
            exit 1
        else
            "$DS/ifs/upld.sh" _export "${tpc}" & exit 1
        fi
    elif [ $ret = 0 ]; then
        sv_data
        conds_upload "${2}"
        "$DS/ifs/tls.sh" check_index "${tpc}" 1
        ( sleep 1; notify-send -i dialog-information "$(gettext "Upload in progress")" \
        "$(gettext "This can take a while...")" -t 6000 ) &
        mkdir -p "$DT/upload/files/conf"
        DT_u="$DT/upload/"
        orig="$(grep -o 'orig="[^"]*' "${DC_tlt}/id.cfg" |grep -o '[^"]*$')"
        [ -z "${orig}" ] && orig="${tpc}"
        pre=$(sed "s/ /_/g;s/'//g" <<< "${orig:0:15}" |iconv -c -f utf8 -t ascii)
        export autr="${autr_mod}"
        export pass="${pass_mod}"
        export md5i=$(md5sum "${DC_tlt}/0.cfg" |cut -d' ' -f1)
        export ilnk="${pre,,}${md5i:0:20}"
        export dtec="$(grep -o 'dtec="[^"]*' "${DC_tlt}/id.cfg" |grep -o '[^"]*$')"
        export dtei="$(grep -o 'dtei="[^"]*' "${DC_tlt}/id.cfg" |grep -o '[^"]*$')"
        export dteu=$(date +%F)
        tpcid=$(strings /dev/urandom |tr -cd '[:alnum:]' |fold -w 3 |head -n 1)
        export nwrd=${cfg3}
        export nsnt=${cfg4}
        export orig levl
        
        # copying files
        cd "${DM_tlt}"/
        cp -r ./* "$DT_u/files/"
        mkdir "$DT_u/files/share"
        [ ! -d "$DT_u/files/images" ] && mkdir "$DT_u/files/images"

        auds="$(uniq < "${DC_tlt}/4.cfg" \
        | sed 's/\n/ /g' | sed 's/ /\n/g' \
        | grep -v '^.$' | grep -v '^..$' \
        | sed 's/&//; s/,//; s/\?//; s/\¿//; s/;//'g \
        |  sed 's/\!//; s/\¡//; s/\]//; s/\[//; s/\.//; s/  / /'g \
        | tr -d ')' | tr -d '(' | tr '[:upper:]' '[:lower:]')"
        while read -r audio; do
            if [ -f "$DM_tl/.share/audio/$audio.mp3" ]; then
                cp -f "$DM_tl/.share/audio/$audio.mp3" \
                "$DT_u/files/share/$audio.mp3"
            fi
        done <<<"$auds"
        while read -r audio; do
            if [ -f "$DM_tl/.share/audio/${audio,,}.mp3" ]; then
                cp -f "$DM_tl/.share/audio/${audio,,}.mp3" \
                "$DT_u/files/share/${audio,,}.mp3"
            fi
        done < "${DC_tlt}/3.cfg"
        while read -r img; do
            if [ -e "$DM_tlt/images/${img,,}.jpg" ]; then
                img_path="$DM_tlt/images/${img,,}.jpg"
            elif [ -e "$DM_tls/images/${img,,}-0.jpg" ]; then
                img_path="$DM_tls/images/${img,,}-0.jpg"
            fi
            if [ -e "${img_path}" ]; then
                cp -f "${img_path}" "$DT_u/files/images/${img,,}.jpg"
            fi
        done < "${DC_tlt}/3.cfg"
        export naud=$(find "$DT_u/files" -maxdepth 5 -name '*.mp3' |wc -l)
        export nimg=$(cd "$DT_u/files/images"/; ls *.jpg |wc -l)
        cp "${DC_tlt}/6.cfg" "$DT_u/files/conf/6.cfg"
        cp "${DC_tlt}/info" "$DT_u/files/conf/info"

        # create tar
        cd "$DT/upload"/
        find "$DT_u"/ -type f -exec chmod 644 {} \;
        tar czpvf - ./"files" |split -d -b 2500k - ./"${ilnk}"
        rm -fr ./"files"; rename 's/(.*)/$1.tar.gz/' *
        
        # create id
        export nsze=$(du -h . |cut -f1)
        eval c="$(sed -n 4p "$DS/default/vars")"
        echo -e "${c}" > "${DC_tlt}/id.cfg"
        direc="$DT_u"
        eval body="$(sed -n 5p "$DS/default/vars")"
        export tpc direc body
        echo -e "{\"items\":{" > "$DT_u/$tpcid.$orig.$lgt"
        while read -r _item; do
            get_item "${_item}"
            eval itm="$(sed -n 1p "$DS/default/vars")"
            [ -n "${trgt}" ] && echo -en "${itm}" >> "$DT_u/$tpcid.$orig.$lgt"
        done < <(sed 's|"|\\"|g' < "${DC_tlt}/0.cfg")
        sed -i 's/,$//' "$DT_u/$tpcid.$orig.$lgt"
        echo "}," >> "$DT_u/$tpcid.$orig.$lgt"
        eval head="$(sed -n 3p "$DS/default/vars")"
        echo -e "${head}}" >> "$DT_u/$tpcid.$orig.$lgt"

        python << END
import os, sys, requests, time, xmlrpclib
reload(sys)
sys.setdefaultencoding("utf-8")
autr = os.environ['autr']
pssw = os.environ['pass']
tpc = os.environ['tpc']
body = os.environ['body']
try:
    server = xmlrpclib.Server('http://idiomind.net/community/xmlrpc.php')
    nid = server.metaWeblog.newPost('blog', autr, pssw, 
    {'title': tpc, 'description': body}, True)
except:
    sys.exit(3)
url = requests.get('http://idiomind.sourceforge.net/uploads.php').url
direc = os.environ['direc']
volumes = [i for i in os.listdir(direc)]
for f in volumes:
    file = {'file': open(f, 'rb')}
    r = requests.post(url, files=file)
    time.sleep(5)
END
        u=$?
        if [ $u = 0 ]; then
            info="\"$tpc\"\n<b>$(gettext "Uploaded correctly")</b>\n"
            image='dialog-ok-apply'
        elif [ $u = 3 ]; then
            info="$(gettext "Authentication error.")\n"
            image='error'
        else
            sleep 5
            info="$(gettext "A problem has occurred with the file upload, try again later.")\n"
            image='error'
        fi
        msg "$info" $image

        cleanups "${DT_u}"
        exit 0
    fi
    
} >/dev/null 2>&1

fdlg() {
    tpcs="$(cd "$DS/ifs/mods/export"; ls \
    |sed 's/\.sh//g'|tr "\\n" '!' |sed 's/\!*$//g')"
    key=$((RANDOM%100000)); cd "$HOME"
    yad --file --save --filename="$HOME/$tpc" --tabnum=1 --plug="$key" &
    yad --form --tabnum=2 --plug="$key" \
    --separator="" --align=right \
    --field="\t\t\t\t$(gettext "Export to"):CB" "$tpcs" &
    yad --paned --key="$key" --title="$(gettext "Export")" \
    --name=Idiomind --class=Idiomind \
    --window-icon=idiomind --center --on-top \
    --width=600 --height=500 --borders=8 --splitter=370 \
    --button="$(gettext "Cancel")":1 \
    --button="$(gettext "Save")":0
}

_export() {
    dlg="$(fdlg)"
    ret=$?
    if [ $ret -eq 0 ]; then
        "$DS/ifs/mods/export/$(head -n 1 <<<"$dlg").sh" \
        "$(tail -n 1 <<<"$dlg")" "${tpc}" & exit 0
    fi
} >/dev/null 2>&1

case "$1" in
    vsd)
    vsd "$@" ;;
    infsd)
    infsd "$@" ;;
    dwld)
    dwld "$@" ;;
    upld)
    upld "$@" ;;
    _export)
    _export "$@" ;;
    share)
    download "$@" ;;
esac
