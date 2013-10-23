#!/bin/bash
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Optionally takes one argument, the destination resource directory
if [ -z $1 ]
then
	DESTDIR=$HOME/code/bitfighter/resource/
else
	DESTDIR=$1
fi

function stage() {
	mkdir -p $DESTDIR/$1
	for file in $(find $SCRIPTDIR/$1 -name '*.lua')
	do
		base=$(basename $file)
		rm $DESTDIR/$1/$base 2>/dev/null
		echo "Staging $SCRIPTDIR/$1/$base to $DESTDIR/$1/$base"
		ln -s $SCRIPTDIR/$1/$base $DESTDIR/$1/$base
	done
}

stage editor_plugins
stage scripts