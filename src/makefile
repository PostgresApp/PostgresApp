# VERSION numbers

# http://postgis.net/source/
POSTGIS_VERSION=2.2.2
POSTGIS_MAJOR_VERSION=2.2

POSTGRES_VERSION=9.6beta1
POSTGRES_MAJOR_VERSION=9.6

# http://trac.osgeo.org/gdal/wiki/DownloadSource
GDAL_VERSION=1.11.4

# http://trac.osgeo.org/geos/
GEOS_VERSION=3.5.0

JPEG_VERSION=8d
LIBEDIT_VERSION=20130611-3.1

#http://download.osgeo.org/gdal/
LIBJASPER_VERSION=1.900.1

# http://xmlsoft.org/news.html
LIBXML2_VERSION=2.9.3

# https://www.openssl.org
OPENSSL_VERSION=1.0.1t

# http://proj4.org/download.html
PROJ_VERSION=4.9.2
DATUMGRID_VERSION=1.5

#see http://omahaproxy.appspot.com for latest stable v8 version
V8_VERSION=3.18

# https://github.com/plv8/plv8/releases
PLV8_VERSION=1.4.8

# https://github.com/json-c/json-c/wiki
# https://s3.amazonaws.com/json-c_releases/releases/index.html
JSONC_VERSION=0.11

# http://www.remotesensing.org/libtiff/
LIBTIFF_VERSION=4.0.6


# path configuration
PREFIX=/Applications/Postgres.app/Contents/Versions/$(POSTGRES_MAJOR_VERSION)
SHAREDPREFIX=/Applications/Postgres.app/Contents/Versions/shared
PATH=$(PREFIX)/bin:/bin:/usr/bin:/opt/local/bin

#compiler options
MACOSX_DEPLOYMENT_TARGET=10.7
CFLAGS:=$(CFLAGS) -mmacosx-version-min=10.7
CXXFLAGS:=$(CFLAGS) -mmacosx-version-min=10.7

export CFLAGS CXXFLAGS MACOSX_DEPLOYMENT_TARGET

# commands used for downloading and extracting sources
CURL=/usr/bin/curl -L10 --silent --show-error --remote-name
TAR=/usr/bin/tar xzf

all: postgresql postgis
#all: postgresql postgis plv8
clean: clean-postgresql clean-openssl clean-libxml2 clean-libgdal clean-libproj clean-postgis clean-plv8 clean-libjpeg clean-libjasper clean-libgeos clean-libtiff clean-json-c

#########################
###### PostgreSQL #######
#########################

postgresql: $(PREFIX)/bin/psql

$(PREFIX)/bin/psql: postgresql-$(POSTGRES_VERSION)/GNUmakefile
	make -C "postgresql-$(POSTGRES_VERSION)" all contrib
	make -C "postgresql-$(POSTGRES_VERSION)" install
	
# setting PATH is to make sure we find the right xml2-config
# the --with-includes and --with-libraries options are necessary so
# that postgres will be compiled and linked against our own versions
# of libraries like openssl, instead of system provided versions
postgresql-$(POSTGRES_VERSION)/GNUmakefile: $(SHAREDPREFIX)/lib/libssl.dylib $(SHAREDPREFIX)/lib/libxml2.dylib postgresql-$(POSTGRES_VERSION)/configure 
	cd "postgresql-$(POSTGRES_VERSION)" && export PATH="$(PREFIX)/bin:$$PATH" && ./configure --prefix="$(PREFIX)" --with-includes="$(SHAREDPREFIX)/include" --with-libraries="$(SHAREDPREFIX)/lib" --enable-thread-safety --with-openssl --with-gssapi --with-bonjour --with-libxml --with-libxslt --with-perl --with-python --with-readline --with-uuid=e2fs
# patch makefile to fix python linker flags
	cd postgresql-$(POSTGRES_VERSION)/src; mv Makefile.global Makefile.global.old; sed 's@^python_libspec.*@python_libspec = '"`python-config --ldflags`"'@' Makefile.global.old >Makefile.global

postgresql-$(POSTGRES_VERSION)/configure: postgresql-$(POSTGRES_VERSION).tar.bz2
	$(TAR) "postgresql-$(POSTGRES_VERSION).tar.bz2"
	touch $@

postgresql-$(POSTGRES_VERSION).tar.bz2:	
	$(CURL) "https://ftp.postgresql.org/pub/source/v$(POSTGRES_VERSION)/postgresql-$(POSTGRES_VERSION).tar.bz2"

clean-postgresql:
	rm -Rf postgresql-$(POSTGRES_VERSION)
	
		
#########################
####### OpenSSL #########
#########################

openssl: $(SHAREDPREFIX)/lib/libssl.dylib

$(SHAREDPREFIX)/lib/libssl.dylib: openssl-${OPENSSL_VERSION}/Makefile
	make -C openssl-${OPENSSL_VERSION}
	make -C openssl-${OPENSSL_VERSION} install_sw

openssl-${OPENSSL_VERSION}/Makefile: openssl-${OPENSSL_VERSION}/Configure
	cd openssl-${OPENSSL_VERSION} && ./Configure --prefix="${SHAREDPREFIX}" darwin64-x86_64-cc zlib no-asm no-krb5 shared

openssl-${OPENSSL_VERSION}/Configure: openssl-${OPENSSL_VERSION}.tar.gz
	$(TAR) openssl-${OPENSSL_VERSION}.tar.gz
	touch $@

openssl-${OPENSSL_VERSION}.tar.gz:
	$(CURL) "https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz"
	
clean-openssl:
	rm -Rf "openssl-${OPENSSL_VERSION}"

#########################
######## LibXML2 ########
#########################

libxml2: $(SHAREDPREFIX)/lib/libxml2.dylib

$(SHAREDPREFIX)/lib/libxml2.dylib: libxml2-${LIBXML2_VERSION}/Makefile
	make -C libxml2-${LIBXML2_VERSION} install-exec
	make -C libxml2-${LIBXML2_VERSION}/include install
	touch $(SHAREDPREFIX)/lib/libxml2.dylib

libxml2-${LIBXML2_VERSION}/Makefile: libxml2-${LIBXML2_VERSION}/configure
	cd libxml2-${LIBXML2_VERSION} && ./configure --prefix="$(SHAREDPREFIX)" --disable-dependency-tracking

libxml2-${LIBXML2_VERSION}/configure: libxml2-${LIBXML2_VERSION}.tar.gz
	$(TAR) libxml2-${LIBXML2_VERSION}.tar.gz
	touch $@
	
libxml2-${LIBXML2_VERSION}.tar.gz:
	$(CURL) "ftp://xmlsoft.org/libxml2/libxml2-${LIBXML2_VERSION}.tar.gz"
	
clean-libxml2:
	rm -Rf "libxml2-$(LIBXML2_VERSION)"

#########################
####### LibEdit #########
#########################

libedit: $(SHAREDPREFIX)/lib/libedit.dylib

$(SHAREDPREFIX)/lib/libedit.dylib: libedit-$(LIBEDIT_VERSION)/Makefile
	make -C "libedit-$(LIBEDIT_VERSION)" install

libedit-$(LIBEDIT_VERSION)/Makefile: libedit-$(LIBEDIT_VERSION)/configure
	cd libedit-$(LIBEDIT_VERSION) && ./configure --prefix="$(SHAREDPREFIX)"

libedit-$(LIBEDIT_VERSION)/configure: libedit-$(LIBEDIT_VERSION).tar.gz
	$(TAR) "libedit-${LIBEDIT_VERSION}.tar.gz"
	touch $@

libedit-$(LIBEDIT_VERSION).tar.gz:
	$(CURL) "http://www.thrysoee.dk/editline/libedit-$(LIBEDIT_VERSION).tar.gz"

clean-libedit:
	rm -Rf "libedit-$(LIBEDIT_VERSION)"


#########################
####### LibJasper #######
#########################

libjasper: $(SHAREDPREFIX)/lib/libjasper.dylib

$(SHAREDPREFIX)/lib/libjasper.dylib: jasper-${LIBJASPER_VERSION}.uuid/Makefile
	make -C jasper-${LIBJASPER_VERSION}.uuid install

jasper-${LIBJASPER_VERSION}.uuid/Makefile: jasper-${LIBJASPER_VERSION}.uuid/configure
	cd jasper-${LIBJASPER_VERSION}.uuid && ./configure --prefix="$(SHAREDPREFIX)" --disable-debug --disable-dependency-tracking --enable-shared --enable-dynamic


jasper-${LIBJASPER_VERSION}.uuid/configure: jasper-$(LIBJASPER_VERSION).uuid.tar.gz
	$(TAR) "jasper-$(LIBJASPER_VERSION).uuid.tar.gz"
	touch $@

jasper-$(LIBJASPER_VERSION).uuid.tar.gz:
	$(CURL) "http://download.osgeo.org/gdal/jasper-$(LIBJASPER_VERSION).uuid.tar.gz"

clean-libjasper:
	rm -Rf jasper-${LIBJASPER_VERSION}.uuid


#########################
#######  libjpeg  #######
#########################

libjpeg: $(SHAREDPREFIX)/lib/libjpeg.dylib

$(SHAREDPREFIX)/lib/libjpeg.dylib: jpeg-$(JPEG_VERSION)/Makefile
	make -C jpeg-$(JPEG_VERSION) install

jpeg-$(JPEG_VERSION)/Makefile: jpeg-$(JPEG_VERSION)/configure
	cd jpeg-$(JPEG_VERSION) && ./configure --prefix="$(SHAREDPREFIX)" --disable-dependency-tracking

jpeg-$(JPEG_VERSION)/configure: jpegsrc.v$(JPEG_VERSION).tar.gz
	$(TAR) jpegsrc.v$(JPEG_VERSION).tar.gz
	touch $@

jpegsrc.v$(JPEG_VERSION).tar.gz:
	$(CURL) "http://www.ijg.org/files/jpegsrc.v$(JPEG_VERSION).tar.gz"

clean-libjpeg:
	rm -Rf jpeg-$(JPEG_VERSION)

#########################
#######  libgeos  #######
#########################

# Depends on postgresql

libgeos: $(SHAREDPREFIX)/lib/libgeos.dylib

$(SHAREDPREFIX)/lib/libgeos.dylib: geos-${GEOS_VERSION}/Makefile
	make -C geos-${GEOS_VERSION} install

geos-${GEOS_VERSION}/Makefile: geos-${GEOS_VERSION}/configure $(PREFIX)/bin/psql
	cd geos-${GEOS_VERSION} && ./configure --prefix="$(SHAREDPREFIX)"

#geos needs to be patched
geos-${GEOS_VERSION}/configure: geos-${GEOS_VERSION}.tar.bz2
	$(TAR) geos-${GEOS_VERSION}.tar.bz2
	/usr/bin/sed -i -e 's/@CFLAGS@$$/@CFLAGS@ -O1/g' geos-${GEOS_VERSION}/src/geom/Makefile.in
	/usr/bin/sed -i -e 's/@CXXFLAGS@$$/@CXXFLAGS@ -O1/g' geos-${GEOS_VERSION}/src/geom/Makefile.in
	touch $@

geos-${GEOS_VERSION}.tar.bz2:
	$(CURL) "http://download.osgeo.org/geos/geos-${GEOS_VERSION}.tar.bz2"

clean-libgeos:
	rm -Rf geos-${GEOS_VERSION}

#########################
#######  libgdal  #######
#########################

# Depends on libproj, libjasper, postgresql, libjpeg, libtiff

libgdal: $(SHAREDPREFIX)/lib/libgdal.dylib

$(SHAREDPREFIX)/lib/libgdal.dylib: gdal-$(GDAL_VERSION)/GNUMakefile
	make -C gdal-$(GDAL_VERSION) install

gdal-$(GDAL_VERSION)/GNUMakefile: gdal-$(GDAL_VERSION)/autogen.sh  $(SHAREDPREFIX)/include/json/json_object_iterator.h $(SHAREDPREFIX)/lib/libproj.dylib $(SHAREDPREFIX)/lib/libjasper.dylib  $(SHAREDPREFIX)/lib/libjpeg.dylib $(PREFIX)/bin/psql $(SHAREDPREFIX)/lib/libtiff.dylib
	cd gdal-$(GDAL_VERSION) && ./autogen.sh && ./configure --prefix="$(PREFIX)" --with-pg="$(PREFIX)/bin/pg_config"  --with-jpeg="$(SHAREDPREFIX)" --with-jasper="$(SHAREDPREFIX)" --with-libjson-c="$(SHAREDPREFIX)" --with-static-proj4="$(PWD)/proj-$(PROJ_VERSION)/src/.libs"
	touch $@

gdal-$(GDAL_VERSION)/autogen.sh: gdal-${GDAL_VERSION}.tar.gz
	$(TAR) gdal-${GDAL_VERSION}.tar.gz
	touch $@	

gdal-${GDAL_VERSION}.tar.gz:
	$(CURL) "http://download.osgeo.org/gdal/${GDAL_VERSION}/gdal-${GDAL_VERSION}.tar.gz"

clean-libgdal:
	rm -Rf gdal-$(GDAL_VERSION)


#########################
###### proj4 ############
#########################

# Depends on postgresql

libproj: $(SHAREDPREFIX)/lib/libproj.dylib

$(SHAREDPREFIX)/lib/libproj.dylib: proj-$(PROJ_VERSION)/Makefile
	make -C proj-$(PROJ_VERSION) install

proj-$(PROJ_VERSION)/Makefile: proj-$(PROJ_VERSION)/configure $(PREFIX)/bin/psql
	cd proj-$(PROJ_VERSION) && ./configure --prefix="$(SHAREDPREFIX)"

proj-${PROJ_VERSION}/configure: proj-${PROJ_VERSION}.tar.gz proj-datumgrid-$(DATUMGRID_VERSION).zip
	$(TAR) "proj-${PROJ_VERSION}.tar.gz"
	unzip -o "proj-datumgrid-${DATUMGRID_VERSION}.zip" -d "./proj-${PROJ_VERSION}/nad"
	touch $@

proj-${PROJ_VERSION}.tar.gz:
	$(CURL) "http://download.osgeo.org/proj/proj-${PROJ_VERSION}.tar.gz"

proj-datumgrid-${DATUMGRID_VERSION}.zip:
	$(CURL) "http://download.osgeo.org/proj/proj-datumgrid-${DATUMGRID_VERSION}.zip"
	
clean-libproj:
	rm -Rf proj-${PROJ_VERSION}



#########################
###### JSON-c ###########
#########################

$(SHAREDPREFIX)/include/json/json_object_iterator.h: json-c-$(JSONC_VERSION)/Makefile
	make -C json-c-$(JSONC_VERSION) install
	cp json-c-$(JSONC_VERSION)/json_object_iterator.h "$(SHAREDPREFIX)/include/json/json_object_iterator.h"


json-c-$(JSONC_VERSION)/Makefile: json-c-$(JSONC_VERSION)/configure
	cd json-c-$(JSONC_VERSION) && ./configure --prefix="$(SHAREDPREFIX)"

json-c-$(JSONC_VERSION)/configure: json-c-$(JSONC_VERSION).tar.gz
	$(TAR) json-c-$(JSONC_VERSION).tar.gz
	touch $@

json-c-$(JSONC_VERSION).tar.gz:
	$(CURL) "https://s3.amazonaws.com/json-c_releases/releases/json-c-$(JSONC_VERSION).tar.gz"

clean-json-c:
	rm -Rf json-c-$(JSONC_VERSION)


#########################
####### libtiff #########
#########################

libtiff: $(SHAREDPREFIX)/lib/libtiff.dylib

$(SHAREDPREFIX)/lib/libtiff.dylib: tiff-$(LIBTIFF_VERSION)/Makefile
	make -C tiff-$(LIBTIFF_VERSION) install

tiff-$(LIBTIFF_VERSION)/Makefile: tiff-$(LIBTIFF_VERSION)/configure
	cd tiff-$(LIBTIFF_VERSION) && ./configure --prefix="$(SHAREDPREFIX)" --disable-dependency-tracking

tiff-$(LIBTIFF_VERSION)/configure: tiff-$(LIBTIFF_VERSION).tar.gz
	$(TAR) tiff-$(LIBTIFF_VERSION).tar.gz
	touch $@

tiff-$(LIBTIFF_VERSION).tar.gz:
	$(CURL) ftp://ftp.remotesensing.org/pub/libtiff/tiff-$(LIBTIFF_VERSION).tar.gz

clean-libtiff:
	rm -Rf tiff-$(LIBTIFF_VERSION)

#########################
###### PostGIS ##########
#########################

#depends on libgdal, libgeos, libjpeg, postgresql, jsonc

postgis: $(PREFIX)/lib/postgresql/postgis-$(POSTGIS_MAJOR_VERSION).so $(SHAREDPREFIX)/lib/liblwgeom.dylib

$(SHAREDPREFIX)/lib/liblwgeom.dylib: postgis-${POSTGIS_VERSION}/GNUMakefile $(PREFIX)/lib/postgresql/postgis-$(POSTGIS_MAJOR_VERSION).so
	make -C postgis-${POSTGIS_VERSION}/liblwgeom
	make -C postgis-${POSTGIS_VERSION}/liblwgeom install

$(PREFIX)/lib/postgresql/postgis-$(POSTGIS_MAJOR_VERSION).so: postgis-${POSTGIS_VERSION}/GNUMakefile
	make -C postgis-${POSTGIS_VERSION}
	make -C postgis-${POSTGIS_VERSION} install

postgis-${POSTGIS_VERSION}/GNUMakefile: postgis-${POSTGIS_VERSION}/autogen.sh $(SHAREDPREFIX)/lib/libgdal.dylib $(SHAREDPREFIX)/lib/libgeos.dylib $(SHAREDPREFIX)/lib/libjpeg.dylib $(PREFIX)/bin/psql $(SHAREDPREFIX)/include/json/json_object_iterator.h
	cd postgis-${POSTGIS_VERSION} && ./autogen.sh && ./configure --prefix="$(SHAREDPREFIX)" --with-pgconfig="$(PREFIX)/bin/pg_config" --with-geosconfig="$(SHAREDPREFIX)/bin/geos-config" --with-projdir="$(SHAREDPREFIX)" --with-gdaldir="$(SHAREDPREFIX)" --with-jsondir="$(SHAREDPREFIX)"
	/usr/bin/sed -i -e 's#/usr/local$$#"$(PREFIX)"#g' postgis-${POSTGIS_VERSION}/liblwgeom/Makefile
	touch $@

postgis-${POSTGIS_VERSION}/autogen.sh: postgis-${POSTGIS_VERSION}.tar.gz
	$(TAR) $<
	touch $@

postgis-${POSTGIS_VERSION}.tar.gz:
	$(CURL) "http://download.osgeo.org/postgis/source/postgis-${POSTGIS_VERSION}.tar.gz"

clean-postgis:
	rm -Rf postgis-${POSTGIS_VERSION}


##########################
######## PLV8 ############
##########################

plv8: $(SHAREDPREFIX)/lib/postgresql/plv8.so

$(SHAREDPREFIX)/lib/postgresql/plv8.so: plv8-${PLV8_VERSION}/Makefile $(SHAREDPREFIX)/lib/libv8.dylib
	export PGHOME="$(SHAREDPREFIX)"; export CC=clang; export CXX=clang++; export V8_SRCDIR="$(CURDIR)/v8-${V8_VERSION}"; make -C plv8-${PLV8_VERSION} install 
#	/usr/bin/install_name_tool -change "/usr/local/lib/libv8.dylib" "$(SHAREDPREFIX)/lib/libv8.dylib" "$(SHAREDPREFIX)/lib/postgresql/plv8.so"


plv8-${PLV8_VERSION}/Makefile: plv8-${PLV8_VERSION}.tar.gz
	$(TAR) $<
	touch $@
	
plv8-${PLV8_VERSION}.tar.gz:
	/usr/bin/curl -L10 --silent --show-error -o $@ https://github.com/plv8/plv8/archive/v${PLV8_VERSION}.tar.gz

# Unfortunately, plv8 only builds with outdated v8, but outdated v8 no longer builds with recent clang
# As a workaround, we include libv8 binary built with older clang in repository
#
#$(SHAREDPREFIX)/lib/libv8.dylib: v8-${V8_VERSION}/out/x64.release/libv8.dylib
#	cp v8-${V8_VERSION}/out/x64.release/libv8.dylib $(SHAREDPREFIX)/lib/libv8.dylib
#	/usr/bin/install_name_tool -id "$(SHAREDPREFIX)/lib/libv8.dylib" "$(SHAREDPREFIX)/lib/libv8.dylib"
#
#v8-${V8_VERSION}/out/x64.release/libv8.dylib: v8-${V8_VERSION}/Makefile
#	export CC=clang; export CXX=clang++; export GYP_DEFINES="clang=1"; make -C v8-${V8_VERSION} dependencies
#	export CC=clang; export CXX=clang++; export GYP_DEFINES="clang=1"; export DYLD_LIBRARY_PATH=$(CURDIR)/v8-${V8_VERSION}/out/x64.release; make -C v8-${V8_VERSION} library=shared werror=no x64.release

$(SHAREDPREFIX)/lib/libv8.dylib: v8-${V8_VERSION}/Makefile
	cp bin/libv8.dylib $(SHAREDPREFIX)/lib/libv8.dylib

v8-${V8_VERSION}/Makefile:
	svn export --force "http://v8.googlecode.com/svn/branches/$(V8_VERSION)/" "v8-$(V8_VERSION)"
	touch $@

clean-plv8:
	rm -Rf plv8js v8-${V8_VERSION} plv8-${PLV8_VERSION}
