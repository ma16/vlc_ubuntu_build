--- tools.mak.org	2017-03-28 09:18:59.037594078 +0200
+++ tools.mak	2017-03-28 10:05:55.707275999 +0200
@@ -12,2 +12,4 @@
 export AUTOCONF
+PATH:=$(PATH):$(PREFIX)/bin
+export PATH
 
@@ -86,3 +88,3 @@
 
-.libtool: libtool .automake
+.libtool: libtool .automake .m4
 	(cd $<; ./configure --prefix=$(PREFIX) && $(MAKE) && $(MAKE) install)
@@ -139,3 +141,4 @@
 
-.autoconf: autoconf .pkg-config
+.autoconf: autoconf .pkg-config .m4
+	echo $(PATH)
 	(cd $<; ./configure --prefix=$(PREFIX) && $(MAKE) && $(MAKE) install)
@@ -156,3 +159,3 @@
 
-.automake: automake .autoconf
+.automake: automake .autoconf .m4
 	(cd $<; ./configure --prefix=$(PREFIX) && $(MAKE) && $(MAKE) install)
