# VLC 2.2.4 on Ubuntu 16.04

Build and set-up a minimal VLC 2.2.4 player on Ubuntu 16.04.1 (desktop;amd64).

## Motivation

VLC requires a lot of 3rd party (contrib) packages. Hence, it is kind of difficult to build and run VLC. There are some vague tutorials, which (in my experience) all fail. At least for the Linux platform. There is neither a _reference_ system for the VLC player. None. For no platform. 

Well, normally, you don't have to deal with such details: There are Linux packages for many distro available; which can be easily installed.

However, if you got a problem and you want to get to the bottom of it, it will become very hard with such a package. The problem may be not reproducibe on other other system since your own installation might be quite unique (since there are so many libraries involved).

This guide shows how to compile a (minimal) VLC system. This includes 3rd party tools and libraries.

Note, there is the Linux-From-Scratch project, which also includes VLC. That's will build a whole Linux distribution from scratch. 

## VLC on Linux

Suprisingly, it is quite difficult to build (compile) VLC. There are lots of required contrib packages. Even though the VLC source includes make-rules for those, the make-rules are destined for static contrib libs: VLC however requires shared libs. Also, make-rules for various contrib packages are missing (most notably Xorg). And there are (a few) faulty make-rules.

Thus, this build will only include the most necessary libraries. So, what does a (basic) video player require? 

A video player (in general) needs (besides the video source): 
- the facilities to display the visual contents, 
- the facilities to play the audio contents, 
- the codec and, 
- optionally, some kind of user-interface to control the video playback.

Linux (Ubuntu) already provides the kernel support and the runtime libraries to display (Xorg/XCB) and to play (ALSA) the video. VLC still needs the definitions (C-headers) to make use of them. You may install related Linux packages (on Ubuntu they have the postfix "devel"). However, here, we use the source tarballs.

In order to decode the video contents, VLC makes use of FFMpeg (and a few more packages). These libraries have to be build before building VLC and to be supplied together with the VLC program (as runtime library).

In order to interact with the video player (i.e. select file, fast forward, etc.) VLC offers several interfaces. Here we use Qt5. The Qt5 package makes up most of the download size and most of the build time. As with the codec, it has to be build before the VLC-build and to be supplied together with VLC (as runtime library).

So, let's have a closer look at VLC. The source tarball contains besides others:
- The _extra/tools/_ directory to download and to build the build-tools. Not all of the tools need to be build since several of them come already with Linux.
- The _contrib/_ directory holds the list of contrib packages to download (see above) and the rules how to build them.
- The _src/_ and _modules/_ directories hold the actual VLC program. The _core_ is given in the _src/_ directory. The _module/_ directory holds the "plugins": VLC provides an architecture to load and execute optional code at will at runtime.

We only use a few plugins in this installation. The names are provided in the configuration process of the VLC program (before the actual build):
- --enable-lua (to prevent VLC from complaining)
- --enable-alsa
- --enable-avcodec (FFMpeg)
- --enable-libxml2 (to prevent VLC from complaining)
- --enable-qt (Qt5)
- --enable-swscale (Xorg)
- --enable-vlc (the actual VLC player)
- --enable-xcb (Xorg)

## VLC Build Instructions

This build regards VLC version 2.2.4 on a fresh Ubuntu (default installation) version 16.04.1 (desktop;amd64). All Ubuntu (auto) updates were disabled.

The build was done and tested in a KVM/QEMU box and also natively.

The build may also succeed on other Debian-based distributions. No efforts were taken to check this, though.

### A temporary directory for our build

```
mkdir build && cd build
ROOT="$PWD"
```

### Get build scripts
```
wget https://github.com/ma16/vlc_ubuntu_build/archive/master.zip
unzip master.zip
mv vlc_ubuntu_build-master ma16
```

### Download all required packages beforehand
```
ma16/download.sh ma16/download.files
```
The size of all the downloads is about 450 megabytes.

### Set up an installation directory
```
sudo mkdir /usr/local_vlc
sudo chown $USER:$USER /usr/local_vlc
```
We need a fixed installation directory. VLC may not work if files are moved to an other location than the installation directory. In this example we use */usr/local_vlc* as target (which installs actually into */usr/local_vlc/x86_64-linux-gnu*).

### Build VLC and contrib packages
On a single 3ghz thread, the build will take about 3hrs, thus, in this example, we let make use 6 threads (on a 4core machine).
```
export MAKEFLAGS="-j6 -O"
ma16/make.sh downloads/ ma16/patches/ /usr/local_vlc/
```

The _make.sh_ script runs the build process in three steps:
* build make-tools
* build contrib packages
* build VLC program

It will be difficult to see what/if something went wrong. So you may want to execute the script manually line-by-line in case of problems.

If everything went fine, you will see some tar files in the installation directory */usr/local_vlc/*:
* alsa.x86_64-linux-gnu.tar
* ffmpeg.x86_64-linux-gnu.tar
* keysyms.x86_64-linux-gnu.tar
* libxml2.x86_64-linux-gnu.tar
* lua.x86_64-linux-gnu.tar
* qt5.x86_64-linux-gnu.tar
* vlc.x86_64-linux-gnu.tar
* xorg.x86_64-linux-gnu.tar

### Install & test
```
cd /usr/local_vlc
rm -fr x86_64-linux-gnu
```
We install the runtime-libraries, and, also the complete devel stuff.
```
for f in ffmpeg qt5 vlc ; do tar xf "$f.x86_64-linux-gnu.tar" ; done
```
The other tar archives were only required for VLC compilation.

We use the intro of the bunny video to test our installation. This should provide video and sound, without any errors on the console.
```
cd "$ROOT"
ma16/test.sh /usr/local_vlc downloads/big_buck_bunny.mp4
```

For the installation we need a little wrapper to set up the _LD_LIBRARAY_PATH_.
```
mv /usr/local_vlc/x86_64-linux-gnu/bin/vlc /usr/local_vlc/x86_64-linux-gnu/bin/vlc.org
cp ma16/wrapper.sh /usr/local_vlc/x86_64-linux-gnu/bin/vlc
```

Let's test again.
```
cp downloads/big_buck_bunny.mp4 ..
cd ..
/usr/local_vlc/x86_64-linux-gnu/bin/vlc big_buck_bunny.mp4
```

Eventually you probably want to get rid of the _build_ directory.
