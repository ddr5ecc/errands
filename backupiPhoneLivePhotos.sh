#!/bin/sh

# 202108010 PST
# Objective: Backup livephotos in a script
# Mechanism
# 	mount with ifuse. 
#	backup with rsync. 
#	rename file with exif to match with pCloud autosync filename. 

# TODO: only backup MOV in the nearest year. 

# check rsync 
[ ! -e /usr/bin/rsync ] && echo Please install rsync

# check ifuse
[ ! -e /usr/bin/ifuse ] && echo Please install ifuse

# check exif
[ ! -e /usr/bin/exif ] && echo Please install exif

# make sure to connect the iPhone to the computer
clear
echo "Please connect iPhone to the computer and press Enter to continue..."
read z
echo

targetDirectory=/home/sdz/tmp/livephotos

echo
echo Livephotos will be backuped to this directory. 
echo \		$targetDirectory
echo

[ ! -d $targetDirectory ] && mkdir -p $targetDirectory 
	


# Mount iPhone to /tmp/mnt
mountDirectory=/tmp/mnt
[ ! -d /tmp/mnt ] && /usr/bin/mkdir -p $mountDirectory

/usr/bin/ifuse $mountDirectory
[ $? = 1 ] && echo Something went wrong with ifuse mounting. 


# Enter iPhone photo directory
cd $mountDirectory/DCIM

for dir in ???APPLE;
	do
		cd $dir
		
		# Check every JPG
		for file in `ls | grep .JPG`;
	
			do
				# Check if there are filenames with .JPG and .MOV ending
				# Change .MOV filename to according time stamp. 
				if [ -e `echo $file | sed s/.JPG/.MOV/` ] ; then

		# Get time stamp of the JPG file for MOV
		# exif，輸入檔名，抓出日間戳記，只留下第四，第五欄，刪除|，將兩個:換成-
		# exit, extract filename, get time stamp, leave column #4 and #5, delete |, replace 2 colons with dash
					timeStamp=`/usr/bin/exif $file | grep "Date and Time       |" | awk '{print $4,$5}' | sed  's/|//' | sed 's/:/-/' | sed 's/:/-/'`

					# Move the .MOV file to destination directory and rename it with time stamp. 
					/usr/bin/rsync -avk `echo $file | sed s/.JPG/.MOV/` $targetDirectory/"$timeStamp.mov"
					echo Working on:  $file \	Target file is:  $targetDirectory/$timeStamp.mov
					echo
					echo

				fi
			done
		cd ..
	done

echo Mission completed. Needs root priviledge to unmount $mountDirectory.  
