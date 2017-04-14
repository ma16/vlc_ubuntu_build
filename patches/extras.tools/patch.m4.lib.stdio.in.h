--- m4/lib/stdio.in.h.org	2017-03-28 10:24:03.894497198 +0200
+++ m4/lib/stdio.in.h	2017-03-28 10:24:08.274543841 +0200
@@ -164,3 +164,5 @@
 #undef gets
+#if HAVE_RAW_DECL_GETS
 _GL_WARN_ON_USE (gets, "gets is a security hole - use fgets instead");
+#endif
 
