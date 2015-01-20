#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
source $DS/ifs/trans/$lgs/rss.conf

itdl="$2"
kpt="$DM_tl/Feeds/kept"
drtc="$DC_tl/Feeds/"

if [[ $1 = dlti ]]; then
	if [ -f "$kpt/words/$itdl.mp3" ]; then
		$yad --title="$confirm" --width=400 \
		--height=140 --on-top --center \
		--image=dialog-question --skip-taskbar \
		--text="$delete_word" \
		--window-icon=idiomind --borders=5 \
		--button=gtk-delete:2 --button="$cancel":0
		ret=$?
			if [[ $ret -eq 2 ]]; then
				rm "$kpt/words/$itdl.mp3"
				cd "$drtc"
				grep -v -x -v "$itdl" ./.inx > ./inx
				sed '/^$/d' ./inx > ./.inx
				rm ./inx
				grep -v -x -v "$itdl" ./cnfg3 > ./cnfg3_
				sed '/^$/d' ./cnfg3_ > ./cnfg3
				rm ./cnfg3_
				grep -v -x -v "$itdl" ./cnfg0 > ./cnfg0_
				sed '/^$/d' ./cnfg0_ > ./cnfg0
				rm ./cnfg0_
				notify-send  -i idiomind "$itdl" "$deleted"  -t 1500
			fi
			if [[ $ret -eq 1 ]]; then
				exit
			fi
	
	elif [ -f "$kpt/$itdl.mp3" ]; then
		$yad --title="$confirm" --width=400 \
		--height=140 --on-top --center \
		--image=dialog-question --skip-taskbar \
		--text="$delete_sentence" \
		--window-icon=idiomind --borders=5 \
		--button=gtk-delete:2 --button="$cancel":0
		ret=$?
			if [[ $ret -eq 2 ]]; then
				rm "$kpt/$itdl.mp3"
				rm "$kpt/$itdl.lnk"
				cd "$drtc"
				grep -v -x -v "$itdl" ./.inx > ./inx
				sed '/^$/d' ./inx > ./.inx
				rm ./inx
				grep -v -x -v "$itdl" ./cnfg4 > ./cnfg4_
				sed '/^$/d' ./cnfg4_ > ./cnfg4
				rm ./cnfg4_
				grep -v -x -v "$itdl" ./cnfg0 > ./cnfg0_
				sed '/^$/d' ./cnfg0_ > ./cnfg0
				rm ./cnfg0_
				notify-send  -i idiomind "$itdl" "$deleted"  -t 1500
			fi
			if [[ $ret -eq 1 ]]; then
				exit
			fi
	else
		yad --title="$confirm" --width=400 \
		--height=140 --on-top --center \
		--image=dialog-question --skip-taskbar \
		--text="$delete_item" \
		--window-icon=idiomind --borders=5 \
		--button=gtk-delete:2 --button="$cancel":0
		ret=$?
			if [[ $ret -eq 2 ]]; then
				rm "$kpt/$itdl.mp3"
				rm "$kpt/$itdl.lnk"
				cd "$drtc"
				grep -v -x -v "$itdl" ./.inx > ./inx
				sed '/^$/d' ./inx > ./.inx
				rm ./inx
				grep -v -x -v "$itdl" ./cnfg3 > ./cnfg3_
				sed '/^$/d' ./cnfg3_ > ./cnfg3
				rm ./cnfg3_
				grep -v -x -v "$itdl" ./cnfg4 > ./cnfg4_
				sed '/^$/d' ./cnfg4_ > ./cnfg4
				rm ./cnfg4_
				grep -v -x -v "$itdl" ./cnfg0 > ./cnfg0_
				sed '/^$/d' ./cnfg0_ > ./cnfg0
				rm ./cnfg0_
				notify-send  -i idiomind "$itdl" "$deleted"  -t 1500
			fi
			if [[ $ret -eq 1 ]]; then
				exit
			fi
	fi
elif [[ $1 = dlns ]]; then
	$yad --width=400 --height=150 --title="$confirm" \
	--on-top --image=dialog-question --center --skip-taskbar \
	--window-icon=idiomind --text="$delete_all" \
	--borders=5 --button="gtk-delete:0" --button="$cancel:1"
		ret=$?
		if [[ $ret -eq 0 ]]; then
			rm -r $DM_tl/Feeds/conten/*
			rm $DC_tl/Feeds/.updt.lst
			rm $DC_tl/Feeds/.dt
			notify-send  -i idiomind "$deleted" " " -t 2000
		else
			exit 1
		fi
elif [[ $1 = dlkt ]]; then

	$yad --image=dialog-question \
	--window-icon=idiomind --width=400 --height=140  \
	--title="$confirm" --on-top --center --skip-taskbar \
	--borders=5 --button=gtk-delete:0 --name=idiomind \
	--button="$cancel":1 --text="$delete_saved2"
	ret=$?
	if [[ $ret -eq 0 ]]; then
		rm -r "$drtc"/.inx "$drtc"/cnfg3 "$drtc"/cnfg4 "$drtc"/cnfg0
		touch "$drtc"/.inx "$drtc"/cnfg3 "$drtc"/cnfg4 "$drtc"/cnfg0
		rm -r "$kpt"/*.mp3
		rm -r "$kpt"/words/*.mp3
	else
		exit 1
	fi

fi