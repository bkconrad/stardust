#!/bin/bash
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DESTDIR=$HOME/code/bitfighter/resource/

function stage() {
	cd $SCRIPTDIR/$1
	for file in $(find . -name '*.lua')
	do
		base=$(basename $file)
		rm $DESTDIR/$1/$base 2>/dev/null
		echo "Staging $SCRIPTDIR/$1/$base to $DESTDIR/$1/$base"
		ln -s $SCRIPTDIR/$1/$base $DESTDIR/$1/$base
	done
}

stage editor_plugins
stage scripts