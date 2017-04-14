#!/bin/bash

if [[ $# -ne 2 ]] ; then
  echo "arguments: install-dir test-movie" 1>&2
  exit -1
fi

INST=$(readlink -f $1)
FILE=$(readlink -f $2)

export LD_LIBRARY_PATH="$INST/x86_64-linux-gnu/lib"
"$INST/x86_64-linux-gnu/bin/vlc" "$FILE"

