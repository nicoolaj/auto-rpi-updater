#!/bin/bash

fctcheck-apt-upd(){
	apt-get update
}

fctdownload-apt(){
	apt-get dist-upgrade -d -y 2>&1 >/dev/null
}

fcthelp(){
	echo -e "Usage: $0 [MODE]"
	echo -e " possible MODE toggle :"
	echo -e " * afetch [A]"
	echo -e "   gpull [I]"
	echo -e "   ainstall [ÃI]"
	echo -e ".  total [I]"
	echo -e "\n   [I] = interactive mode"
	echo -e "   [A] = automatic mode"
}


main(){
	case $1
		afetch)
		echo afetch
		;
		gpull)
		echo gpull
		;
		help)
		fcthelp
		;
	esac
}
main $@
