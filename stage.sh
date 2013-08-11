#!/bin/bash
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DESTDIR=$HOME/code/bitfighter/resource/editor_plugins

cd $SCRIPTDIR

for file in $(find . -name '*.lua')
do
	base=$(basename $file)
	rm $DESTDIR/$base 2>/dev/null
	ln -s $SCRIPTDIR/$base $DESTDIR/$base
done