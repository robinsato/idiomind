#!/bin/bash

if [[ "$1" = _dlg_ ]]; then
    fname="$(basename "$0")"
    name="<b>$(cut -f 1 -d '.' <<< "$fname")</b>"
    icon=dialog-information 
    if [ -f "$DC_a/dict/msgs/$fname" ]; then
        info="\n<b>Status:</b> $(< "$DC_a/dict/msgs/$fname")"
        icon=dialog-warning
    fi
    source "$DS/ifs/cmns.sh"
    msg "$name\n<small>$(gettext "Languages"): Spanish\n$(gettext "Does not need configuration")</small>\n$info" $icon "$4" "$(gettext "Close")"
    
    
    
else
    export LINK="http://static.vocabulix.com//speech/dict/spanish/${word}.mp3"
    export ex='mp3'
fi
