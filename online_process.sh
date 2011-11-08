#!/bin/bash
#octave 
datadir="/media/ADATA/"
tempdir="/home/meeg/matlab_online/temp/"
localdir="/home/meeg/matlab_online/data/"
while true
do
for i in `ls $datadir*.wfm 2>/dev/null`
do
filename=`basename "$i"`
if [[ (! -f "$localdir$filename") && (! -f "$tempdir$filename")  ]]
then
echo "copying $filename"
cp "$datadir$filename" "$tempdir$filename"
fi
done
echo "Done copying"
sleep 1
done
