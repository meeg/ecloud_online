#!/bin/bash
export LM_LICENSE_FILE='27010@sunlics1:27010@sunlics2:27010@sunlics3'
ecloud_root="/afs/slac.stanford.edu/g/arda/ecloud"
date="MD201111/111109"
mkdir -p "$ecloud_root/DataProcessed/$date/spectrograms"
for filename in `ls "$ecloud_root/DataProcessed/$date/"|grep mat|sed "s/.mat//"`
do
	/afs/slac/package/matlab/linux/2007b/bin/matlab -nosplash -nodesktop -r "make_spectrograms $date $filename"
done
