#!/bin/bash
if [ -z ${LD_LIBRARY_PATH+x} ]; then
  export LD_LIBRARY_PATH=/usr/local_vlc/x86_64-linux-gnu/lib
else
  LD_LIBRARY_PATH=/usr/local_vlc/x86_64-linux-gnu/lib:$LD_LIBRARY_PATH
fi
exec /usr/local_vlc/x86_64-linux-gnu/bin/vlc.org -I "qt4" "$@"
