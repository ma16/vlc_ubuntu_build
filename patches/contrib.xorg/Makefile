CONFIG=$(PREFIX)/lib/pkgconfig:$(PREFIX)/share/pkgconfig

all: .build/.xorg

# (1) unpack tarball

.unpacked/.%: $(DOWNLOADS)/%.tar.bz2
	rm -fr $@ $(@:.unpacked/.%=unpacked/%) && mkdir -p .unpacked && \
	cd .unpacked && tar xf $(DOWNLOADS)/$(@:.unpacked/.%=%.tar.bz2) && \
	cd .. && touch $@

.unpacked/.%: $(DOWNLOADS)/%.tar.gz
	rm -fr $@ $(@:.unpacked/.%=unpacked/%) && mkdir -p .unpacked && \
	cd .unpacked && tar xf $(DOWNLOADS)/$(@:.unpacked/.%=%.tar.gz) && \
	cd .. && touch $@

# (2) patch if necessary...

.patched/.freetype-2.7.1: .patched/.freetype-2.7.1.copy
	rm -f $@ && \
	cd $(@:.patched/.%=.patched/%) && \
	sed -ri "s:.*(AUX_MODULES.*valid):\1:" modules.cfg && \
	sed -r "s:.*(#.*SUBPIXEL_RENDERING) .*:\1:" -i include/freetype/config/ftoption.h && \
	cd ../.. && touch $@

.patched/.libxcb-1.12: .patched/.libxcb-1.12.copy
	rm -f $@ && \
	cd $(@:.patched/.%=.patched/%) && \
	sed -i "s/pthread-stubs//" configure && \
	cd ../.. && touch $@

.patched/.xcb-proto-1.12: .patched/.xcb-proto-1.12.copy $(DOWNLOADS)/xcb-proto-1.12-schema-1.patch
	rm -f $@ && \
	cd $(@:.patched/.%=.patched/%) && \
	patch -Np1 -i $(DOWNLOADS)/xcb-proto-1.12-schema-1.patch && \
	cd ../.. && touch $@

# ... or don't patch

.patched/.%: .patched/.%.copy
	touch $@

.patched/.%.copy: .unpacked/.%
	rm -fr $@ $(@:.patched/.%.copy=.patched/%) && mkdir -p .patched && \
	cp -a $(@:.patched/.%.copy=.unpacked/%) $(@:.patched/.%.copy=.patched/%) && touch $@

# (3) dependencies

XORG=	.build/.xtrans-1.3.5 \
	.build/.libX11-1.6.4 \
	.build/.libXext-1.3.3 \
	.build/.libFS-1.0.7 \
	.build/.libICE-1.0.9 \
	.build/.libSM-1.2.2 \
        .build/.libXScrnSaver-1.2.2 \
	.build/.libXt-1.1.5 \
	.build/.libXmu-1.1.2 \
	.build/.libXpm-3.5.12 \
	.build/.libXaw-1.0.13 \
        .build/.libXfixes-5.0.3 \
	.build/.libXcomposite-0.4.4 \
	.build/.libXrender-0.9.10 \
	.build/.libXcursor-1.1.14 \
	.build/.libXdamage-1.1.4 \
        .build/.libfontenc-1.1.3 \
	.build/.libXfont2-2.0.1 \
	.build/.libXft-2.3.2 \
	.build/.libXi-1.7.9 \
	.build/.libXinerama-1.1.3 \
        .build/.libXrandr-1.5.1 \
	.build/.libXres-1.0.7 \
	.build/.libXtst-1.2.3 \
	.build/.libXv-1.0.11 \
	.build/.libXvMC-1.0.10 \
	.build/.libXxf86dga-1.1.4 \
        .build/.libXxf86vm-1.1.4 \
	.build/.libdmx-1.1.3 \
	.build/.libpciaccess-0.13.4 \
	.build/.libxkbfile-1.0.9 \
	.build/.libxshmfence-1.2

# todo: cannot be done in parallel, dependencies within

XPROTODEP=\
	.build/.bigreqsproto-1.1.2 \
	.build/.compositeproto-0.4.2 \
	.build/.damageproto-1.2.1 \
	.build/.dmxproto-2.3.1 \
        .build/.dri2proto-2.8 \
	.build/.dri3proto-1.0 \
	.build/.fixesproto-5.0 \
	.build/.fontsproto-2.1.3 \
	.build/.glproto-1.4.17 \
        .build/.inputproto-2.3.2 \
	.build/.kbproto-1.0.7 \
	.build/.presentproto-1.1 \
	.build/.randrproto-1.5.0 \
	.build/.recordproto-1.14.2 \
        .build/.renderproto-0.11.1 \
	.build/.resourceproto-1.2.0 \
	.build/.scrnsaverproto-1.2.2 \
	.build/.videoproto-2.3.3 \
        .build/.xcmiscproto-1.2.2 \
	.build/.xextproto-7.3.0 \
	.build/.xf86bigfontproto-1.2.0 \
	.build/.xf86dgaproto-2.1 \
        .build/.xf86driproto-2.1.1 \
	.build/.xf86vidmodeproto-2.3.1 \
	.build/.xineramaproto-1.2.1

.build/.fontconfig-2.12.1: .build/.expat-2.1.0 .build/.freetype-2.7.1

.build/.libfontenc-1.1.3: .build/.zlib-1.2.8

.build/.libXau-1.0.8: .build/.xproto-7.0.31

.build/.libxcb-1.12: .build/.libXau-1.0.8 .build/.xcb-proto-1.12

$(XORG): .build/.fontconfig-2.12.1 .build/.libxcb-1.12 .build/.zlib-1.2.8 .build/.util-macros-1.19.1 .build/.xproto-7.0.31

.build/.xorg: $(XORG)

$(XPROTODEP): .build/.util-macros-1.19.1

.build/.xproto-7.0.31: $(XPROTODEP)

# (4) actual build

.build/.zlib-1.2.8: .patched/.zlib-1.2.8
	rm -fr $@ $(@:.build/.%=.build/%) && \
	mkdir -p .build && \
	cp -a $(@:.build/.%=.patched/%) $(@:.build/.%=.build/%) && \
	cd $(@:.build/.%=.build/%) && \
	./configure --prefix=$(PREFIX) && \
	make install && cd ../.. && touch $@

.build/.%: .patched/.%
	rm -fr $@ $(@:.build/.%=.build/%) && \
	mkdir -p .build && \
	cp -a $(@:.build/.%=.patched/%) $(@:.build/.%=.build/%) && \
	cd $(@:.build/.%=.build/%) && \
	./configure --prefix=$(PREFIX) PKG_CONFIG_PATH="$(CONFIG)" CFLAGS="-I$(PREFIX)/include" LDFLAGS="-L$(PREFIX)/lib" && \
	make install && cd ../.. && touch $@

# --disable-static ?!

