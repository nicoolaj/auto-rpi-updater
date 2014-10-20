#!/bin/bash

declare -a on_exit_items
on_exit(){
    for i in "${on_exit_items[@]}"
    do
        #echo "on_exit: $i"
        eval $i
    done
}

add_on_exit(){
    local n=${#on_exit_items[*]}
    on_exit_items[$n]="$*"
    if [[ $n -eq 0 ]]; then
        #echo "Setting trap"
        trap on_exit EXIT
    fi
}

fctcheck_apt_upd(){
	apt-get update 2>&1 >/dev/null
	if [ $? != 0 ] ; then
		echo "An error occured in fctcheck_apt_upd"
	else
		fctdownload_apt
	fi
}

fctdownload_apt(){
	apt-get dist-upgrade -d -y 2>&1 >/dev/null
}

fctapt_install(){
	apt-get upgrade -y
}

fctafetch(){
	fctcheck_apt_upd 
}

fctsrc_folder_gitlisting(){
	cd $SRC_FOLDER
	add_on_exit rm -f /tmp/gitlisting.$$
	add_on_exit rm -f /tmp/tmplisting.$$
	ls -d -1 -a */.git > /tmp/tmplisting.$$
	sed 's/\.git//' </tmp/tmplisting.$$ >/tmp/gitlisting.$$
}

fctgpull(){
	fctsrc_folder_gitlisting
	while read line; do
		#disable self update
		if [ "$SRC_FOLDER/$line" != "$SCRIPTPATH/" ] ; then
			cd $SRC_FOLDER/$line
			pwd
			git pull
		fi
	done </tmp/gitlisting.$$ 
}

fcthelp(){
	echo "Usage: $0 [MODE]"
	echo " possible MODE toggle :"
	echo " * afetch [A]"
	echo "   rpiupd [A]"
	echo "   gpull [I]"
	echo "   ainstall [ÃI]"
	echo "   total [I]"
	echo ""
	echo "   [I] = interactive mode"
	echo "   [A] = automatic mode"
}

main(){
	if [ $# -eq 1 ] ; then
		DEFAULT_ACTION=$1
		echo "forcing DefAct = $DEFAULT_ACTION"
	fi
	case $DEFAULT_ACTION in
		afetch)
			fctafetch
		;;
		gpull)
			fctgpull
		;;
		ainstall)
			fctafetch
			fctapt_install
		;;
		rpiupd)
			rpi-update
		;;
		total)
			fctafetch
			fctapt_install
			fctgpull
			if [ $SPECIFIC_HARD -eq "raspberrypi" ] ; then
				rpi-update
			fi
		;;
		help)
			fcthelp
		;;
	esac
}

SCRIPTFULLPATH=$(readlink -f $0)
SCRIPTPATH=`dirname $SCRIPTFULLPATH`
ORIGINAL_FOLDER=`pwd`

SRC_FOLDER="/usr/src"
DEFAULT_ACTION="afetch"
SPECIFIC_HARD="raspberrypi"
if [ -f $SCRIPTPATH/config ] ; then
	# Override previous settings
	 . $SCRIPTPATH/config
fi
main $@
on_exit
cd $ORIGINAL_FOLDER
