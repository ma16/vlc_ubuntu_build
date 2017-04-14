#!/bin/bash

if [[ $# -ne 1 ]] ; then
    echo "arguments: file-list" 1>&2
    exit -1
fi 

INPUT=$1

mkdir -p downloads

cat "$INPUT" | while read MD5 FILE URL
do
    TARGET="downloads/$FILE"
    if [[ -z "$URL" ]] ; then
	echo "$TARGET: no URL"
    else
	if [[ ! -s "$TARGET" ]] ; then
	    rm -f "$TARGET"
	    # ...for zero-size files
	    wget -nv --show-progress -O "$TARGET" "$URL"
	    # ...-c option makes trouble with redirected urls
	fi
	if [[ -s "$TARGET" ]] ; then
	    CK=`md5sum -b "$TARGET" | awk '{print $1}'`
	fi
	if [[ "$CK" != "$MD5" ]] ; then
	    echo "$TARGET: invalid checksum"
	fi
    fi
done
