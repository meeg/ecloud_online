#!/bin/bash
#octave 
datadir="/media/ADATA"
localdir="/home/meeg/matlab_online/temp"
while true
do
for i in `ls $datadir/*.wfm`
do
filename=`basename "$i"`
echo "$filename"
if [[ ! -f "$localdir/$filename" ]]
then
echo "copying $filename"
cp "$datadir/$filename" "$localdir/$filename"
fi
done
sleep 1
done
