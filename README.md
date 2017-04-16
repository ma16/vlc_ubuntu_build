= Build and Setup a minimal VLC 2.2.4 player on Ubuntu 16.04.1 (desktop;amd64) =

== Motivation ==

It seems there exists no "reference" system for the VLC player. None. For no platform. There are some vague tutorials, which -- in my experience --- all fail. At least for the Linux platform.

Well, there is the Linux From Scratch project, which also includes VLC. But I didn't want to start from scratch. There are also the the Linux packages (for the distro of your choice). However, I wanted to control the related (VLC) contrib packages on my own. The Linux packages use a shared library approach, which make it difficult to isolate defects. So, what I searched for, was a VLC setup to play videos, to monitor defects and to make little changes to, in order to deal with defects.

Suprisingly, it is quite difficult to build (compile) VLC. There are lots of required contrib packages. Even tough the VLC source includes make-rules for those, the make-rules are destined for static contrib libs: VLC however requires shared libs. Also, make-rules for various contrib packages are missing (most notably Xorg). And there are (a few) faulty make-rules.

At this point I want to make clear that I like VLC. The people who develop VLC made it possible to run VLC on many different platforms. So it is admittedly quite hard to provide reliable instructions to build VLC on each of these (and their flavours and current versions).

== VLC on Linux ==

This is just to remind, what a (basic) video player does. 

A video player (in general) needs (besides the video source): the facilities to display the visual contents, the facilities to play the audio contents, the codec and, optionally, some kind of interaction to control the video playback.

Linux (Ubuntu) already provides the kernel support and the runtime libraries to display (Xorg/XCB) and to play (ALSA) the video. VLC still needs the definitions (C-headers) to make use of them. You may install related Linux packages (on Ubuntu they have the postfix "devel"). However, here, we use the source tarballs.

In order to decode the video contents, VLC makes use of FFMpeg (and a few more packages). These libraries have to be build before building VLC and to be supplied together with the VLC program (as runtime library).

In order to interact with the video player (i.e. select file, fast forward, etc.) VLC offers several interfaces. Here we use Qt5. The Qt5 package makes up most of the download size and most of the build time. As with the codec, it has to be build before the VLC-build and to be supplied together with VLC (as runtime library).

So, let's have a closer look at VLC. The source tarball contains besides others:

* The extra/tools/ directory to download and to build the build-tools. Not all of the tools need to be build since several of them come already with Linux.
* The contrib/ directory holds the list of contrib packages (see above) to download and the rules how to build them.
* The src/ and modules/ directories hold the actual VLC program. The "core" is given in the src/ directory. The module/ directory holds the "plugins": VLC provides an architecture to load and execute optional code at will at runtime.

We only use a few plugins in this installation. The names are provided in the configuration process of the VLC program (before the actual build):
* --enable-lua (to prevent VLC from complaining)
* --enable-alsa
* --enable-avcodec (FFMpeg)
* --enable-libxml2 (to prevent VLC from complaining)
* --enable-qt (Qt5)
* --enable-swscale (Xorg)
* --enable-vlc (the actual VLC player)
* --enable-xcb (Xorg)

== VLC Build Instructions ==

This build regards VLC version 2.2.4 on a fresh Ubuntu (default installation) version 16.04.1 (desktop;amd64). All Ubuntu (auto) updates were disabled.

The build was run (tested) in a KVM/QEMU box and also natively.

The build may also succeed on other Debian-based distributions. Though no efforts were taken to check this.

# temporary directory for our build
mkdir build && cd build
ROOT="$PWD"

# get build scripts
wget https://github.com/ma16/vlc_ubuntu_build/archive/master.zip
unzip master.zip
mv vlc_ubuntu_build-master ma16

# download all required packages beforehand
ma16/download.sh ma16/download.files
# ...the size of all the downloads is about 450 megabytes

# set up an installation directory
sudo mkdir /usr/local_vlc
sudo chown $USER:$USER /usr/local_vlc
# we need a fixed installation directory. VLC may not work if files are
# moved to an other location than the installation directory. In this
# example we use /usr/local_vlc as target (which installs actually into
# /usr/local_vlc/x86_64-linux-gnu).

# build VLC and contrib packages
export MAKEFLAGS="-j6 -O"
# ...on a single ~3ghz thread, the build will take about 3hrs, thus,
# in this example, we let make use 6 threads (on a 4core machine)
ma16/make.sh downloads/ ma16/patches/ /usr/local_vlc/

# the "make.sh" script runs the build process in three steps:
#   * build make-tools
#   * build contrib packages
#   * build VLC program
# it will be difficult to see what/if something went wrong. so you may
# want to execute the script manually line-by-line in case of problems.
#
# if everything went fine, you will get some tar files in the
# installation directory /usr/local_vlc
#   * alsa.x86_64-linux-gnu.tar
#   * ffmpeg.x86_64-linux-gnu.tar
#   * keysyms.x86_64-linux-gnu.tar
#   * libxml2.x86_64-linux-gnu.tar
#   * lua.x86_64-linux-gnu.tar
#   * qt5.x86_64-linux-gnu.tar
#   * vlc.x86_64-linux-gnu.tar
#   * xorg.x86_64-linux-gnu.tar

# install & test
cd /usr/local_vlc
rm -fr x86_64-linux-gnu
# runtime-libraries (actually also the complete devel stuff)
for f in ffmpeg qt5 vlc ; do tar xf "$f.x86_64-linux-gnu.tar" ; done
# ...the other tar archives are only required for VLC compilation
cd "$ROOT"
ma16/test.sh /usr/local_vlc downloads/big_buck_bunny.mp4
# ...this should provide video and sound, without any errors on the console
mv /usr/local_vlc/x86_64-linux-gnu/bin/vlc /usr/local_vlc/x86_64-linux-gnu/bin/vlc.org
cp ma16/downloads/wrapper.sh /usr/local_vlc/x86_64-linux-gnu/bin/vlc
/usr/local_vlc/x86_64-linux-gnu/bin/vlc downloads/big_buck_bunny.mp4
# if successful, you can remove the build directory
