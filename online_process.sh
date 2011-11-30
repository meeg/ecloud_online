#!/bin/bash
if [ $1 ]
then
	echo "Watching $1 for new data"
else
	echo "Specify a directory to watch"
	exit
fi

tempdir="temp/"
localdir="data/"
while true
do
	for i in `ls $1/*.wfm 2>/dev/null`
	do
		filename=`basename "$i"`
		if [[ (! -f "$localdir$filename") && (! -f "$tempdir$filename")  ]]
		then
			echo "copying $filename"
			cp "$1/$filename" "$tempdir$filename"
		fi
	done
	echo "Done copying"
	sleep 1
done
