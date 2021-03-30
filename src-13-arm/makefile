# VERSION numbers

# http://postgis.net/source/
POSTGIS_VERSION=3.1.1
POSTGIS_MAJOR_VERSION=3.1

POSTGRES_VERSION=13.2
POSTGRES_MAJOR_VERSION=13
POSTGRES_DOWNLOAD_URL=https://ftp.postgresql.org/pub/source/v$(POSTGRES_VERSION)

POSTGRESAPP_VERSION=$(POSTGRES_VERSION)

# https://github.com/OSGeo/gdal/releases
# http://download.osgeo.org/gdal/
GDAL_VERSION=3.1.4

# http://trac.osgeo.org/geos/
GEOS_VERSION=3.8.1

JPEG_VERSION=9c
LIBEDIT_VERSION=20130611-3.1

#http://download.osgeo.org/gdal/
LIBJASPER_VERSION=1.900.1

# ftp://xmlsoft.org/libxml2/
LIBXML2_VERSION=2.9.10

# https://www.openssl.org
OPENSSL_VERSION=1.1.1i

# http://proj4.org/download.html
PROJ_VERSION=7.1.1
DATUMGRID_VERSION=1.8

# https://github.com/plv8/plv8/releases
PLV8_VERSION=2.3.15

# https://github.com/json-c/json-c/wiki
# https://s3.amazonaws.com/json-c_releases/releases/index.html
JSONC_VERSION=0.13.1

# https://github.com/eulerto/wal2json/releases
WAL2JSON_VERSION=wal2json_2_3

# https://github.com/protocolbuffers/protobuf/releases
PROTOBUF_VERSION=3.14.0

# https://github.com/protobuf-c/protobuf-c/releases
PROTOBUFC_VERSION=1.3.3

# http://simplesystems.org/libtiff/
LIBTIFF_VERSION=4.2.0

# http://site.icu-project.org/download/
ICU_MAJOR_VERSION=67
ICU_MINOR_VERSION=1

PYTHON_VERSION=3.9

#path configuration
BUILD_PREFIX=$(shell pwd)/build
PREFIX=/Applications/Postgres.app/Contents/Versions/$(POSTGRES_MAJOR_VERSION)-arm
PATH=$(PREFIX)/bin:/bin:/usr/bin:/opt/local/bin
PKG_CONFIG_LIBDIR=$(PREFIX)/lib/pkgconfig

export PATH PKG_CONFIG_LIBDIR

#python config
PYTHON=/Library/Frameworks/Python.framework/Versions/$(PYTHON_VERSION)/bin/python3
export PYTHON

#compiler options
MACOSX_DEPLOYMENT_TARGET=10.12
CFLAGS:=$(CFLAGS) -mmacosx-version-min=10.12
CXXFLAGS:=$(CFLAGS) -mmacosx-version-min=10.12
ICU_LIBS=-licui18n -licuuc
ICU_CFLAGS=-I$(PREFIX)/share/icu

XCODE_PROJECT_FILE=$(CURDIR)/../Postgres.xcodeproj
EXPORT_ARCHIVE_PATH=~/Documents/postgresapp-archives/$(POSTGRESAPP_VERSION)

PROTOC=$(BUILD_PREFIX)/bin/protoc
protobuf_CFLAGS=-I$(BUILD_PREFIX)/include -pthread
protobuf_LIBS=-L$(BUILD_PREFIX)/lib -lprotobuf -pthread

# For some reason PostgreSQL could no longer find DTDs when building docs
# This change fixes that issue. It doesn't fully work in the configure script,
# But it does work when building docs as long as we also pass XMLINCLUDE=--catalogs to make
# Note: it expects that you have installed the docbook-xml-4.5 port
XMLLINT=xmllint
SGML_CATALOG_FILES=/opt/local/etc/sgml/catalog
export XMLLINT SGML_CATALOG_FILES

export CFLAGS CXXFLAGS MACOSX_DEPLOYMENT_TARGET ICU_LIBS ICU_CFLAGS
export PROTOC protobuf_CFLAGS protobuf_LIBS

# commands used for downloading and extracting sources
CURL=/usr/bin/curl -L10 --silent --show-error --remote-name --fail
TAR=/usr/bin/tar xzf

all: postgresql postgis plv8 wal2json pldebugger
clean: clean-postgresql clean-openssl clean-libxml2 clean-libgdal clean-libproj clean-postgis clean-plv8 clean-libjpeg clean-libjasper clean-libgeos clean-libtiff clean-json-c clean-icu clean-protobuf-c clean-protobuf-cpp clean-wal2json clean-pldebugger
	rm -Rf "$(PREFIX)"
check: check-postgresql
download: postgresql-$(POSTGRES_VERSION).tar.bz2 openssl-${OPENSSL_VERSION}.tar.gz icu4c-$(ICU_MAJOR_VERSION)_$(ICU_MINOR_VERSION)-src.tgz libxml2-${LIBXML2_VERSION}.tar.gz libedit-$(LIBEDIT_VERSION).tar.gz jasper-$(LIBJASPER_VERSION).uuid.tar.gz jpegsrc.v$(JPEG_VERSION).tar.gz geos-${GEOS_VERSION}.tar.bz2 gdal-${GDAL_VERSION}.tar.gz proj-${PROJ_VERSION}.tar.gz proj-datumgrid-${DATUMGRID_VERSION}.zip json-c-$(JSONC_VERSION).tar.gz protobuf-cpp-$(PROTOBUF_VERSION).tar.gz protobuf-c-$(PROTOBUFC_VERSION).tar.gz tiff-$(LIBTIFF_VERSION).tar.gz postgis-${POSTGIS_VERSION}.tar.gz plv8-${PLV8_VERSION}.tar.gz wal2json-${WAL2JSON_VERSION}.tar.gz 


#########################
###### PostgreSQL #######
#########################

check-postgresql:
	make -C "postgresql-$(POSTGRES_VERSION)" check-world

postgresql: $(PREFIX)/bin/psql

$(PREFIX)/bin/psql: postgresql-$(POSTGRES_VERSION)/GNUmakefile
	MAKELEVEL=0 make -C "postgresql-$(POSTGRES_VERSION)" world XMLINCLUDE=--catalogs
	make -C "postgresql-$(POSTGRES_VERSION)" install-world

# setting PATH is to make sure we find the right xml2-config
# the --with-includes and --with-libraries options are necessary so
# that postgres will be compiled and linked against our own versions
# of libraries like openssl, instead of system provided versions
# 
# We're building without tcl and perl for now because they caused problems on macOS 10.15
postgresql-$(POSTGRES_VERSION)/GNUmakefile: $(PREFIX)/lib/libssl.dylib $(PREFIX)/lib/libxml2.dylib $(PREFIX)/lib/libicui18n.dylib postgresql-$(POSTGRES_VERSION)/configure
	cd "postgresql-$(POSTGRES_VERSION)" && PG_SYSROOT=no-sysroot ./configure --prefix="$(PREFIX)" --with-includes="$(PREFIX)/include" --with-libraries="$(PREFIX)/lib" --enable-thread-safety --with-openssl --with-bonjour --with-libxml --with-libxslt --with-python --with-readline --with-uuid=e2fs --with-icu

postgresql-$(POSTGRES_VERSION)/configure: postgresql-$(POSTGRES_VERSION).tar.bz2
	$(TAR) "postgresql-$(POSTGRES_VERSION).tar.bz2"
	touch $@

postgresql-$(POSTGRES_VERSION).tar.bz2:
	$(CURL) "$(POSTGRES_DOWNLOAD_URL)/postgresql-$(POSTGRES_VERSION).tar.bz2"

clean-postgresql:
	rm -Rf postgresql-$(POSTGRES_VERSION)


#########################
####### OpenSSL #########
#########################

openssl: $(PREFIX)/lib/libssl.dylib
	touch $@

$(PREFIX)/lib/libssl.dylib: openssl-${OPENSSL_VERSION}/Makefile
	make -C openssl-${OPENSSL_VERSION}
	make -C openssl-${OPENSSL_VERSION} install_sw

openssl-${OPENSSL_VERSION}/Makefile: openssl-${OPENSSL_VERSION}/Configure
	cd openssl-${OPENSSL_VERSION} && ./Configure --prefix="${PREFIX}" darwin64-arm64-cc zlib no-asm shared

openssl-${OPENSSL_VERSION}/Configure: openssl-${OPENSSL_VERSION}.tar.gz
	$(TAR) openssl-${OPENSSL_VERSION}.tar.gz
	touch $@

openssl-${OPENSSL_VERSION}.tar.gz:
	$(CURL) "https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz"

clean-openssl:
	rm -Rf "openssl-${OPENSSL_VERSION}"


#########################
######## ICU ############
#########################

icu: $(PREFIX)/lib/libicui18n.dylib
	touch $@

$(PREFIX)/lib/libicui18n.dylib: icu4c-$(ICU_MAJOR_VERSION)_$(ICU_MINOR_VERSION)/source/Makefile
	make -C "icu4c-$(ICU_MAJOR_VERSION)_$(ICU_MINOR_VERSION)/source"
	make -C "icu4c-$(ICU_MAJOR_VERSION)_$(ICU_MINOR_VERSION)/source" install
	install_name_tool -change libicuuc.$(ICU_MAJOR_VERSION).dylib $(PREFIX)/lib/libicuuc.$(ICU_MAJOR_VERSION).dylib $(PREFIX)/lib/libicui18n.$(ICU_MAJOR_VERSION).dylib
	install_name_tool -change libicudata.$(ICU_MAJOR_VERSION).dylib $(PREFIX)/lib/libicudata.$(ICU_MAJOR_VERSION).dylib $(PREFIX)/lib/libicui18n.$(ICU_MAJOR_VERSION).dylib
	install_name_tool -change libicudata.$(ICU_MAJOR_VERSION).dylib $(PREFIX)/lib/libicudata.$(ICU_MAJOR_VERSION).dylib $(PREFIX)/lib/libicuuc.$(ICU_MAJOR_VERSION).dylib
	install_name_tool -id $(PREFIX)/lib/libicui18n.$(ICU_MAJOR_VERSION).dylib $(PREFIX)/lib/libicui18n.$(ICU_MAJOR_VERSION).dylib
	install_name_tool -id $(PREFIX)/lib/libicuuc.$(ICU_MAJOR_VERSION).dylib $(PREFIX)/lib/libicuuc.$(ICU_MAJOR_VERSION).dylib
	install_name_tool -id $(PREFIX)/lib/libicudata.$(ICU_MAJOR_VERSION).dylib $(PREFIX)/lib/libicudata.$(ICU_MAJOR_VERSION).dylib

icu4c-$(ICU_MAJOR_VERSION)_$(ICU_MINOR_VERSION)/source/Makefile: icu4c-$(ICU_MAJOR_VERSION)_$(ICU_MINOR_VERSION)
	cd icu4c-$(ICU_MAJOR_VERSION)_$(ICU_MINOR_VERSION)/source; ./runConfigureICU MacOSX --prefix="$(PREFIX)"

icu4c-$(ICU_MAJOR_VERSION)_$(ICU_MINOR_VERSION): icu4c-$(ICU_MAJOR_VERSION)_$(ICU_MINOR_VERSION)-src.tgz
	$(TAR) icu4c-$(ICU_MAJOR_VERSION)_$(ICU_MINOR_VERSION)-src.tgz
	mv icu icu4c-$(ICU_MAJOR_VERSION)_$(ICU_MINOR_VERSION)
	touch $@

icu4c-$(ICU_MAJOR_VERSION)_$(ICU_MINOR_VERSION)-src.tgz:
	$(CURL) https://github.com/unicode-org/icu/releases/download/release-$(ICU_MAJOR_VERSION)-$(ICU_MINOR_VERSION)/icu4c-$(ICU_MAJOR_VERSION)_$(ICU_MINOR_VERSION)-src.tgz

clean-icu:
	rm -Rf "icu4c-$(ICU_MAJOR_VERSION)_$(ICU_MINOR_VERSION)"


#########################
######## LibXML2 ########
#########################

libxml2: $(PREFIX)/lib/libxml2.dylib
	touch $@

$(PREFIX)/lib/libxml2.dylib: libxml2-${LIBXML2_VERSION}/Makefile
	make -C libxml2-${LIBXML2_VERSION} install-exec
	make -C libxml2-${LIBXML2_VERSION}/include install
	touch $(PREFIX)/lib/libxml2.dylib

libxml2-${LIBXML2_VERSION}/Makefile: libxml2-${LIBXML2_VERSION}/configure
	cd libxml2-${LIBXML2_VERSION} && export PATH="$(PREFIX)/bin:/bin:/usr/bin" && ./configure --prefix="$(PREFIX)" --disable-dependency-tracking

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

libedit: $(PREFIX)/lib/libedit.dylib
	touch $@

$(PREFIX)/lib/libedit.dylib: libedit-$(LIBEDIT_VERSION)/Makefile
	make -C "libedit-$(LIBEDIT_VERSION)" install

libedit-$(LIBEDIT_VERSION)/Makefile: libedit-$(LIBEDIT_VERSION)/configure
	cd libedit-$(LIBEDIT_VERSION) && ./configure --prefix="$(PREFIX)"

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

libjasper: $(PREFIX)/lib/libjasper.dylib
	touch $@

$(PREFIX)/lib/libjasper.dylib: jasper-${LIBJASPER_VERSION}.uuid/Makefile
	make -C jasper-${LIBJASPER_VERSION}.uuid install

jasper-${LIBJASPER_VERSION}.uuid/Makefile: jasper-${LIBJASPER_VERSION}.uuid/configure
	cd jasper-${LIBJASPER_VERSION}.uuid && ./configure --prefix="$(PREFIX)" --disable-debug --disable-dependency-tracking --enable-shared --enable-dynamic

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

libjpeg: $(PREFIX)/lib/libjpeg.dylib
	touch $@

$(PREFIX)/lib/libjpeg.dylib: jpeg-$(JPEG_VERSION)/Makefile
	make -C jpeg-$(JPEG_VERSION) install

jpeg-$(JPEG_VERSION)/Makefile: jpeg-$(JPEG_VERSION)/configure
	cd jpeg-$(JPEG_VERSION) && ./configure --prefix="$(PREFIX)" --disable-dependency-tracking

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

libgeos: $(PREFIX)/lib/libgeos.dylib
	touch $@

$(PREFIX)/lib/libgeos.dylib: geos-${GEOS_VERSION}/Makefile
	make -C geos-${GEOS_VERSION} install

geos-${GEOS_VERSION}/Makefile: geos-${GEOS_VERSION}/configure $(PREFIX)/bin/psql
	cd geos-${GEOS_VERSION} && ./configure --prefix="$(PREFIX)"

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

libgdal: $(PREFIX)/lib/libgdal.dylib
	touch $@

$(PREFIX)/lib/libgdal.dylib: gdal-$(GDAL_VERSION)/GNUMakefile
	make -C gdal-$(GDAL_VERSION) install

gdal-$(GDAL_VERSION)/GNUMakefile: gdal-$(GDAL_VERSION)/autogen.sh  $(PREFIX)/include/json-c/json_object_iterator.h $(PREFIX)/lib/libproj.dylib $(PREFIX)/lib/libjasper.dylib  $(PREFIX)/lib/libjpeg.dylib $(PREFIX)/bin/psql $(PREFIX)/lib/libtiff.dylib
	cd gdal-$(GDAL_VERSION) && ./autogen.sh && ./configure --prefix="$(PREFIX)" --with-pg=yes  --with-jpeg="$(PREFIX)" --with-jasper="$(PREFIX)" --with-libjson-c="$(PREFIX)" --with-proj="$(PREFIX)"
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

# Depends on postgresql, libtiff

libproj: $(PREFIX)/lib/libproj.dylib
	touch $@

$(PREFIX)/lib/libproj.dylib: proj-$(PROJ_VERSION)/Makefile
	make -C proj-$(PROJ_VERSION) install

proj-$(PROJ_VERSION)/Makefile: proj-$(PROJ_VERSION)/configure $(PREFIX)/bin/psql $(PREFIX)/lib/libtiff.dylib
	cd proj-$(PROJ_VERSION) && SQLITE3_LIBS="-lsqlite3" ./configure --prefix="$(PREFIX)"

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

$(PREFIX)/include/json-c/json_object_iterator.h: json-c-$(JSONC_VERSION)/Makefile
	make -C json-c-$(JSONC_VERSION) install
	cp json-c-$(JSONC_VERSION)/json_object_iterator.h "$(PREFIX)/include/json-c/json_object_iterator.h"

json-c-$(JSONC_VERSION)/Makefile: json-c-$(JSONC_VERSION)/configure
	cd json-c-$(JSONC_VERSION) && ./configure --prefix="$(PREFIX)"

json-c-$(JSONC_VERSION)/configure: json-c-$(JSONC_VERSION).tar.gz
	$(TAR) json-c-$(JSONC_VERSION).tar.gz
	touch $@

json-c-$(JSONC_VERSION).tar.gz:
	$(CURL) "https://s3.amazonaws.com/json-c_releases/releases/json-c-$(JSONC_VERSION).tar.gz"

clean-json-c:
	rm -Rf json-c-$(JSONC_VERSION)


#########################
###### protobuf-cpp #####
#########################

$(BUILD_PREFIX)/bin/protoc: protobuf-$(PROTOBUF_VERSION)/Makefile
	make -C protobuf-$(PROTOBUF_VERSION) install

protobuf-$(PROTOBUF_VERSION)/Makefile: protobuf-$(PROTOBUF_VERSION)/configure
	cd protobuf-$(PROTOBUF_VERSION) && ./configure --prefix="$(BUILD_PREFIX)"

protobuf-$(PROTOBUF_VERSION)/configure: protobuf-cpp-$(PROTOBUF_VERSION).tar.gz
	$(TAR) protobuf-cpp-$(PROTOBUF_VERSION).tar.gz
	touch $@

protobuf-cpp-$(PROTOBUF_VERSION).tar.gz:
	$(CURL) "https://github.com/protocolbuffers/protobuf/releases/download/v$(PROTOBUF_VERSION)/protobuf-cpp-$(PROTOBUF_VERSION).tar.gz"

clean-protobuf-cpp:
	rm -Rf protobuf-$(PROTOBUF_VERSION)


#########################
###### protobuf-c #######
#########################

protobuf-c: $(PREFIX)/lib/libprotobuf-c.dylib

$(PREFIX)/lib/libprotobuf-c.dylib: protobuf-c-$(PROTOBUFC_VERSION)/Makefile
	make -C protobuf-c-$(PROTOBUFC_VERSION) install

protobuf-c-$(PROTOBUFC_VERSION)/Makefile: protobuf-c-$(PROTOBUFC_VERSION)/configure $(BUILD_PREFIX)/bin/protoc
	cd protobuf-c-$(PROTOBUFC_VERSION) && ./configure --prefix="$(PREFIX)"

protobuf-c-$(PROTOBUFC_VERSION)/configure: protobuf-c-$(PROTOBUFC_VERSION).tar.gz
	$(TAR) protobuf-c-$(PROTOBUFC_VERSION).tar.gz
	touch $@

protobuf-c-$(PROTOBUFC_VERSION).tar.gz:
	$(CURL) "https://github.com/protobuf-c/protobuf-c/releases/download/v$(PROTOBUFC_VERSION)/protobuf-c-$(PROTOBUFC_VERSION).tar.gz"

clean-protobuf-c:
	rm -Rf protobuf-c-$(PROTOBUFC_VERSION)


#########################
####### libtiff #########
#########################

libtiff: $(PREFIX)/lib/libtiff.dylib
	touch $@

$(PREFIX)/lib/libtiff.dylib: tiff-$(LIBTIFF_VERSION)/Makefile
	make -C tiff-$(LIBTIFF_VERSION) install

tiff-$(LIBTIFF_VERSION)/Makefile: tiff-$(LIBTIFF_VERSION)/configure
	cd tiff-$(LIBTIFF_VERSION) && ./configure --prefix="$(PREFIX)" --disable-dependency-tracking

tiff-$(LIBTIFF_VERSION)/configure: tiff-$(LIBTIFF_VERSION).tar.gz
	$(TAR) tiff-$(LIBTIFF_VERSION).tar.gz
	touch $@

tiff-$(LIBTIFF_VERSION).tar.gz:
	$(CURL) https://download.osgeo.org/libtiff/tiff-$(LIBTIFF_VERSION).tar.gz

clean-libtiff:
	rm -Rf tiff-$(LIBTIFF_VERSION)


#########################
###### PostGIS ##########
#########################

#depends on libgdal, libgeos, libjpeg, postgresql, jsonc

PCRE_INCLUDE_PATH=$(shell pwd)/include

postgis: $(PREFIX)/lib/liblwgeom.dylib
	touch $@

$(PREFIX)/lib/liblwgeom.dylib: postgis-${POSTGIS_VERSION}/GNUMakefile $(PREFIX)/lib/postgresql/postgis-$(POSTGIS_MAJOR_VERSION).so
	make -C postgis-${POSTGIS_VERSION}/liblwgeom
	make -C postgis-${POSTGIS_VERSION}/liblwgeom install

$(PREFIX)/lib/postgresql/postgis-$(POSTGIS_MAJOR_VERSION).so: postgis-${POSTGIS_VERSION}/GNUMakefile
	make -C postgis-${POSTGIS_VERSION}
	make -C postgis-${POSTGIS_VERSION} install

postgis-${POSTGIS_VERSION}/GNUMakefile: postgis-${POSTGIS_VERSION}/autogen.sh $(PREFIX)/lib/libgdal.dylib $(PREFIX)/lib/libgeos.dylib $(PREFIX)/lib/libjpeg.dylib $(PREFIX)/bin/psql $(PREFIX)/include/json-c/json_object_iterator.h $(PREFIX)/lib/libprotobuf-c.dylib
	cd postgis-${POSTGIS_VERSION} && ./autogen.sh && ./configure --prefix="$(PREFIX)" --with-pgconfig="$(PREFIX)/bin/pg_config" --with-geosconfig="$(PREFIX)/bin/geos-config" --with-projdir="$(PREFIX)" --with-gdaldir="$(PREFIX)" --with-jsondir="$(PREFIX)" --with-protobufdir="$(PREFIX)" PCRE_CPPFLAGS="-I$(PCRE_INCLUDE_PATH)"
	/usr/bin/sed -i -e 's#/usr/local$$#"$(PREFIX)"#g' postgis-${POSTGIS_VERSION}/liblwgeom/Makefile
	touch $@

postgis-${POSTGIS_VERSION}/autogen.sh: postgis-${POSTGIS_VERSION}.tar.gz
	$(TAR) $<
	touch $@

postgis-${POSTGIS_VERSION}.tar.gz:
	$(CURL) "https://download.osgeo.org/postgis/source/postgis-${POSTGIS_VERSION}.tar.gz"

clean-postgis:
	rm -Rf postgis-${POSTGIS_VERSION}


##########################
######## PLV8 ############
##########################

plv8: $(PREFIX)/lib/postgresql/plv8.so
	touch $@

$(PREFIX)/lib/postgresql/plv8.so: plv8-${PLV8_VERSION}/Makefile $(PREFIX)/bin/psql
	export PGHOME="$(PREFIX)"; export PG_CONFIG="$(PREFIX)/bin/pg_config"; make -C plv8-${PLV8_VERSION} install

plv8-${PLV8_VERSION}/Makefile: plv8-${PLV8_VERSION}.tar.gz
	$(TAR) $<
	touch $@

plv8-${PLV8_VERSION}.tar.gz:
	/usr/bin/curl -L10 --silent --fail --show-error -o $@ https://github.com/plv8/plv8/archive/v${PLV8_VERSION}.tar.gz

clean-plv8:
	rm -Rf plv8-${PLV8_VERSION}


#########################
###### wal2json #########
#########################

wal2json: $(PREFIX)/lib/postgresql/wal2json.so
	touch $@

$(PREFIX)/lib/postgresql/wal2json.so: wal2json-${WAL2JSON_VERSION}/Makefile $(PREFIX)/bin/psql
	export PGHOME="$(PREFIX)"; export PG_CONFIG="$(PREFIX)/bin/pg_config"; export USE_PGXS=1; make -C wal2json-${WAL2JSON_VERSION} install

wal2json-${WAL2JSON_VERSION}/Makefile: wal2json-${WAL2JSON_VERSION}.tar.gz
	$(TAR) $<
	touch $@

wal2json-${WAL2JSON_VERSION}.tar.gz:
	/usr/bin/curl -L10 --silent --fail --show-error -o $@ https://github.com/eulerto/wal2json/archive/${WAL2JSON_VERSION}.tar.gz

clean-wal2json:
	rm -Rf wal2json-${WAL2JSON_VERSION}


#########################
##### pldebugger ########
#########################

pldebugger: $(PREFIX)/lib/postgresql/plugin_debugger.so
	touch $@

$(PREFIX)/lib/postgresql/plugin_debugger.so: pldebugger/Makefile $(PREFIX)/bin/psql
	export PGHOME="$(PREFIX)"; export PG_CONFIG="$(PREFIX)/bin/pg_config"; export USE_PGXS=1; make -C pldebugger install

pldebugger/Makefile:
	git clone git://git.postgresql.org/git/pldebugger.git
	touch $@

clean-pldebugger:
	rm -Rf pldebugger
