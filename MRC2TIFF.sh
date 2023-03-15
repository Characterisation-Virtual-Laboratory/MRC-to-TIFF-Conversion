#!/bin/bash

################################################
# Written by Joshua Silver, jsilver@uow.edu.au #
# Last update: 2022-03-29                      #
# v1.0                                         #
#                                              #
# Purpose: Implement pseudo multithreading for #
# IMODs 'mrc2tif' function.                    #
################################################

### Defaults
defaultDestination="/path/to/default/save/location/"
defaultPartCount=8
iModPath="/opt/IMOD/bin"


preRunConfig()
{
	logPath="$(dirname $(realpath $0))/logs/"
	logFile="$logPath$(basename "$0" | sed 's/.sh$//g').log"
	partCount=$defaultPartCount
	coreCount=$(($(lscpu | grep "Socket(s)" | tr -s ' ' | cut -d " " -f 2) * $(lscpu | grep "Core(s)" | tr -s ' ' | cut -d " " -f 4)))
	### Ensure that whitespace in the pathnames are handled correctly
	saveIFS=$IFS
	IFS=$(echo -en "\n\b")
}

usage()
{
        echo "Usage: $0 [-p <num>] </source/dir/project> [</dest/dir>]" >&2
}

checkArgs()
{
	### Get num of parallel process to start
	while getopts ":p:" opt
	do
		case ${opt} in
			p)
				partCount=${OPTARG}
				;;
			/?)
				echo "Invalid option" >&2
				usage
				exit 1
				;;
		esac
	done
	shift $((OPTIND - 1))

	### Check for correct number of arguments
	if [[ $# -lt 1 || $# -gt 2 ]]
	then
		echo "Invalid number of arguments" >&2
		usage
		exit 101
	fi

	mrcSource=$1
	tiffDest=${2:-$defaultDestination}

	### Append trailing slash to folder paths if not already pressent
	length=${#mrcSource}
	lastChar=${mrcSource:length-1:1}
	if [ $lastChar != "/" ]
	then
		mrcSource="$mrcSource/"
	fi

	length=${#tiffDeset}
	lastChar=${tiffDest:length-1:1}
	if [ $lastChar != "/" ]
	then
		tiffDest="$tiffDest/"
	fi

	### Check source and destination are directories
	if [ ! -d $mrcSource ]
	then
		echo "<srcdir> has to be a valid directory" >&2
		exit 102
	fi
	if [ ! -d $tiffDest ]
	then
		echo "<destdir> has to be a valid directory" >&2
		exit 103
	fi
}

findMRCs()
{
	### Get a list of mrc files in the source directory (and subdirs).
	mrcList="${logPath}tmpMRCList.$$"
	find $mrcSource -name \*.mrc -type f >> $mrcList
	sed -i "s|^$mrcSource||g" $mrcList
	sed -i 's|.mrc$||g' $mrcList
	mrcCount=$(cat $mrcList | wc -l)
}

createDestDirs()
{
	### Create directory structure for Tiffs, IMOD's mrc2tif doesn't create missing parent directories
	dirList="${logPath}tmpDirList.$$"
	find $mrcSource -type d >> $dirList
	sed -i "s|^$mrcSource||g" $dirList
	captureDir=$(basename $mrcSource)
	tiffDest="$tiffDest$captureDir/"
	if [ -d $tiffDest ]
	then
		echo "Destination directory already exists, stopping run." >> $logFile
		echo "Destination directory already exists, stopping run." >&2
		postRunCleanup
		exit 111
	fi
	echo "Creating Tiff Dir: $tiffDest" >> $logFile
	mkdir $tiffDest
	for i in `cat $dirList`
	do
		mkdir -p $tiffDest$i
	done
}

splitMRCList()
{
	### Sanity checking on the number of parallel parts
	### Limit part count to the smallest of: flag, CPU core count, number of MRCs
	if [[ $coreCount -lt $partCount && $coreCount -lt $mrcCount ]]
	then
		partCount=$coreCount
		echo "Limiting parts to number of CPU Cores: $coreCount" >> $logFile
	elif [[ $mrcCount -lt $partCount && $mrcCount -lt $coreCount ]]
	then
		partCount=$mrcCount
		echo "Limiting parts to number of MRC files: $mrcCount" >> $logFile
	fi

	### Split MRC List if needed
	if [ $partCount -ne 1 ]
	then
		loopCounter=0
		for i in `cat $mrcList`
		do
			echo "$i" >> ${mrcList}_$(($loopCounter % $partCount))
			loopCounter=$(($loopCounter+1))
		done
	else
		mv $mrcList ${mrcList}_0
	fi
}

getTimestamp()
{
        echo $(date)
}

convert2tiff()
{
        for i in `cat $1`
        do
                printf "."
                ### -s = single file, -c 5 = RZW compression
                $iModPath/mrc2tif -s -c 5 $mrcSource$i.mrc $tiffDest$i.tiff > /dev/null
        done
}

convertMRCs()
{
	printf "Writing $mrcCount tiff images "
	for (( i=0; i<$partCount; i++ ))
	do
		convert2tiff "${mrcList}_$i" &
	done
	wait
	echo ""
}

writeStats()
{
	echo "Start: $startTime" >> $logFile
	echo "End: $endTime" >> $logFile
	### Calculate conversion rate (GB/hr)
	startTime=$(date -d "$startTime" +%s)
	endTime=$(date -d "$endTime" +%s)
	runDuration=$(echo "scale=4; ($endTime-$startTime)/3600" | bc)
	dirSize=$(echo "scale=2; $(du -shBM --apparent-size $mrcSource | cut -d 'M' -f 1) / 1024" | bc)
	echo "Source Size: ${dirSize}GB" >> $logFile
	echo "Converted at $(echo "scale=2; $dirSize / $runDuration" | bc)GB/hr" >> $logFile
}

postRunCleanup()
{
	echo "" >> $logFile
	rm -f ${logPath}tmpDirList.*
	rm -f ${logPath}tmpMRCList.*
	IFS=$SAVEIFS
}


##### MAIN #####
preRunConfig
checkArgs $@
echo "Called: $(printf %q "$BASH_SOURCE")$((($#)) && printf ' %q' "$@")" >> $logFile
echo "Tiff Destination: $tiffDest" >> $logFile

findMRCs
echo "MRC Count: $mrcCount" >> $logFile
createDestDirs
splitMRCList
echo "Part Count: $partCount" >> $logFile

startTime=$(getTimestamp)
convertMRCs
endTime=$(getTimestamp)

writeStats
postRunCleanup

exit 0
