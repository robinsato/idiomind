#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
source $DS/ifs/trans/$lgs/edit.conf
source $DS/ifs/cmns.sh

if [ $1 = mkmn ]; then
	#[[ ! -f $DC_tl/.cfg.1 ]] && exit 1
	cd "$DC_tl"
	[[ -d ./images ]] && rm -r ./images
	[[ -d ./words ]] && rm -r ./words
	[[ -f ./*.mp3 ]] && rm ./*.mp3
	[[ -f ./cfg.0 ]] && rm ./cfg.0
	[[ -f ./cfg.1 ]] && rm ./cfg.1
	[[ -f ./cfg.2 ]] && rm ./cfg.2
	[[ -f ./cfg.3 ]] && rm ./cfg.3
	[[ -f ./cfg.5 ]] && rm ./cfg.5
	[[ -f ./cfg.4 ]] && rm ./cfg.4
	[[ -f ./cfg.8 ]] && rm ./cfg.8
	[[ -f ./cfg.12 ]] && rm ./cfg.12
	[[ -d ./practice ]] && rm -r ./practice
	[[ -f ./tpc.sh ]] && rm ./tpc.sh
	[[ -f ./.cfg.11 ]] && rm ./.cfg.11
	ls -t -d -N * > $DC_tl/.cfg.1
	[[ -f $DC_s/cfg.0 ]] && mv -f $DC_s/cfg.0 $DC_s/cfg.16
	n=1
	while [ $n -le $(cat $DC_tl/.cfg.1 | head -50 | wc -l) ]; do
		tp=$(sed -n "$n"p $DC_tl/.cfg.1)
		i=$(cat "$DC_tl/$tp/cfg.8")
		
		if [ ! -f "$DC_tl/$tp/cfg.8" ] || \
		[ ! -f "$DC_tl/$tp/tpc.sh" ] || \
		[ ! -f "$DC_tl/$tp/cfg.0" ] || \
		[ ! -f "$DC_tl/$tp/cfg.1" ] || \
		[ ! -f "$DC_tl/$tp/cfg.3" ] || \
		[ ! -f "$DC_tl/$tp/cfg.4" ] || \
		[ ! -d "$DM_tl/$tp" ]; then
			i=13
			echo "13" > "$DC_tl/$tp/cfg.8"
			cp -f $DS/default/tpc.sh "$DC_tl/$tp/tpc.sh"
		fi
		echo "/usr/share/idiomind/images/img.$i.png" >> $DC_s/cfg.0
		echo "$tp" >> $DC_s/cfg.0
		let n++
	done
	n=1
	while [ $n -le $(cat $DC_tl/.cfg.1 | tail -n+21 | wc -l) ]; do
		ff=$(cat $DC_tl/.cfg.1 | tail -n+21)
		tp=$(echo "$ff" | sed -n "$n"p)
		if [ ! -f "$DC_tl/$tp/cfg.8" ] || \
		[ ! -f "$DC_tl/$tp/tpc.sh" ] || \
		[ ! -f "$DC_tl/$tp/cfg.0" ] || \
		[ ! -f "$DC_tl/$tp/cfg.1" ] || \
		[ ! -f "$DC_tl/$tp/cfg.3" ] || \
		[ ! -f "$DC_tl/$tp/cfg.4" ] || \
		[ ! -d "$DM_tl/$tp" ]; then
			echo '/usr/share/idiomind/images/img.13.png' >> $DC_s/cfg.0
		else
			echo '/usr/share/idiomind/images/img.12.png' >> $DC_s/cfg.0
		fi
		echo "$tp" >> $DC_s/cfg.0
		let n++
	done
	exit

elif [ $1 = edit ]; then
	ttl=$(sed -n 2p $DC_s/cfg.6)
	plg1=$(sed -n 1p $DC_s/cfg.3)
	cfg.1="$DC_s/cfg.1"
	ti=$(cat "$DC_tl/$tpc/cfg.0" | wc -l)
	ni="$DC_tl/$tpc/cfg.1"
	bi=$(cat "$DC_tl/$tpc/cfg.2" | wc -l)
	nstll=$(grep -Fxo "$tpc" $DC_tl/.cfg.3)
	slct=$(mktemp $DT/slct.XXXX)
	
if ! grep -Fxo "$tpc" $DC_tl/.cfg.3; then
if [ "$ti" -ge 15 ]; then
dd="$DS/images/ok.png
$learned
$DS/images/rw.png
$review
$DS/images/rn.png
$rename
$DS/images/dlt.png
$delete
$DS/images/upd.png
$share
$DS/images/pdf.png
$topdf"
else
dd="$DS/images/rn.png
$rename
$DS/images/dlt.png
$delete
$DS/images/upd.png
$share
$DS/images/pdf.png
$topdf"
fi
else
if [ "$ti" -ge 15 ]; then
dd="$DS/images/ok.png
$learned
$DS/images/rw.png
$review
$DS/images/rn.png
$rename
$DS/images/dlt.png
$delete
$DS/images/pdf.png
$topdf"
else
dd="$DS/images/rn.png
$rename
$DS/images/dlt.png
$delete
$DS/images/pdf.png
$topdf"
fi
fi
	echo "$dd" | yad --list --on-top --expand-column=2 \
	--width=280 --name=idiomind --center \
	--height=240 --title="$tpc" --window-icon=idiomind \
	--buttons-layout=end --no-headers --skip-taskbar \
	--borders=0 --button=Ok:0 --column=icon:IMG \
	--column=Action:TEXT > "$slct"
	ret=$?
	slt=$(cat "$slct")
	if  [[ "$ret" -eq 0 ]]; then
		if echo "$slt" | grep -o $learned; then
			/usr/share/idiomind/mngr.sh mkok-
		elif echo "$slt" | grep -o $review; then
			/usr/share/idiomind/mngr.sh mklg-
		elif echo "$slt" | grep -o $rename; then
			/usr/share/idiomind/add.sh new_topic name 2
		elif echo "$slt" | grep -o $delete; then
			/usr/share/idiomind/mngr.sh dlt
		elif echo "$slt" | grep -o $share; then
			/usr/share/idiomind/ifs/upld.sh
		elif echo "$slt" | grep -o $topdf; then
			/usr/share/idiomind/ifs/tls.sh pdf
		fi
		rm -f "$slct"

	elif [[ "$ret" -eq 1 ]]; then
		exit 1
	fi
	
#--------------------------------
elif [ $1 = index ]; then

	DC_tlt="$DC_tl/$4"

	if [ -z "$3" ]; then
		exit 1
	fi
	
	if [ "$2" = W ]; then
		if [[ "$(cat "$DC_tlt/cfg.0" | grep "$5")" ]] && [ -n "$5" ]; then
			sed -i "s/${5}/${5}\n$3/" "$DC_tlt/cfg.0"
			sed -i "s/${5}/${5}\n$3/" "$DC_tlt/cfg.1"
			sed -i "s/${5}/${5}\n$3/" "$DC_tlt/.cfg.11"
		else
			echo "$3" >> "$DC_tlt/cfg.0"
			echo "$3" >> "$DC_tlt/cfg.1"
			echo "$3" >> "$DC_tlt/.cfg.11"
		fi
		echo "$3" >> "$DC_tlt/cfg.3"
		
	elif [ "$2" = S ]; then
		echo "$3" >> "$DC_tlt/cfg.0"
		echo "$3" >> "$DC_tlt/cfg.1"
		echo "$3" >> "$DC_tlt/cfg.4"
		echo "$3" >> "$DC_tlt/.cfg.11"
	fi
	
	lss="$DC_tlt/.cfg.11"
	if [ -n "$(cat "$lss" | sort -n | uniq -dc)" ]; then
		cat "$lss" | awk '!array_temp[$0]++' > lss.tmp
		sed '/^$/d' lss.tmp > "$lss"
	fi
	ls0="$DC_tlt/cfg.0"
	if [ -n "$(cat "$ls0" | sort -n | uniq -dc)" ]; then
		cat "$ls0" | awk '!array_temp[$0]++' > ls0.tmp
		sed '/^$/d' ls0.tmp > "$ls0"
	fi
	ls1="$DC_tlt/cfg.1"
	if [ -n "$(cat "$ls1" | sort -n | uniq -dc)" ]; then
		cat "$ls1" | awk '!array_temp[$0]++' > ls1.tmp
		sed '/^$/d' ls1.tmp > "$ls1"
	fi
	ls2="$DC_tlt/cfg.3"
	if [ -n "$(cat "$ls2" | sort -n | uniq -dc)" ]; then
		cat "$ls2" | awk '!array_temp[$0]++' > ls2.tmp
		sed '/^$/d' ls2.tmp > "$ls2"
	fi
	ls3="$DC_tlt/cfg.4"
	if [ -n "$(cat "$ls3" | sort -n | uniq -dc)" ]; then
		cat "$ls3" | awk '!array_temp[$0]++' > ls3.tmp
		sed '/^$/d' ls3.tmp > "$ls3"
	fi

	exit 1
#--------------------------------
elif [ "$1" = mklg- ]; then
	kill -9 $(pgrep -f "$yad --icons")

	nstll=$(grep -Fxo "$tpc" "$DC_tl/.cfg.3")
	if [ -n "$nstll" ]; then
		if [ $(cat "$DC_tlt/cfg.8") = 7 ]; then
			dts=$(cat "$DC_tlt/cfg.9" | wc -l)
			if [ $dts = 1 ]; then
				dte=$(sed -n 1p "$DC_tlt/cfg.9")
				TM=$(echo $(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) )))
				RM=$((100*$TM/10))
			elif [ $dts = 2 ]; then
				dte=$(sed -n 2p "$DC_tlt/cfg.9")
				TM=$(echo $(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) )))
				RM=$((100*$TM/15))
			elif [ $dts = 3 ]; then
				dte=$(sed -n 3p "$DC_tlt/cfg.9")
				TM=$(echo $(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) )))
				RM=$((100*$TM/30))
			elif [ $dts = 4 ]; then
				dte=$(sed -n 4p "$DC_tlt/cfg.9")
				TM=$(echo $(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) )))
				RM=$((100*$TM/60))
			fi
			if [ "$RM" -ge 50 ]; then
				echo "8" > "$DC_tlt/cfg.8"
			else
				echo "6" > "$DC_tlt/cfg.8"
			fi
		else
			echo "6" > "$DC_tlt/cfg.8"
		fi
		rm -f "$DC_tlt/cfg.7"
	else
		if [ $(cat "$DC_tlt/cfg.8") = 2 ]; then
			dts=$(cat "$DC_tlt/cfg.9" | wc -l)
			if [ $dts = 1 ]; then
				dte=$(sed -n 1p "$DC_tlt/cfg.9")
				TM=$(echo $(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) )))
				RM=$((100*$TM/10))
			elif [ $dts = 2 ]; then
				dte=$(sed -n 2p "$DC_tlt/cfg.9")
				TM=$(echo $(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) )))
				RM=$((100*$TM/15))
			elif [ $dts = 3 ]; then
				dte=$(sed -n 3p "$DC_tlt/cfg.9")
				TM=$(echo $(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) )))
				RM=$((100*$TM/30))
			elif [ $dts = 4 ]; then
				dte=$(sed -n 4p "$DC_tlt/cfg.9")
				TM=$(echo $(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) )))
				RM=$((100*$TM/60))
			fi
			if [ "$RM" -ge 50 ]; then
				echo "3" > "$DC_tlt/cfg.8"
			else
				echo "1" > "$DC_tlt/cfg.8"
			fi
		else
			echo "1" > "$DC_tlt/cfg.8"
		fi
		rm -f "$DC_tlt/cfg.7"
	fi
	cat "$DC_tlt/cfg.0" | awk '!array_temp[$0]++' > $DT/cfg.0.tmp
	sed '/^$/d' $DT/cfg.0.tmp > "$DC_tlt/cfg.0"
	rm -f $DT/*.tmp
	rm "$DC_tlt/cfg.2" "$DC_tlt/cfg.1" "$DC_tl/.cfg.6"
	cp -f "$DC_tlt/cfg.0" "$DC_tlt/cfg.1"

	$DS/mngr.sh mkmn &

	idiomind topic & exit 1
	
#--------------------------------
elif [ "$1" = mkok- ]; then
	kill -9 $(pgrep -f "yad --icons")

	if [ -f "$DC_tlt/cfg.9" ]; then
		dts=$(cat "$DC_tlt/cfg.9" | wc -l)
		if [ $dts = 1 ]; then
			dte=$(sed -n 1p "$DC_tlt/cfg.9")
			TM=$(echo $(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) )))
			RM=$((100*$TM/10))
		elif [ $dts = 2 ]; then
			dte=$(sed -n 2p "$DC_tlt/cfg.9")
			TM=$(echo $(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) )))
			RM=$((100*$TM/15))
		elif [ $dts = 3 ]; then
			dte=$(sed -n 3p "$DC_tlt/cfg.9")
			TM=$(echo $(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) )))
			RM=$((100*$TM/30))
		elif [ $dts = 4 ]; then
			dte=$(sed -n 4p "$DC_tlt/cfg.9")
			TM=$(echo $(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) )))
			RM=$((100*$TM/60))
		fi
		if [ "$RM" -ge 50 ]; then
			if [ $(cat "$DC_tlt/cfg.9" | wc -l) = 4 ]; then
				echo "_
				_
				_
				$(date +%m/%d/%Y)" > "$DC_tlt/cfg.9"
			else
				echo "$(date +%m/%d/%Y)" >> "$DC_tlt/cfg.9"
			fi
		fi
	else
		echo "$(date +%m/%d/%Y)" > "$DC_tlt/cfg.9"
	fi
	> "$DC_tlt/cfg.7"
	nstll=$(grep -Fxo "$tpc" "$DC_tl/.cfg.3")
	if [ -n "$nstll" ]; then
		echo "7" > "$DC_tlt/cfg.8"
	else
		echo "2" > "$DC_tlt/cfg.8"
	fi
	rm "$DC_tlt/cfg.2" "$DC_tlt/cfg.1"
	cp -f "$DC_tlt/cfg.0" "$DC_tlt/cfg.2"
	$DS/mngr.sh mkmn &

	idiomind topic & exit 1
	
	
elif [ $1 = dli ]; then
	touch $DT/ps_lk

	source $DS/ifs/yad/mngr.sh
	itdl="$2"
	
	[[ -z "$itdl" ]] && rm -f $DT/ps_lk && exit
	
	nme="$(nmfile "$itdl")"
	
	if [ "$3" = "C" ]; then
		# rm word
		if [ -f "$DM_tlt/words/$nme.mp3" ]; then
			rm "$DM_tlt/words/$nme.mp3"
			cd "$DC_tlt/practice"
			sed -i 's/'"$itdl"'//g' ./fin
			sed -i 's/'"$itdl"'//g' ./mcin
			sed -i 's/'"$itdl"'//g' ./lwin
			cd ..
			grep -v -x -F "$itdl" ./.cfg.11 > ./cfg.11.tmp
			sed '/^$/d' ./cfg.11.tmp > ./.cfg.11
			grep -v -x -F "$itdl" ./cfg.0 > ./cfg.0.tmp
			sed '/^$/d' ./cfg.0.tmp > ./cfg.0
			grep -v -x -F "$itdl" ./cfg.2 > ./cfg.2.tmp
			sed '/^$/d' ./cfg.2.tmp > ./cfg.2
			grep -v -x -F "$itdl" ./cfg.1 > ./cfg.1.tmp
			sed '/^$/d' ./cfg.1.tmp > ./cfg.1
			grep -v -x -F "$itdl" cfg.3 > cfg.3.tmp
			sed '/^$/d' cfg.3.tmp > cfg.3
			rm ./*.tmp
		# rm sentence
		elif [ -f "$DM_tlt/$nme.mp3" ]; then
			rm "$DM_tlt/$nme.mp3"
			cd "$DC_tlt/practice"
			sed -i 's/'"$itdl"'//g' ./lsin
			cd ..
			grep -v -x -F "$itdl" ./.cfg.11 > ./cfg.11.tmp
			sed '/^$/d' ./cfg.11.tmp > ./.cfg.11
			grep -v -x -F "$itdl" ./cfg.0 > ./cfg.0.tmp
			sed '/^$/d' ./cfg.0.tmp > ./cfg.0
			grep -v -x -F "$itdl" ./cfg.2 > ./cfg.2.tmp
			sed '/^$/d' ./cfg.2.tmp > ./cfg.2
			grep -v -x -F "$itdl" ./cfg.1 > ./cfg.1.tmp
			sed '/^$/d' ./cfg.1.tmp > ./cfg.1
			grep -v -x -F "$itdl" cfg.4 > cfg.4.tmp
			sed '/^$/d' cfg.4.tmp > cfg.4
			rm ./*.tmp
		else
			cd "$DC_tlt/practice"
			sed -i 's/'"$itdl"'//g' ./fin
			sed -i 's/'"$itdl"'//g' ./mcin
			sed -i 's/'"$itdl"'//g' ./lwin
			sed -i 's/'"$itdl"'//g' ./lsin
			cd ..
			grep -v -x -F "$itdl" ./.cfg.11 > ./cfg.11.tmp
			sed '/^$/d' ./cfg.11.tmp > ./.cfg.11
			grep -v -x -F "$itdl" ./cfg.0 > ./cfg.0.tmp
			sed '/^$/d' ./cfg.0.tmp > ./cfg.0
			grep -v -x -F "$itdl" ./cfg.2 > ./cfg.2.tmp
			sed '/^$/d' ./cfg.2.tmp > ./cfg.2
			grep -v -x -F "$itdl" ./cfg.1 > ./cfg.1.tmp
			sed '/^$/d' ./cfg.1.tmp > ./cfg.1
			grep -v -x -F "$itdl" cfg.3 > cfg.3.tmp
			sed '/^$/d' cfg.3.tmp > cfg.3
			grep -v -x -F "$itdl" cfg.4 > cfg.4.tmp
			sed '/^$/d' cfg.4.tmp > cfg.4
			rm ./*.tmp
		fi
		rm -f $DT/ps_lk
		exit 1
	fi
	
	# rm word
	if [ -f "$DM_tlt/words/$nme.mp3" ]; then
		flw="$DM_tlt/words/$nme.mp3"
	elif [ -f "$DM_tlt/$nme.mp3" ]; then
		fls="$DM_tlt/$nme.mp3"
	fi

	if [ -f "$flw" ]; then

			dlg_msg_1 " $delete_word "
			ret=$(echo "$?")
			
			if [ $ret -eq 0 ]; then
			
				(sleep 1 && kill -9 $(pgrep -f "$yad --form "))
				killall edt1 edt2
				rm -f "$flw"
				cd "$DC_tlt/practice"
				sed -i 's/'"$itdl"'//g' ./fin
				sed -i 's/'"$itdl"'//g' ./mcin
				sed -i 's/'"$itdl"'//g' ./lwin
				cd ..
				grep -v -x -F "$itdl" ./.cfg.11 > ./cfg.11.tmp
				sed '/^$/d' ./cfg.11.tmp > ./.cfg.11
				grep -v -x -F "$itdl" ./cfg.0 > ./cfg.0.tmp
				sed '/^$/d' ./cfg.0.tmp > ./cfg.0
				grep -v -x -F "$itdl" ./cfg.2 > ./cfg.2.tmp
				sed '/^$/d' ./cfg.2.tmp > ./cfg.2
				grep -v -x -F "$itdl" ./cfg.1 > ./cfg.1.tmp
				sed '/^$/d' ./cfg.1.tmp > ./cfg.1
				grep -v -x -F "$itdl" cfg.3 > cfg.3.tmp
				sed '/^$/d' cfg.3.tmp > cfg.3
				rm ./*.tmp
				rm -f $DT/ps_lk & exit
			else
				rm -f $DT/ps_lk & exit
			fi
			
	elif [ -f "$fls" ]; then

			dlg_msg_1 " $delete_sentence "
			ret=$(echo "$?")
			
			if [ $ret -eq 0 ]; then
				(sleep 1 && kill -9 $(pgrep -f "$yad --form "))
				rm -f "$fls"
				cd "$DC_tlt/practice"
				sed -i 's/'"$itdl"'//g' ./lsin
				cd ..
				grep -v -x -F "$itdl" ./.cfg.11 > ./cfg.11.tmp
				sed '/^$/d' ./cfg.11.tmp > ./.cfg.11
				grep -v -x -F "$itdl" ./cfg.0 > ./cfg.0.tmp
				sed '/^$/d' ./cfg.0.tmp > ./cfg.0
				grep -v -x -F "$itdl" ./cfg.2 > ./cfg.2.tmp
				sed '/^$/d' ./cfg.2.tmp > ./cfg.2
				grep -v -x -F "$itdl" ./cfg.1 > ./cfg.1.tmp
				sed '/^$/d' ./cfg.1.tmp > ./cfg.1
				grep -v -x -F "$itdl" cfg.4 > cfg.4.tmp
				sed '/^$/d' cfg.4.tmp > cfg.4
				rm ./*.tmp
				rm -f $DT/ps_lk & exit
			else
				rm -f $DT/ps_lk & exit
			fi
			
	elif [ ! -f "$flw" ] || [ ! -f "$flw" ]; then

			dlg_msg_1 " $delete_item "
			ret=$(echo "$?")
			
			if [ $ret -eq 0 ]; then
				(sleep 1 && kill -9 $(pgrep -f "$yad --form "))
				cd "$DC_tlt/practice"
				sed -i 's/'"$itdl"'//g' ./fin
				sed -i 's/'"$itdl"'//g' ./mcin
				sed -i 's/'"$itdl"'//g' ./lwin
				sed -i 's/'"$itdl"'//g' ./lsin
				cd ..
				grep -v -x -F "$itdl" ./.cfg.11 > ./cfg.11.tmp
				sed '/^$/d' ./cfg.11.tmp > ./.cfg.11
				grep -v -x -F "$itdl" ./cfg.0 > ./cfg.0.tmp
				sed '/^$/d' ./cfg.0.tmp > ./cfg.0
				grep -v -x -F "$itdl" ./cfg.2 > ./cfg.2.tmp
				sed '/^$/d' ./cfg.2.tmp > ./cfg.2
				grep -v -x -F "$itdl" ./cfg.1 > ./cfg.1.tmp
				sed '/^$/d' ./cfg.1.tmp > ./cfg.1
				grep -v -x -F "$itdl" cfg.4 > cfg.4.tmp
				sed '/^$/d' cfg.4.tmp > cfg.4
				grep -v -x -F "$itdl" cfg.3 > cfg.3.tmp
				sed '/^$/d' cfg.3.tmp > cfg.3
				rm ./*.tmp
				rm -f $DT/ps_lk & exit
			else
				rm -f $DT/ps_lk & exit
			fi
	fi
	
#--------------------------------
elif [ $1 = dlt ]; then
	include $DS/ifs/mods/mngr
	
	dlg_msg_1 " $delete_topic "
	ret=$(echo "$?")
		
		if [ $ret -eq 0 ]; then
		
			[[ -d "$DM_tl/$tpc" ]] && rm -r "$DM_tl/$tpc"
			[[ -d "$DC_tl/$tpc" ]] && rm -r "$DC_tl/$tpc"
			> $DC_s/cfg.6
			rm $DC_s/cfg.8
			> $DC_tl/.cfg.8
			grep -v -x -F "$tpc" $DC_tl/.cfg.2 > $DC_tl/.cfg.2.tmp
			sed '/^$/d' $DC_tl/.cfg.2.tmp > $DC_tl/.cfg.2
			grep -v -x -F "$tpc" $DC_tl/.cfg.1 > $DC_tl/.cfg.1.tmp
			sed '/^$/d' $DC_tl/.cfg.1.tmp > $DC_tl/.cfg.1
			grep -v -x -F "$tpc" $DC_tl/.cfg.3 > $DC_tl/.cfg.3.tmp
			sed '/^$/d' $DC_tl/.cfg.3.tmp > $DC_tl/.cfg.3
			grep -v -x -F "$tpc" $DC_tl/.cfg.7 > $DC_tl/.cfg.7.tmp
			sed '/^$/d' $DC_tl/.cfg.7.tmp > $DC_tl/.cfg.7
			grep -v -x -F "$tpc" $DC_tl/.cfg.6 > $DC_tl/.cfg.6.tmp
			sed '/^$/d' $DC_tl/.cfg.6.tmp > $DC_tl/.cfg.6
			grep -v -x -F "$tpc" $DC_tl/.cfg.5 > $DC_tl/.cfg.5.tmp
			sed '/^$/d' $DC_tl/.cfg.5.tmp > $DC_tl/.cfg.5
			rm $DC_tl/.*.tmp 
			
			kill -9 $(pgrep -f "$yad --list ")
			$DS/mngr.sh mkmn
			rm -f $DT/ps_lk & exit
		else
			rm -f $DT/ps_lk & exit
		fi

#--------------------------------
elif [ "$1" = edt ]; then

	source /usr/share/idiomind/ifs/ifs.sh
	include $DS/ifs/mods/mngr
	wth=$(sed -n 7p $DC_s/cfg.18)
	eht=$(sed -n 8p $DC_s/cfg.18)
	dct="$DS/addons/Dics/cnfg.sh"
	cnf=$(mktemp $DT/cnf.XXXX)
	edta=$(sed -n 17p ~/.config/idiomind/s/cfg.1)
	tpcs=$(cat "$DC_tl/.cfg.2" | egrep -v "$tpc" | cut -c 1-40 \
	| tr "\\n" '!' | sed 's/!\+$//g')
	c=$(echo $(($RANDOM%10000)))
	re='^[0-9]+$'
	v="$2"
	nme="$(nmfile "$3")"
	ff="$4"

	if [ "$v" = v1 ]; then
		ind="$DC_tlt/cfg.1"
		inp="$DC_tlt/cfg.2"
		chk="$mark_as_learned"
	elif [ "$v" = v2 ]; then
		ind="$DC_tlt/cfg.2"
		inp="$DC_tlt/cfg.1"
		chk="$review"
	fi

	file="$DM_tlt/words/$nme.mp3"
	AUD="$DM_tlt/words/$nme.mp3"

	if [ -f "$file" ]; then
		TGT="$nme"
		tgs=$(eyeD3 "$file")
		SRC=$(echo "$tgs" | grep -o -P '(?<=IWI2I0I).*(?=IWI2I0I)')
		inf=$(echo "$tgs" | grep -o -P '(?<=IWI3I0I).*(?=IWI3I0I)' | tr '_' '\n')
		echo "$inf"
		mrk=$(echo "$tgs" | grep -o -P '(?<=IWI4I0I).*(?=IWI4I0I)')
		src=$(echo "$SRC")
		ok=$(echo "FALSE")
		exm1=$(echo "$inf" | sed -n 1p)
		dftn=$(echo "$inf" | sed -n 2p)
		ntes=$(echo "$inf" | sed -n 3p)
		dlte="$DS/mngr.sh dli '$nme'"
		imge="$DS/add.sh set_image '$nme' word"

		dlg_form_1 $cnf
		ret=$(echo "$?")
			
			srce=$(cat $cnf | tail -12 | sed -n 2p)
			topc=$(cat $cnf | tail -12 | sed -n 3p)
			audo=$(cat $cnf | tail -12 | sed -n 4p)
			exm1=$(cat $cnf | tail -12 | sed -n 5p)
			dftn=$(cat $cnf | tail -12 | sed -n 6p)
			ntes=$(cat $cnf | tail -12 | sed -n 7p)
			mrk2=$(cat $cnf | tail -12 | sed -n 8p)
			mrok=$(cat $cnf | tail -12 | sed -n 9p)
			
			rm -f $cnf
			
			source /usr/share/idiomind/ifs/c.conf
			include $DS/ifs/mods/add
			#source $DS/ifs/mods/add_yad.sh
			
			if [[ "$mrk" != "$mrk2" ]]; then
				if [[ "$mrk2" = "TRUE" ]]; then
					echo "$TGT" >> "$DC_tlt/cfg.6"
				else
					grep -v -x -v "$TGT" "$DC_tlt/cfg.6" > "$DC_tlt/cfg.6.tmp"
					sed '/^$/d' "$DC_tlt/cfg.6.tmp" > "$DC_tlt/cfg.6"
					rm "$DC_tlt/cfg.6.tmp"
				fi
				add_tags_8 W "$mrk2" "$DM_tlt/words/$nme".mp3 >/dev/null 2>&1
			fi
			
			if [[ "$audo" != "$file" ]]; then
				eyeD3 --write-images=$DT "$file"
				cp -f "$audo" "$DM_tlt/words/$nme.mp3"
				add_tags_2 W "$TGT" "$srce" "$DM_tlt/words/$nme.mp3" >/dev/null 2>&1
				eyeD3 --add-image $DT/ILLUSTRATION.jpeg:ILLUSTRATION \
				"$DM_tlt/words/$nme.mp3" >/dev/null 2>&1
				[[ -d $DT/idadtmptts ]] && rm -fr $DT/idadtmptts
			fi
			
			if [[ "$srce" != "$SRC" ]]; then
				add_tags_5 W "$srce" "$file" >/dev/null 2>&1
			fi
			
			infm="$(echo $exm1 && echo $dftn && echo $ntes)"
			if [ "$infm" != "$inf" ]; then
				impr=$(echo "$infm" | tr '\n' '_')
				add_tags_6 W "$impr" "$file" >/dev/null 2>&1
				echo "eitm.$tpc.eitm" >> \
				$DC/addons/stats/.log &
			fi

			mv -f "$DT/$nme.mp3" "$file"

			if [[ "$tpc" != "$topc" ]]; then
				cp -f "$audo" "$DM_tl/$topc/words/$nme.mp3"
				$DS/mngr.sh index W "$nme" "$topc" &
				if [ -n "$(cat "$DC_tl/.cfg.2" | grep "$topc")" ]; then
					$DS/mngr.sh dli "$nme" C
				fi
			fi
			
			if [[ "$mrok" = "TRUE" ]]; then
				grep -v -x -v "$nme" "$ind" > $DT/tx
				sed '/^$/d' $DT/tx > "$ind"
				rm $DT/tx
				echo "$nme" >> "$inp"
				echo "okim.1.okim" >> \
				$DC/addons/stats/.log &
				./vwr.sh "$v" "nll" $ff & exit 1
			fi
			./vwr.sh "$v" "$nme" $ff & exit 1
			
	else 
		file="$DM_tlt/$nme.mp3"
		tgs=$(eyeD3 "$file")
		mrk=$(echo "$tgs" | grep -o -P '(?<=ISI4I0I).*(?=ISI4I0I)')
		tgt=$(echo "$tgs" | grep -o -P '(?<=ISI1I0I).*(?=ISI1I0I)')
		src=$(echo "$tgs" | grep -o -P '(?<=ISI2I0I).*(?=ISI2I0I)')
		lwrd=$(echo "$tgs" | grep -o -P '(?<=IWI3I0I).*(?=IPWI3I0I)')
		pwrds=$(echo "$tgs" | grep -o -P '(?<=IPWI3I0I).*(?=IPWI3I0I)')
		wrds="$DS/add.sh edit_list_words '$nme' F $c"
		
		edau="--button=Edit Audio:/usr/share/idiomind/ifs/tls.sh edta '$DM_tlt/$nme.mp3' '$DM_tlt'"
		dlte="$DS/mngr.sh dli '$nme'"
		imge="$DS/add.sh set_image '$nme' sentence"
		
		dlg_form_2 $cnf
		ret=$(echo "$?")
			
			mrok=$(cat $cnf | tail -8 | sed -n 1p)
			mrk2=$(cat $cnf | tail -8 | sed -n 2p)
			trgt=$(cat $cnf | tail -8 | sed -n 3p)
			srce=$(cat $cnf | tail -8 | sed -n 4p)
			topc=$(cat $cnf | tail -8 | sed -n 5p)
			audo=$(cat $cnf | tail -8 | sed -n 6p)
			
			source /usr/share/idiomind/ifs/c.conf
			include $DS/ifs/mods/add

			rm -f $cnf
			
			if [ "$mrk" != "$mrk2" ]; then
				if [ "$mrk2" = "TRUE" ]; then
					echo "$nme" >> "$DC_tlt/cfg.6"
				else
					grep -v -x -v "$nme" "$DC_tlt/cfg.6" > "$DC_tlt/cfg.6.tmp"
					sed '/^$/d' "$DC_tlt/cfg.6.tmp" > "$DC_tlt/cfg.6"
					rm "$DC_tlt/cfg.6.tmp"
				fi
				add_tags_8 S "$mrk2" "$DM_tlt/$nme.mp3" >/dev/null 2>&1
			fi
			
			if [ -n "$audo" ]; then
			
				if [ "$audo" != "$file" ]; then
				
					cp -f "$audo" "$DM_tlt/$nme.mp3"
					eyeD3 --remove-all "$DM_tlt/$nme.mp3"
					add_tags_1 S "$trgt" "$srce" "$DM_tlt/$nme.mp3" >/dev/null 2>&1
					source $DS/default/dicts/$lgt
					
					(
					DT_r=$(mktemp -d $DT/XXXXXX)
					cd $DT_r
					r=$(echo $(($RANDOM%1000)))
					clean_3 $DT_r $r
					translate "$(cat $aw | sed '/^$/d')" auto $lg | sed 's/,//g' \
					| sed 's/\?//g' | sed 's/\¿//g' | sed 's/;//g' > $bw
					check_grammar_1 $DT_r $r
					list_words $DT_r $r
					grmrk=$(cat g.$r | sed ':a;N;$!ba;s/\n/ /g')
					lwrds=$(cat A.$r)
					pwrds=$(cat B.$r | tr '\n' '_')
					add_tags_3 W "$lwrds" "$pwrds" "$grmrk" "$DM_tlt/$nme.mp3" >/dev/null 2>&1
					fetch_audio $aw $bw
					
					[[ -d $DT_r ]] && rm -fr $DT_r
					) &
				fi
			fi
			
			if [ -f $DT/tmpau.mp3 ]; then
				cp -f $DT/tmpau.mp3 "$DM_tlt/$nme.mp3"
				add_tags_1 S "$trgt" "$srce" "$DM_tlt/$nme.mp3" >/dev/null 2>&1
				rm -f $DT/tmpau.mp3
			fi

			if [ "$trgt" != "$tgt" ]; then
				
				fln="$(echo "$trgt" | cut -c 1-100 | sed 's/[ \t]*$//' \
				| sed s'/&//'g | sed s'/://'g | sed "s/'/ /g")"
				sed -i "s/${nme}/${fln}/" "$DC_tlt/cfg.4"
				sed -i "s/${nme}/${fln}/" "$DC_tlt/cfg.1"
				sed -i "s/${nme}/${fln}/" "$DC_tlt/cfg.0"
				sed -i "s/${nme}/${fln}/" "$DC_tlt/cfg.2"
				sed -i "s/${nme}/${fln}/" "$DC_tlt/.cfg.11"
				sed -i "s/${nme}/${fln}/" "$DC_tlt/practice/lsin.tmp"
				mv -f "$DM_tlt/$nme".mp3 "$DM_tlt/$fln".mp3
				add_tags_7 S "$trgt" "$DM_tlt/$fln.mp3" >/dev/null 2>&1
				source $DS/default/dicts/$lgt

				(
				DT_r=$(mktemp -d $DT/XXXXXX)
				cd $DT_r
				r=$(echo $(($RANDOM%1000)))
				clean_3 $DT_r $r
				translate "$(cat $aw | sed '/^$/d')" auto $lg | sed 's/,//g' \
				| sed 's/\?//g' | sed 's/\¿//g' | sed 's/;//g' > $bw
				check_grammar_1 $DT_r $r
				list_words $DT_r $r
				grmrk=$(cat g.$r | sed ':a;N;$!ba;s/\n/ /g')
				lwrds=$(cat A.$r)
				pwrds=$(cat B.$r | tr '\n' '_')
				add_tags_3 W "$lwrds" "$pwrds" "$grmrk" "$DM_tlt/$fln".mp3 >/dev/null 2>&1
				fetch_audio $aw $bw
			
				[[ -d $DT_r ]] && rm -fr $DT_r
				) &
				
				nme="$fln"
			fi
			
			if [ "$srce" != "$src" ]; then
				file="$DM_tlt/$nme.mp3"
				add_tags_5 S "$srce" "$file"
			fi
			
			if [ "$tpc" != "$topc" ]; then
			
				cp -f "$audo" "$DM_tl/$topc/$nme.mp3"
				tag="$(eyeD3 "$DM_tl/$topc/$nme.mp3" | grep -o -P '(?<=ISI1I0I).*(?=ISI1I0I)')"
				trgt="$(clean_3 "$tag")"
				n=1
				while [ $n -le "$(echo "$trgt" | wc -l)" ]; do
					echo "$(echo "$tgt" | sed -n "$n"p).mp3" >> "$DC_tl/$topc/cfg.5"
					let n++
				done
				$DS/mngr.sh index S "$trgt" "$topc" &
				if [ -n "$(cat "$DC_tl/.cfg.2" | grep "$topc")" ]; then
					$DS/mngr.sh dli "$nme" C
				fi
			fi
			
			if [ "$mrok" = "TRUE" ]; then
				grep -v -x -v "$nme" "$ind" > $DT/tx
				sed '/^$/d' $DT/tx > "$ind"
				rm $DT/tx
				echo "$nme" >> "$inp"
				echo "okim.1.okim" >> \
				$DC/addons/stats/.log &
				./vwr.sh "$v" "nll" $ff & exit 1
			fi
			
			[ -d "$DT/$c" ] && $DS/add.sh selecting_words_edit "$nme" S $c "$trgt" &
			./vwr.sh "$v" "$nme" $ff & exit 1
	fi
fi
