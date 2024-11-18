# VERSION numbers

# http://postgis.net/development/source_code/
POSTGIS_VERSION=3.4.3
POSTGIS_MAJOR_VERSION=3

POSTGRES_VERSION=16.6
POSTGRES_MAJOR_VERSION=16
POSTGRES_DOWNLOAD_URL=https://ftp.postgresql.org/pub/source/v$(POSTGRES_VERSION)

POSTGRESAPP_VERSION=$(POSTGRES_VERSION)

# https://github.com/lz4/lz4/releases
LZ4_VERSION=1.9.4

# https://github.com/facebook/zstd/releases
ZSTD_VERSION=1.5.6

# https://github.com/OSGeo/gdal/releases
# http://download.osgeo.org/gdal/
GDAL_VERSION=3.7.3

# https://libgeos.org/usage/download/
GEOS_VERSION=3.12.2

# http://www.ijg.org
JPEG_VERSION=9f

# https://gmplib.org/download/gmp/
GMP_VERSION=6.3.0

# https://www.mpfr.org/mpfr-current/#download
MPFR_VERSION=4.2.1

# https://www.boost.org/users/download/
BOOST_VERSION=1_83_0

# https://github.com/CGAL/cgal/releases
CGAL_VERSION=5.6.2

# https://gitlab.com/sfcgal/SFCGAL/-/releases
SFCGAL_VERSION=1.4.1

LIBEDIT_VERSION=20130611-3.1

# https://gitlab.gnome.org/GNOME/libxml2/-/releases
# https://download.gnome.org/sources/libxml2/
LIBXML2_VERSION=2.11.9
LIBXML2_VERSION_MAJOR=$(shell echo $(LIBXML2_VERSION) | sed -E 's/^([0-9]+\.[0-9]+)\..*$$/\1/')

# https://www.openssl.org
OPENSSL_VERSION=3.0.15

# https://proj.org/download.html
# https://github.com/OSGeo/PROJ/releases
PROJ_VERSION=9.2.1
# due to their size we no longer bundle proj-data. 
# Users can download them via projsync or use the CDN
#PROJ-DATA_VERSION=1.7

# https://github.com/plv8/plv8/tags
PLV8_VERSION=3.0.0

# https://github.com/json-c/json-c/wiki
# https://s3.amazonaws.com/json-c_releases/releases/index.html
JSONC_VERSION=0.17

# https://github.com/eulerto/wal2json/releases
WAL2JSON_VERSION=wal2json_2_6

# https://github.com/protocolbuffers/protobuf/releases
PROTOBUF_VERSION=3.21.12
PROTOBUF_VERSION_MINOR=$(shell echo $(PROTOBUF_VERSION) | sed -E 's/^[0-9]+\.(.*)$$/\1/')

# https://github.com/protobuf-c/protobuf-c/releases
PROTOBUFC_VERSION=1.4.1

# http://simplesystems.org/libtiff/
LIBTIFF_VERSION=4.6.0

# https://github.com/glennrp/libpng/tags
LIBPNG_VERSION=1.6.44

# https://github.com/uclouvain/openjpeg/releases
OPENJPEG_VERSION=2.5.2

# https://github.com/Unidata/netcdf-c/releases
NETCDF_VERSION=4.9.2

# https://github.com/EnterpriseDB/pldebugger/tags
PLDEBUGGER_VERSION=1.8

# https://github.com/pgvector/pgvector/tags
PGVECTOR_VERSION=0.8.0

# https://github.com/pgRouting/pgrouting/releases
PGROUTING_VERSION=3.5.1
PGROUTING_VERSION_MAJOR=$(shell echo $(PGROUTING_VERSION) | sed -E 's/^([0-9]+\.[0-9]+)\..*$$/\1/')

# https://github.com/plv8/pljs/tags
PLJS_VERSION=0.8.0

# https://bellard.org/quickjs/
QUICKJS_VERSION=2024-01-13

# https://unicode-org.github.io/icu/download/
ICU_MAJOR_VERSION=73
ICU_MINOR_VERSION=2

# https://www.python.org/downloads/macos/
PYTHON_VERSION=3.12
PYTHON_VERSION_FULL=3.12.7

#path configuration
BUILD_PREFIX=$(shell pwd)/build
PREFIX=/Applications/Postgres.app/Contents/Versions/$(POSTGRES_MAJOR_VERSION)
PATH=$(PREFIX)/bin:/bin:/usr/bin:/sbin:/opt/local/bin:/opt/homebrew/bin
PKG_CONFIG_LIBDIR=$(PREFIX)/lib/pkgconfig
DEVELOPER_DIR=/Library/Developer/CommandLineTools

export PREFIX PATH PKG_CONFIG_LIBDIR DEVELOPER_DIR

#python config
PYTHON=/Library/Frameworks/Python.framework/Versions/$(PYTHON_VERSION)/bin/python3
export PYTHON

#compiler options
MACOSX_DEPLOYMENT_TARGET=10.13
CFLAGS:=$(CFLAGS) -Os -mmacosx-version-min=10.13 -arch arm64 -arch x86_64
CXXFLAGS:=$(CXXFLAGS) -Os -mmacosx-version-min=10.13 -arch arm64 -arch x86_64
CMAKE_OSX_ARCHITECTURES=arm64;x86_64
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
# Note: it expects that you have installed the docbook-xml-4.5 port or the docbook-xsl formula
XMLLINT=xmllint
SGML_CATALOG_FILES=/opt/local/etc/sgml/catalog:/opt/homebrew/etc/xml/catalog
export XMLLINT SGML_CATALOG_FILES

export CFLAGS CXXFLAGS MACOSX_DEPLOYMENT_TARGET CMAKE_OSX_ARCHITECTURES ICU_LIBS ICU_CFLAGS
export PROTOC protobuf_CFLAGS protobuf_LIBS

# commands used for downloading and extracting sources
CURL=/usr/bin/curl -L10 --silent --show-error --remote-name --fail
TAR=/usr/bin/tar xzf

all: postgresql auth_permission_dialog postgis wal2json pldebugger pgvector pgrouting pljs
clean: clean-postgresql clean-auth_permission_dialog clean-lz4 clean-zstd clean-openssl clean-icu clean-libxml2 clean-libedit clean-libjpeg clean-libgeos clean-libgdal clean-libproj clean-json-c clean-protobuf-cpp clean-protobuf-c clean-libtiff clean-libpng clean-openjpeg clean-netcdf clean-gmp clean-mpfr clean-boost clean-cgal clean-sfcgal clean-postgis clean-plv8 clean-wal2json clean-pldebugger clean-pgvector clean-pgrouting clean-pljs
	rm -Rf "$(PREFIX)"
	rm -Rf "$(BUILD_PREFIX)"
check: check-postgresql check-zstd check-libgeos check-libproj check-libtiff check-netcdf check-gmp check-mpfr check-pgvector check-pljs check-arch check-libs check-rpath check-python
download: postgresql-$(POSTGRES_VERSION).tar.bz2 lz4-${LZ4_VERSION}.tar.gz zstd-${ZSTD_VERSION}.tar.gz openssl-${OPENSSL_VERSION}.tar.gz icu4c-$(ICU_MAJOR_VERSION)_$(ICU_MINOR_VERSION)-src.tgz libxml2-${LIBXML2_VERSION}.tar.xz libedit-$(LIBEDIT_VERSION).tar.gz jpegsrc.v$(JPEG_VERSION).tar.gz geos-${GEOS_VERSION}.tar.bz2 gdal-${GDAL_VERSION}.tar.gz proj-${PROJ_VERSION}.tar.gz json-c-$(JSONC_VERSION).tar.gz protobuf-cpp-$(PROTOBUF_VERSION).tar.gz protobuf-c-$(PROTOBUFC_VERSION).tar.gz tiff-$(LIBTIFF_VERSION).tar.gz libpng-$(LIBPNG_VERSION).tar.gz openjpeg-$(OPENJPEG_VERSION).tar.gz netcdf-c-$(NETCDF_VERSION).tar.gz gmp-$(GMP_VERSION).tar.xz mpfr-$(MPFR_VERSION).tar.xz boost_$(BOOST_VERSION).tar.bz2 CGAL-$(CGAL_VERSION).tar.xz SFCGAL-v$(SFCGAL_VERSION).tar.gz postgis-${POSTGIS_VERSION}.tar.gz plv8-${PLV8_VERSION}.tar.gz wal2json-${WAL2JSON_VERSION}.tar.gz pldebugger-${PLDEBUGGER_VERSION}.tar.gz pgvector-${PGVECTOR_VERSION}.tar.gz pgrouting-$(PGROUTING_VERSION).tar.gz pljs-${PLJS_VERSION}.tar.gz quickjs-${QUICKJS_VERSION}.tar.xz


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
postgresql-$(POSTGRES_VERSION)/GNUmakefile: $(PREFIX)/lib/libssl.dylib $(PREFIX)/lib/libxml2.dylib $(PREFIX)/lib/libicui18n.dylib $(PREFIX)/lib/liblz4.dylib $(PREFIX)/lib/libzstd.dylib postgresql-$(POSTGRES_VERSION)/configure | check-python
	cd "postgresql-$(POSTGRES_VERSION)" && PG_SYSROOT=no-sysroot ./configure --prefix="$(PREFIX)" --with-includes="$(PREFIX)/include" --with-libraries="$(PREFIX)/lib" --enable-thread-safety --with-openssl --with-bonjour --with-libxml --with-libxslt --with-python --with-readline --with-uuid=e2fs --with-icu --with-extra-version=" (Postgres.app)" --with-lz4 --with-zstd

postgresql-$(POSTGRES_VERSION)/configure: postgresql-$(POSTGRES_VERSION).tar.bz2
	$(TAR) "postgresql-$(POSTGRES_VERSION).tar.bz2"
	patch -b -d "postgresql-$(POSTGRES_VERSION)" -p1 <patches/fd.c.patch
	touch $@

postgresql-$(POSTGRES_VERSION).tar.bz2:
	$(CURL) "$(POSTGRES_DOWNLOAD_URL)/postgresql-$(POSTGRES_VERSION).tar.bz2"

clean-postgresql:
	rm -Rf postgresql-$(POSTGRES_VERSION)


######################################
####### auth_permission_dialog #######
######################################

auth_permission_dialog: $(PREFIX)/lib/postgresql/auth_permission_dialog.dylib
	touch $@

$(PREFIX)/lib/postgresql/auth_permission_dialog.dylib: auth_permission_dialog/Makefile $(PREFIX)/bin/psql
	make -C auth_permission_dialog
	make -C auth_permission_dialog install

auth_permission_dialog/Makefile:
	cp -r ../auth_permission_dialog auth_permission_dialog

clean-auth_permission_dialog:
	rm -Rf auth_permission_dialog


#########################
######### LZ4 ###########
#########################

lz4: $(PREFIX)/lib/liblz4.dylib
	touch $@

$(PREFIX)/lib/liblz4.dylib: lz4-${LZ4_VERSION}/Makefile
	CPPFLAGS="${CXXFLAGS}" make -C lz4-${LZ4_VERSION} lib-release
	make -C lz4-${LZ4_VERSION}/lib install

lz4-${LZ4_VERSION}/Makefile: lz4-${LZ4_VERSION}.tar.gz
	$(TAR) lz4-${LZ4_VERSION}.tar.gz
	touch $@

lz4-${LZ4_VERSION}.tar.gz:
	$(CURL) --remote-header-name "https://github.com/lz4/lz4/archive/refs/tags/v${LZ4_VERSION}.tar.gz"

clean-lz4:
	rm -Rf "lz4-${LZ4_VERSION}"


###############################
######### Zstandard ###########
###############################

# used for postgresql, libgdal, libtiff, netcdf, boost

zstd: $(PREFIX)/lib/libzstd.dylib
	touch $@

$(PREFIX)/lib/libzstd.dylib: zstd-${ZSTD_VERSION}/Makefile
	make -C zstd-${ZSTD_VERSION} lib-release HAVE_LZ4=0
	make -C zstd-${ZSTD_VERSION}/lib install

zstd-${ZSTD_VERSION}/Makefile: zstd-${ZSTD_VERSION}.tar.gz
	$(TAR) zstd-${ZSTD_VERSION}.tar.gz
	touch $@

zstd-${ZSTD_VERSION}.tar.gz:
	$(CURL) "https://github.com/facebook/zstd/releases/download/v${ZSTD_VERSION}/zstd-${ZSTD_VERSION}.tar.gz"

check-zstd:
	make -C zstd-${ZSTD_VERSION} check

clean-zstd:
	rm -Rf "zstd-${ZSTD_VERSION}"

#########################
####### OpenSSL #########
#########################

openssl: $(PREFIX)/lib/libssl.dylib
	touch $@

$(PREFIX)/lib/libssl.dylib: openssl-${OPENSSL_VERSION}/build_arm64/libssl.dylib openssl-${OPENSSL_VERSION}/build_x86_64/libssl.dylib
	$(eval DYLD_VERSION=$(shell grep -o '"shlib_version".*' openssl-${OPENSSL_VERSION}/build_arm64/configdata.pm | cut -d '"' -f4))
	cd openssl-${OPENSSL_VERSION}/build_arm64 && lipo -create ./libcrypto.${DYLD_VERSION}.dylib ../build_x86_64/libcrypto.${DYLD_VERSION}.dylib -output ./libcrypto.${DYLD_VERSION}.dylib
	cd openssl-${OPENSSL_VERSION}/build_arm64 && lipo -create ./libcrypto.a ../build_x86_64/libcrypto.a -output ./libcrypto.a
	cd openssl-${OPENSSL_VERSION}/build_arm64 && lipo -create ./libssl.${DYLD_VERSION}.dylib ../build_x86_64/libssl.${DYLD_VERSION}.dylib -output ./libssl.${DYLD_VERSION}.dylib
	cd openssl-${OPENSSL_VERSION}/build_arm64 && lipo -create ./libssl.a ../build_x86_64/libssl.a -output ./libssl.a
	cd openssl-${OPENSSL_VERSION}/build_arm64 && lipo -create ./apps/openssl ../build_x86_64/apps/openssl -output ./apps/openssl
	cd openssl-${OPENSSL_VERSION}/build_arm64 && lipo -create ./engines/capi.dylib ../build_x86_64/engines/capi.dylib -output ./engines/capi.dylib
	cd openssl-${OPENSSL_VERSION}/build_arm64 && lipo -create ./engines/dasync.dylib ../build_x86_64/engines/dasync.dylib -output ./engines/dasync.dylib
	cd openssl-${OPENSSL_VERSION}/build_arm64 && lipo -create ./engines/loader_attic.dylib ../build_x86_64/engines/loader_attic.dylib -output ./engines/loader_attic.dylib
	cd openssl-${OPENSSL_VERSION}/build_arm64 && lipo -create ./engines/ossltest.dylib ../build_x86_64/engines/ossltest.dylib -output ./engines/ossltest.dylib
	cd openssl-${OPENSSL_VERSION}/build_arm64 && lipo -create ./engines/padlock.dylib ../build_x86_64/engines/padlock.dylib -output ./engines/padlock.dylib
	cd openssl-${OPENSSL_VERSION}/build_arm64 && lipo -create ./providers/legacy.dylib ../build_x86_64/providers/legacy.dylib -output ./providers/legacy.dylib
	cd openssl-${OPENSSL_VERSION}/build_arm64 && lipo -create ./test/p_test.dylib ../build_x86_64/test/p_test.dylib -output ./test/p_test.dylib
	cd openssl-${OPENSSL_VERSION}/build_arm64 && lipo -create ./test/p_minimal.dylib ../build_x86_64/test/p_minimal.dylib -output ./test/p_minimal.dylib
	# to avoid dirty make targets after we touched the libraries, pretend we rebuilded everything before installing
	make -C openssl-${OPENSSL_VERSION}/build_arm64 --touch
	make -C openssl-${OPENSSL_VERSION}/build_arm64 install_sw

openssl-${OPENSSL_VERSION}/build_arm64/libssl.dylib: openssl-${OPENSSL_VERSION}/build_arm64/Makefile
	make -C openssl-${OPENSSL_VERSION}/build_arm64
	
openssl-${OPENSSL_VERSION}/build_x86_64/libssl.dylib: openssl-${OPENSSL_VERSION}/build_x86_64/Makefile
	make -C openssl-${OPENSSL_VERSION}/build_x86_64
	
openssl-${OPENSSL_VERSION}/build_arm64/Makefile: openssl-${OPENSSL_VERSION}/Configure
	cd openssl-${OPENSSL_VERSION}/build_arm64 && CFLAGS="$(filter-out -arch arm64 x86_64,$(CFLAGS)) -arch arm64" ../Configure --prefix="${PREFIX}" darwin64-arm64-cc zlib shared

openssl-${OPENSSL_VERSION}/build_x86_64/Makefile: openssl-${OPENSSL_VERSION}/Configure
	cd openssl-${OPENSSL_VERSION}/build_x86_64 && CFLAGS="$(filter-out -arch arm64 x86_64,$(CFLAGS)) -arch x86_64" ../Configure --prefix="${PREFIX}" darwin64-x86_64-cc zlib shared

openssl-${OPENSSL_VERSION}/Configure: openssl-${OPENSSL_VERSION}.tar.gz
	$(TAR) openssl-${OPENSSL_VERSION}.tar.gz
	mkdir openssl-${OPENSSL_VERSION}/build_x86_64
	mkdir openssl-${OPENSSL_VERSION}/build_arm64
	touch $@

openssl-${OPENSSL_VERSION}.tar.gz:
	$(CURL) "https://github.com/openssl/openssl/releases/download/openssl-${OPENSSL_VERSION}/openssl-${OPENSSL_VERSION}.tar.gz"

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
	cd libxml2-${LIBXML2_VERSION} && ./configure --prefix="$(PREFIX)" --disable-dependency-tracking --without-python --without-icu

libxml2-${LIBXML2_VERSION}/configure: libxml2-${LIBXML2_VERSION}.tar.xz
	$(TAR) libxml2-${LIBXML2_VERSION}.tar.xz
	touch $@

libxml2-${LIBXML2_VERSION}.tar.xz:
	$(CURL) "https://download.gnome.org/sources/libxml2/${LIBXML2_VERSION_MAJOR}/libxml2-${LIBXML2_VERSION}.tar.xz"

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
#######  libjpeg  #######
#########################

# used for libgdal, postgis, libtiff

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

$(PREFIX)/lib/libgeos.dylib: geos-${GEOS_VERSION}/build/Makefile
	make -C geos-${GEOS_VERSION}/build
	make -C geos-${GEOS_VERSION}/build install

geos-${GEOS_VERSION}/build/Makefile: geos-${GEOS_VERSION}/configure $(PREFIX)/bin/psql
	cd geos-${GEOS_VERSION}/build && cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$(PREFIX)" -DCMAKE_MACOSX_RPATH=ON -DCMAKE_INSTALL_RPATH="$(PREFIX)/lib" -DCMAKE_INSTALL_NAME_DIR="$(PREFIX)/lib"

geos-${GEOS_VERSION}/configure: geos-${GEOS_VERSION}.tar.bz2
	$(TAR) geos-${GEOS_VERSION}.tar.bz2
	mkdir geos-${GEOS_VERSION}/build
	touch $@

geos-${GEOS_VERSION}.tar.bz2:
	$(CURL) "http://download.osgeo.org/geos/geos-${GEOS_VERSION}.tar.bz2"
	
check-libgeos:
	make -C geos-${GEOS_VERSION}/build check

clean-libgeos:
	rm -Rf geos-${GEOS_VERSION}


#########################
#######  libgdal  #######
#########################

# Depends on libproj, postgresql, libjpeg, libtiff, json-c, libpng, openjpeg, lz4, zstd, sfcgal, libgeos, netcdf

libgdal: $(PREFIX)/lib/libgdal.dylib
	touch $@

$(PREFIX)/lib/libgdal.dylib: gdal-$(GDAL_VERSION)/build/Makefile
	cd gdal-$(GDAL_VERSION)/build && cmake --build .
	cd gdal-$(GDAL_VERSION)/build && cmake --build . --target install

gdal-$(GDAL_VERSION)/build/Makefile: gdal-$(GDAL_VERSION)/CMakeLists.txt  $(PREFIX)/lib/libjson-c.dylib $(PREFIX)/lib/libproj.dylib $(PREFIX)/lib/libjpeg.dylib $(PREFIX)/bin/psql $(PREFIX)/lib/libtiff.dylib $(PREFIX)/lib/libpng.dylib $(PREFIX)/lib/libopenjp2.dylib  $(PREFIX)/lib/liblz4.dylib $(PREFIX)/lib/libzstd.dylib $(PREFIX)/lib/libSFCGAL.dylib $(PREFIX)/lib/libgeos.dylib $(PREFIX)/lib/libnetcdf.dylib
	cd gdal-$(GDAL_VERSION)/build && cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$(PREFIX)" -DCMAKE_MACOSX_RPATH=ON -DCMAKE_INSTALL_RPATH="$(PREFIX)/lib" -DCMAKE_INSTALL_NAME_DIR="$(PREFIX)/lib" -DENABLE_IPO=ON -DCMAKE_PREFIX_PATH="$(PREFIX)" -DBUILD_PYTHON_BINDINGS:BOOL=OFF -DBUILD_CSHARP_BINDINGS:BOOL=OFF -DBUILD_JAVA_BINDINGS:BOOL=OFF
	touch $@

gdal-$(GDAL_VERSION)/CMakeLists.txt: gdal-${GDAL_VERSION}.tar.gz
	$(TAR) gdal-$(GDAL_VERSION).tar.gz
	#patch curl version detection for <= 10.14 compatibility
	patch -b -d "gdal-$(GDAL_VERSION)" -p1 <patches/gdal_curl_10.14.patch
	mkdir gdal-$(GDAL_VERSION)/build
	touch $@

gdal-${GDAL_VERSION}.tar.gz:
	$(CURL) "http://download.osgeo.org/gdal/${GDAL_VERSION}/gdal-${GDAL_VERSION}.tar.gz"

clean-libgdal:
	rm -Rf gdal-$(GDAL_VERSION)


######################
###### libproj  ######
######################

# Depends on postgresql, libtiff

libproj: $(PREFIX)/lib/libproj.dylib
	touch $@

$(PREFIX)/lib/libproj.dylib: proj-$(PROJ_VERSION)/build/Makefile
	make -C proj-$(PROJ_VERSION)/build
	make -C proj-$(PROJ_VERSION)/build install

proj-$(PROJ_VERSION)/build/Makefile: proj-$(PROJ_VERSION)/configure $(PREFIX)/bin/psql $(PREFIX)/lib/libtiff.dylib
	cd proj-$(PROJ_VERSION)/build && cmake .. -DCMAKE_BUILD_TYPE=Release -DENABLE_IPO=ON -DCMAKE_INSTALL_PREFIX="$(PREFIX)" -DCMAKE_MACOSX_RPATH=ON -DCMAKE_INSTALL_RPATH="$(PREFIX)/lib" -DCMAKE_INSTALL_NAME_DIR="$(PREFIX)/lib"
	
proj-${PROJ_VERSION}/configure: proj-${PROJ_VERSION}.tar.gz
	$(TAR) "proj-${PROJ_VERSION}.tar.gz"
	mkdir proj-${PROJ_VERSION}/build
	touch $@

proj-${PROJ_VERSION}.tar.gz:
	$(CURL) "http://download.osgeo.org/proj/proj-${PROJ_VERSION}.tar.gz"

check-libproj:
	# 'test_fork' fails (if build on big sur, only for arm64) disable for now
	# proj_create: SQLite error on SELECT versioned_auth_name, auth_name, version, priority FROM versioned_auth_name_mapping: disk I/O error
	#make -C proj-$(PROJ_VERSION)/build test

clean-libproj:
	rm -Rf proj-${PROJ_VERSION}


#########################
###### JSON-c ###########
#########################

libjson-c: $(PREFIX)/lib/libjson-c.dylib
	touch $@

$(PREFIX)/lib/libjson-c.dylib: json-c-$(JSONC_VERSION)/build/Makefile
	make -C json-c-$(JSONC_VERSION)/build install

json-c-$(JSONC_VERSION)/build/Makefile: json-c-$(JSONC_VERSION)/cmake-configure
	cd json-c-$(JSONC_VERSION)/build && cmake .. -DCMAKE_BUILD_TYPE=Release -DBUILD_APPS=NO -DCMAKE_INSTALL_PREFIX="$(PREFIX)" -DCMAKE_MACOSX_RPATH=ON -DCMAKE_INSTALL_RPATH="$(PREFIX)/lib" -DCMAKE_INSTALL_NAME_DIR="$(PREFIX)/lib"

json-c-$(JSONC_VERSION)/cmake-configure: json-c-$(JSONC_VERSION).tar.gz
	$(TAR) json-c-$(JSONC_VERSION).tar.gz
	mkdir json-c-$(JSONC_VERSION)/build
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
	$(CURL) "https://github.com/protocolbuffers/protobuf/releases/download/v$(PROTOBUF_VERSION_MINOR)/protobuf-cpp-$(PROTOBUF_VERSION).tar.gz"

clean-protobuf-cpp:
	rm -Rf protobuf-$(PROTOBUF_VERSION)


#########################
###### protobuf-c #######
#########################

# Depends on protobuf-cpp

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

# Depends on libjpeg, zstd

libtiff: $(PREFIX)/lib/libtiff.dylib
	touch $@

$(PREFIX)/lib/libtiff.dylib: tiff-$(LIBTIFF_VERSION)/Makefile
	make -C tiff-$(LIBTIFF_VERSION) install

tiff-$(LIBTIFF_VERSION)/Makefile: tiff-$(LIBTIFF_VERSION)/configure $(PREFIX)/lib/libjpeg.dylib $(PREFIX)/lib/libzstd.dylib
	cd tiff-$(LIBTIFF_VERSION) && ./configure --prefix="$(PREFIX)" --disable-dependency-tracking --with-jpeg-include-dir=$(PREFIX)/include --with-jpeg-lib-dir=$(PREFIX)/lib --with-zstd-include-dir=$(PREFIX)/include --with-zstd-lib-dir=$(PREFIX)/lib --disable-tools --disable-contrib --disable-docs 
	
tiff-$(LIBTIFF_VERSION)/configure: tiff-$(LIBTIFF_VERSION).tar.gz
	$(TAR) tiff-$(LIBTIFF_VERSION).tar.gz
	touch $@

tiff-$(LIBTIFF_VERSION).tar.gz:
	$(CURL) https://download.osgeo.org/libtiff/tiff-$(LIBTIFF_VERSION).tar.gz

clean-libtiff:
	rm -Rf tiff-$(LIBTIFF_VERSION)

check-libtiff:
	make -C tiff-$(LIBTIFF_VERSION) check

########################
####### libpng #########
########################

# used for libgdal as the internal version does not correctly link on aarm64

libpng: $(PREFIX)/lib/libpng.dylib
	touch $@

$(PREFIX)/lib/libpng.dylib: libpng-$(LIBPNG_VERSION)/Makefile
	make -C libpng-$(LIBPNG_VERSION) install

libpng-$(LIBPNG_VERSION)/Makefile: libpng-$(LIBPNG_VERSION)/configure
	cd libpng-$(LIBPNG_VERSION) && ./configure --prefix="$(PREFIX)" --disable-dependency-tracking

libpng-$(LIBPNG_VERSION)/configure: libpng-$(LIBPNG_VERSION).tar.gz
	$(TAR) libpng-$(LIBPNG_VERSION).tar.gz
	touch $@

libpng-$(LIBPNG_VERSION).tar.gz:
	$(CURL) --remote-header-name https://github.com/glennrp/libpng/archive/refs/tags/v$(LIBPNG_VERSION).tar.gz

clean-libpng:
	rm -Rf libpng-$(LIBPNG_VERSION)
	
##########################
####### openjpeg #########
##########################

# used for libgdal as the patched version of jasper does not build on aarm64
# links executables against libpng and libtiff if these are built before

openjpeg: $(PREFIX)/lib/libopenjp2.dylib
	touch $@

$(PREFIX)/lib/libopenjp2.dylib: openjpeg-$(OPENJPEG_VERSION)/build/Makefile
	make -C openjpeg-$(OPENJPEG_VERSION)/build install

openjpeg-$(OPENJPEG_VERSION)/build/Makefile: openjpeg-$(OPENJPEG_VERSION)/CMakeLists.txt $(PREFIX)/lib/libtiff.dylib $(PREFIX)/lib/libpng.dylib
	cd openjpeg-$(OPENJPEG_VERSION)/build && cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$(PREFIX)" -DCMAKE_MACOSX_RPATH=ON -DCMAKE_INSTALL_RPATH="$(PREFIX)/lib" -DCMAKE_INSTALL_NAME_DIR="$(PREFIX)/lib"

openjpeg-$(OPENJPEG_VERSION)/CMakeLists.txt: openjpeg-$(OPENJPEG_VERSION).tar.gz
	$(TAR) openjpeg-$(OPENJPEG_VERSION).tar.gz
	mkdir openjpeg-$(OPENJPEG_VERSION)/build
	touch $@

openjpeg-$(OPENJPEG_VERSION).tar.gz:
	$(CURL) --remote-header-name https://github.com/uclouvain/openjpeg/archive/refs/tags/v$(OPENJPEG_VERSION).tar.gz

clean-openjpeg:
	rm -Rf openjpeg-$(OPENJPEG_VERSION)


########################
####### netcdf #########
########################

# Depends on zstd

netcdf: $(PREFIX)/lib/libnetcdf.dylib
	touch $@

$(PREFIX)/lib/libnetcdf.dylib: netcdf-c-$(NETCDF_VERSION)/build/Makefile
	cmake --build netcdf-c-$(NETCDF_VERSION)/build
	cmake --build netcdf-c-$(NETCDF_VERSION)/build --target install

netcdf-c-$(NETCDF_VERSION)/build/Makefile: netcdf-c-$(NETCDF_VERSION)/CMakeLists.txt $(PREFIX)/lib/libzstd.dylib
	cd netcdf-c-$(NETCDF_VERSION)/build && cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$(PREFIX)" -DCMAKE_MACOSX_RPATH=ON -DCMAKE_INSTALL_RPATH="$(PREFIX)/lib" -DCMAKE_INSTALL_NAME_DIR="$(PREFIX)/lib" -DENABLE_NETCDF_4=OFF -DBUILD_UTILITIES=OFF

netcdf-c-$(NETCDF_VERSION)/CMakeLists.txt: netcdf-c-$(NETCDF_VERSION).tar.gz
	$(TAR) netcdf-c-$(NETCDF_VERSION).tar.gz
	# patch to avoid failing tests in cmake built w/o utilities <https://github.com/Unidata/netcdf-c/issues/2794>
	patch -b -d "netcdf-c-$(NETCDF_VERSION)" -p1 <patches/netcdf-test-utilities.patch
	mkdir netcdf-c-$(NETCDF_VERSION)/build
	touch $@

netcdf-c-$(NETCDF_VERSION).tar.gz:
	$(CURL) --remote-header-name https://github.com/Unidata/netcdf-c/archive/refs/tags/v$(NETCDF_VERSION).tar.gz

clean-netcdf:
	rm -Rf netcdf-c-$(NETCDF_VERSION)

check-netcdf:
	cmake --build netcdf-c-$(NETCDF_VERSION)/build --target test

#####################
####### GMP #########
#####################

# used for mpfr, cgal, sfcgal

gmp: $(PREFIX)/lib/libgmp.dylib
	touch $@

$(PREFIX)/lib/libgmp.dylib: gmp-$(GMP_VERSION)/build_arm64/.libs/libgmp.dylib gmp-$(GMP_VERSION)/build_x86_64/.libs/libgmp.dylib
	$(eval GMP_DYLIB_VERSION=$(shell ls -1 gmp-$(GMP_VERSION)/build_arm64/.libs/libgmp.*.dylib | sed -E "s/.*\.([0-9]+)\.dylib$$/\1/"))
	cd gmp-$(GMP_VERSION)/build_arm64 && lipo -create ./.libs/libgmp.${GMP_DYLIB_VERSION}.dylib ../build_x86_64/.libs/libgmp.${GMP_DYLIB_VERSION}.dylib -output ./.libs/libgmp.${GMP_DYLIB_VERSION}.dylib
	$(eval GMPXX_DYLIB_VERSION=$(shell ls -1 gmp-$(GMP_VERSION)/build_arm64/.libs/libgmpxx.*.dylib | sed -E "s/.*\.([0-9]+)\.dylib$$/\1/"))
	cd gmp-$(GMP_VERSION)/build_arm64 && lipo -create ./.libs/libgmpxx.${GMPXX_DYLIB_VERSION}.dylib ../build_x86_64/.libs/libgmpxx.${GMPXX_DYLIB_VERSION}.dylib -output ./.libs/libgmpxx.${GMPXX_DYLIB_VERSION}.dylib
	# despite documented otherwise, gmp.h differs only in __GMP_CFLAGS, try to mitigate that...
	sed -i '' -E 's/^(#define __GMP_CFLAGS.*-arch arm64)(.*)$$/\1 -arch x86_64\2/' gmp-$(GMP_VERSION)/build_arm64/gmp.h
	# to avoid dirty make targets after we touched the libraries, pretend we rebuilded everything before installing
	make -C gmp-$(GMP_VERSION)/build_arm64 --touch
	make -C gmp-$(GMP_VERSION)/build_arm64 install
	
gmp-$(GMP_VERSION)/build_arm64/.libs/libgmp.dylib: gmp-$(GMP_VERSION)/build_arm64/Makefile
	make -C gmp-$(GMP_VERSION)/build_arm64

gmp-$(GMP_VERSION)/build_x86_64/.libs/libgmp.dylib: gmp-$(GMP_VERSION)/build_x86_64/Makefile
	make -C gmp-$(GMP_VERSION)/build_x86_64

gmp-$(GMP_VERSION)/build_arm64/Makefile: gmp-$(GMP_VERSION)/configure
	cd gmp-$(GMP_VERSION)/build_arm64 && CFLAGS="$(filter-out -arch arm64 x86_64,$(CFLAGS)) -arch arm64" CXXFLAGS="$(filter-out -arch arm64 x86_64,$(CXXFLAGS)) -arch arm64" ../configure --prefix="$(PREFIX)" --disable-static --enable-fat --enable-cxx

gmp-$(GMP_VERSION)/build_x86_64/Makefile: gmp-$(GMP_VERSION)/configure
	#westmere is what rosetta2 emulates (see arch -x86_64 ./config.guess). macOS 13 runs on hardware as old as core2, enable-fat should take care of the differences. 17.7.0 is the kernel of 10.13.6
	cd gmp-$(GMP_VERSION)/build_x86_64 && CFLAGS="$(filter-out -arch arm64 x86_64,$(CFLAGS)) -arch x86_64" CXXFLAGS="$(filter-out -arch arm64 x86_64,$(CXXFLAGS)) -arch x86_64" ../configure --prefix="$(PREFIX)" --disable-static --enable-fat --enable-cxx --host=westmere-apple-darwin17.7.0

gmp-$(GMP_VERSION)/configure: gmp-$(GMP_VERSION).tar.xz
	$(TAR) gmp-$(GMP_VERSION).tar.xz
	#once our MACOSX_DEPLOYMENT_TARGET reaches 11, there is likely another patch required, see https://github.com/Homebrew/homebrew-core/commit/7cf2fcadd549686a715678f0f75a0aacbe33ccd3
	mkdir gmp-$(GMP_VERSION)/build_x86_64
	mkdir gmp-$(GMP_VERSION)/build_arm64
	touch $@

gmp-$(GMP_VERSION).tar.xz:
	$(CURL) https://gmplib.org/download/gmp/gmp-$(GMP_VERSION).tar.xz

clean-gmp:
	rm -Rf gmp-$(GMP_VERSION)

check-gmp:
	make -C gmp-$(GMP_VERSION)/build_arm64 check


######################
####### MPFR #########
######################

# used for cgal and sfcgal
# uses gmp

mpfr: $(PREFIX)/lib/libmpfr.dylib
	touch $@

$(PREFIX)/lib/libmpfr.dylib: mpfr-$(MPFR_VERSION)/build_arm64/src/.libs/libmpfr.dylib mpfr-$(MPFR_VERSION)/build_x86_64/src/.libs/libmpfr.dylib
	$(eval MPFR_DYLIB_VERSION=$(shell ls -1 mpfr-$(MPFR_VERSION)/build_arm64/src/.libs/libmpfr.*.dylib | sed -E "s/.*\.([0-9]+)\.dylib$$/\1/"))
	cd mpfr-$(MPFR_VERSION)/build_arm64 && lipo -create ./src/.libs/libmpfr.${MPFR_DYLIB_VERSION}.dylib ../build_x86_64/src/.libs/libmpfr.${MPFR_DYLIB_VERSION}.dylib -output ./src/.libs/libmpfr.${MPFR_DYLIB_VERSION}.dylib
	cd mpfr-$(MPFR_VERSION)/build_arm64 && lipo -create ./src/.libs/libmpfr.a ../build_x86_64/src/.libs/libmpfr.a -output ./src/.libs/libmpfr.a
	make -C mpfr-$(MPFR_VERSION)/build_arm64 install

mpfr-$(MPFR_VERSION)/build_arm64/src/.libs/libmpfr.dylib: mpfr-$(MPFR_VERSION)/build_arm64/Makefile
	make -C mpfr-$(MPFR_VERSION)/build_arm64
	
mpfr-$(MPFR_VERSION)/build_x86_64/src/.libs/libmpfr.dylib: mpfr-$(MPFR_VERSION)/build_x86_64/Makefile
	make -C mpfr-$(MPFR_VERSION)/build_x86_64

mpfr-$(MPFR_VERSION)/build_arm64/Makefile: mpfr-$(MPFR_VERSION)/configure $(PREFIX)/lib/libgmp.dylib
	cd mpfr-$(MPFR_VERSION)/build_arm64 && CFLAGS="$(filter-out -arch arm64 x86_64,$(CFLAGS)) -arch arm64" ../configure --prefix="$(PREFIX)" --disable-dependency-tracking --with-gmp="$(PREFIX)"

mpfr-$(MPFR_VERSION)/build_x86_64/Makefile: mpfr-$(MPFR_VERSION)/configure $(PREFIX)/lib/libgmp.dylib
	#darwin17.7.0 is the kernel of 10.13.6
	cd mpfr-$(MPFR_VERSION)/build_x86_64 && CFLAGS="$(filter-out -arch arm64 x86_64,$(CFLAGS)) -arch x86_64" ../configure --prefix="$(PREFIX)" --disable-dependency-tracking --with-gmp="$(PREFIX)" --host=x86_64-apple-darwin17.7.0

mpfr-$(MPFR_VERSION)/configure: mpfr-$(MPFR_VERSION).tar.xz
	$(TAR) mpfr-$(MPFR_VERSION).tar.xz
	mkdir mpfr-$(MPFR_VERSION)/build_arm64
	mkdir mpfr-$(MPFR_VERSION)/build_x86_64
	touch $@

mpfr-$(MPFR_VERSION).tar.xz:
	$(CURL) https://www.mpfr.org/mpfr-$(MPFR_VERSION)/mpfr-$(MPFR_VERSION).tar.xz

clean-mpfr:
	rm -Rf mpfr-$(MPFR_VERSION)
	
check-mpfr:
	make -C mpfr-$(MPFR_VERSION)/build_arm64 check


#######################
####### BOOST #########
#######################

# used for cgal and sfcgal
# uses icu (disabled), zstd (?), python (?)

boost: $(PREFIX)/lib/libboost_system.dylib
	touch $@

$(PREFIX)/lib/libboost_system.dylib: boost_$(BOOST_VERSION)/b2
	cd boost_$(BOOST_VERSION) && ./b2 architecture=arm+x86 install
	# till we find a way to pass flags controlling to use of RPATHs to cmake through the B2 system, we fix RPATHs manually after installing
	install_name_tool -id $(PREFIX)/lib/libboost_system.dylib $(PREFIX)/lib/libboost_system.dylib
	install_name_tool -id $(PREFIX)/lib/libboost_thread.dylib $(PREFIX)/lib/libboost_thread.dylib
	install_name_tool -id $(PREFIX)/lib/libboost_serialization.dylib $(PREFIX)/lib/libboost_serialization.dylib
	install_name_tool -id $(PREFIX)/lib/libboost_wserialization.dylib $(PREFIX)/lib/libboost_wserialization.dylib 
	install_name_tool -change @rpath/libboost_serialization.dylib $(PREFIX)/lib/libboost_serialization.dylib $(PREFIX)/lib/libboost_wserialization.dylib

boost_$(BOOST_VERSION)/b2: boost_$(BOOST_VERSION)/bootstrap.sh $(PREFIX)/lib/libzstd.dylib
	#ToDo: evaluate the nedded libraries, see sfcgal/CMakeList.txt from Line 75
	cd boost_$(BOOST_VERSION) && ./bootstrap.sh --prefix="$(BUILD_PREFIX)" --exec-prefix="$(PREFIX)" --without-icu --with-libraries=thread,system,serialization

boost_$(BOOST_VERSION)/bootstrap.sh: boost_$(BOOST_VERSION).tar.bz2
	$(TAR) boost_$(BOOST_VERSION).tar.bz2
	touch $@

boost_$(BOOST_VERSION).tar.bz2:
	$(CURL) https://boostorg.jfrog.io/artifactory/main/release/$(subst _,.,$(BOOST_VERSION))/source/boost_$(BOOST_VERSION).tar.bz2

clean-boost:
	rm -Rf boost_$(BOOST_VERSION)


######################
####### CGAL #########
######################

# used for sfcgal
# uses boost, gmp, mpfr when building - we use it as header only library

cgal: cgal-$(CGAL_VERSION)/include/CGAL
	touch $@

cgal-$(CGAL_VERSION)/include/CGAL: CGAL-$(CGAL_VERSION).tar.xz
	$(TAR) cgal-$(CGAL_VERSION).tar.xz
	touch $@

CGAL-$(CGAL_VERSION).tar.xz:
	$(CURL) https://github.com/CGAL/cgal/releases/download/v$(CGAL_VERSION)/CGAL-$(CGAL_VERSION).tar.xz

clean-cgal:
	rm -Rf CGAL-$(CGAL_VERSION)


######################
####### sfcgal #######
######################

# used for gdal, postgis
# uses cgal, boost, gmp, mpfr

sfcgal: $(PREFIX)/lib/libSFCGAL.dylib
	touch $@

$(PREFIX)/lib/libSFCGAL.dylib: SFCGAL-v$(SFCGAL_VERSION)/Makefile
	make -C SFCGAL-v$(SFCGAL_VERSION)
	make -C SFCGAL-v$(SFCGAL_VERSION) install

SFCGAL-v$(SFCGAL_VERSION)/Makefile: SFCGAL-v$(SFCGAL_VERSION)/CMakeLists.txt cgal-$(CGAL_VERSION)/include/CGAL $(PREFIX)/lib/libboost_system.dylib $(PREFIX)/lib/libmpfr.dylib $(PREFIX)/lib/libgmp.dylib
	cd SFCGAL-v$(SFCGAL_VERSION) && GMP_DIR=$(PREFIX)/lib/ MPFR_DIR=$(PREFIX)/lib/ CGAL_DIR=../cgal-$(CGAL_VERSION) BOOST_ROOT=$(BUILD_PREFIX) cmake . -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$(PREFIX)" -DCMAKE_MACOSX_RPATH=ON -DCMAKE_INSTALL_RPATH="$(PREFIX)/lib" -DCMAKE_INSTALL_NAME_DIR="$(PREFIX)/lib"

SFCGAL-v$(SFCGAL_VERSION)/CMakeLists.txt: SFCGAL-v$(SFCGAL_VERSION).tar.gz
	$(TAR) SFCGAL-v$(SFCGAL_VERSION).tar.gz
	touch $@

SFCGAL-v$(SFCGAL_VERSION).tar.gz:
	$(CURL) https://gitlab.com/Oslandia/SFCGAL/-/archive/v$(SFCGAL_VERSION)/SFCGAL-v$(SFCGAL_VERSION).tar.gz

clean-sfcgal:
	rm -Rf SFCGAL-v$(SFCGAL_VERSION)


#########################
###### PostGIS ##########
#########################

#depends on libgdal, libgeos, libjpeg, postgresql, json-c, protobuf-c, sfcgal

PCRE_INCLUDE_PATH=$(shell pwd)/include

postgis: $(PREFIX)/lib/postgresql/postgis-$(POSTGIS_MAJOR_VERSION).dylib
	touch $@

$(PREFIX)/lib/postgresql/postgis-$(POSTGIS_MAJOR_VERSION).dylib: postgis-${POSTGIS_VERSION}/GNUMakefile
	make -C postgis-${POSTGIS_VERSION}
	make -C postgis-${POSTGIS_VERSION} cheatsheets
	make -C postgis-${POSTGIS_VERSION} install
	make -C postgis-${POSTGIS_VERSION}/doc cheatsheet-install

postgis-${POSTGIS_VERSION}/GNUMakefile: postgis-${POSTGIS_VERSION}/configure $(PREFIX)/lib/libgdal.dylib $(PREFIX)/lib/libgeos.dylib $(PREFIX)/lib/libjpeg.dylib $(PREFIX)/bin/psql $(PREFIX)/lib/libjson-c.dylib $(PREFIX)/lib/libprotobuf-c.dylib $(PREFIX)/lib/libSFCGAL.dylib
	cd postgis-${POSTGIS_VERSION} && ./configure --prefix="$(PREFIX)" --with-pgconfig="$(PREFIX)/bin/pg_config" --with-geosconfig="$(PREFIX)/bin/geos-config" --with-projdir="$(PREFIX)" --with-gdalconfig="$(PREFIX)"/bin/gdal-config --with-jsondir="$(PREFIX)" --with-protobufdir="$(PREFIX)" --with-sfcgal="$(PREFIX)/bin/sfcgal-config" --enable-lto PCRE_CFLAGS="-I$(PCRE_INCLUDE_PATH)" PCRE_LIBS="-lpcre" 
	touch $@

postgis-${POSTGIS_VERSION}/configure: postgis-${POSTGIS_VERSION}.tar.gz
	$(TAR) $<
	touch $@

postgis-${POSTGIS_VERSION}.tar.gz:
	$(CURL) "https://download.osgeo.org/postgis/source/postgis-${POSTGIS_VERSION}.tar.gz"

clean-postgis:
	rm -Rf postgis-${POSTGIS_VERSION}


##########################
######## PLV8 ############
##########################

plv8: $(PREFIX)/lib/postgresql/plv8.dylib
	touch $@

$(PREFIX)/lib/postgresql/plv8.dylib: plv8-${PLV8_VERSION}/Makefile $(PREFIX)/bin/psql
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

wal2json: $(PREFIX)/lib/postgresql/wal2json.dylib
	touch $@

$(PREFIX)/lib/postgresql/wal2json.dylib: wal2json-${WAL2JSON_VERSION}/Makefile $(PREFIX)/bin/psql
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

pldebugger: $(PREFIX)/lib/postgresql/plugin_debugger.dylib
	touch $@

$(PREFIX)/lib/postgresql/plugin_debugger.dylib: pldebugger-${PLDEBUGGER_VERSION}/Makefile $(PREFIX)/bin/psql
	export PGHOME="$(PREFIX)"; export PG_CONFIG="$(PREFIX)/bin/pg_config"; export USE_PGXS=1; make -C pldebugger-${PLDEBUGGER_VERSION} install

pldebugger-${PLDEBUGGER_VERSION}/Makefile: pldebugger-${PLDEBUGGER_VERSION}.tar.gz
	$(TAR) $<
	touch $@

pldebugger-${PLDEBUGGER_VERSION}.tar.gz:
	$(CURL) --remote-header-name https://github.com/EnterpriseDB/pldebugger/archive/refs/tags/v${PLDEBUGGER_VERSION}.tar.gz

clean-pldebugger:
	rm -Rf pldebugger-${PLDEBUGGER_VERSION}


####################
##### pgvector #####
####################

pgvector: $(PREFIX)/lib/postgresql/vector.dylib
	touch $@

$(PREFIX)/lib/postgresql/vector.dylib: pgvector-${PGVECTOR_VERSION}/Makefile $(PREFIX)/bin/psql
	make -C pgvector-${PGVECTOR_VERSION}
	make -C pgvector-${PGVECTOR_VERSION} install

pgvector-${PGVECTOR_VERSION}/Makefile: pgvector-${PGVECTOR_VERSION}.tar.gz
	$(TAR) $<
	touch $@

pgvector-${PGVECTOR_VERSION}.tar.gz:
	$(CURL) --remote-header-name https://github.com/pgvector/pgvector/archive/refs/tags/v${PGVECTOR_VERSION}.tar.gz

clean-pgvector:
	rm -Rf pgvector-${PGVECTOR_VERSION}

check-pgvector:
	! $(PREFIX)/bin/pg_ctl status -D "$(BUILD_PREFIX)/run" || $(PREFIX)/bin/pg_ctl stop -D "$(BUILD_PREFIX)/run"
	rm -Rf "$(BUILD_PREFIX)/run"
	$(PREFIX)/bin/initdb -D "$(BUILD_PREFIX)/run" --encoding=UTF-8 --locale=en_US.UTF-8
	$(PREFIX)/bin/pg_ctl start -D "$(BUILD_PREFIX)/run" -l "$(BUILD_PREFIX)/run/postgresql.log"
	make -C pgvector-${PGVECTOR_VERSION} installcheck || (ret=$$?; $(PREFIX)/bin/pg_ctl stop -D "$(BUILD_PREFIX)/run" && exit $$ret)
	$(PREFIX)/bin/pg_ctl stop -D "$(BUILD_PREFIX)/run"

##########################
####### pgrouting ########
##########################

# uses boost

pgrouting: $(PREFIX)/lib/postgresql/libpgrouting-$(PGROUTING_VERSION_MAJOR).dylib
	touch $@

$(PREFIX)/lib/postgresql/libpgrouting-$(PGROUTING_VERSION_MAJOR).dylib: pgrouting-$(PGROUTING_VERSION)/build/Makefile
	make -C pgrouting-$(PGROUTING_VERSION)/build install
	# pgrouting didn't yet get the notice, the DLSUFFIX has changed in pg16
	mv $(PREFIX)/lib/postgresql/libpgrouting-$(PGROUTING_VERSION_MAJOR).so $(PREFIX)/lib/postgresql/libpgrouting-$(PGROUTING_VERSION_MAJOR).dylib

pgrouting-$(PGROUTING_VERSION)/build/Makefile: pgrouting-$(PGROUTING_VERSION)/CMakeLists.txt $(PREFIX)/lib/libboost_system.dylib $(PREFIX)/bin/psql
	cd pgrouting-$(PGROUTING_VERSION)/build && cmake .. -DCMAKE_BUILD_TYPE=Release -DWITH_DOC=OFF -DBUILD_MAN=ON -DBUILD_HTML=OFF -DBUILD_DOXY=OFF -DCMAKE_INSTALL_PREFIX="$(PREFIX)" -DCMAKE_MACOSX_RPATH=ON -DCMAKE_INSTALL_RPATH="$(PREFIX)/lib" -DCMAKE_INSTALL_NAME_DIR="$(PREFIX)/lib"

pgrouting-$(PGROUTING_VERSION)/CMakeLists.txt: pgrouting-$(PGROUTING_VERSION).tar.gz
	$(TAR) pgrouting-$(PGROUTING_VERSION).tar.gz
	mkdir pgrouting-$(PGROUTING_VERSION)/build
	touch $@

pgrouting-$(PGROUTING_VERSION).tar.gz:
	$(CURL) https://github.com/pgRouting/pgrouting/releases/download/v$(PGROUTING_VERSION)/pgrouting-$(PGROUTING_VERSION).tar.gz

clean-pgrouting:
	rm -Rf pgrouting-$(PGROUTING_VERSION)


################
##### pljs #####
################

pljs: $(PREFIX)/lib/postgresql/pljs.dylib
	touch $@

$(PREFIX)/lib/postgresql/pljs.dylib: pljs-${PLJS_VERSION}/Makefile $(PREFIX)/bin/psql
	cd pljs-${PLJS_VERSION} && make
	make -C pljs-${PLJS_VERSION} install

pljs-${PLJS_VERSION}/Makefile: pljs-${PLJS_VERSION}.tar.gz quickjs-${QUICKJS_VERSION}.tar.xz
	$(TAR) $<
	# fix an error in 0.8.0 release https://github.com/plv8/pljs/commit/21f22971e325055941440b7983cfd1e3d49d41fe
	patch -b -d "pljs-${PLJS_VERSION}" -p1 < patches/pljs-fix_0.8.0.patch
	# disable a test requiring SRFs that are not yet implemented
	patch -b -d "pljs-${PLJS_VERSION}" -p1 < patches/pljs-disable_srf_test.patch
	# use our versioned quickjs instead of attempting to download git head in makefile
	sed -I '' "s/git submodule/#&/" pljs-${PLJS_VERSION}/Makefile
	$(TAR) quickjs-${QUICKJS_VERSION}.tar.xz
	cp -a quickjs-${QUICKJS_VERSION}/ pljs-${PLJS_VERSION}/deps/quickjs
	touch $@

pljs-${PLJS_VERSION}.tar.gz:
	$(CURL) --remote-header-name https://github.com/plv8/pljs/archive/refs/tags/v${PLJS_VERSION}.tar.gz
	
quickjs-${QUICKJS_VERSION}.tar.xz:
	$(CURL) --remote-header-name https://bellard.org/quickjs/quickjs-${QUICKJS_VERSION}.tar.xz

clean-pljs:
	rm -Rf pljs-${PLJS_VERSION}
	rm -Rf quickjs-${QUICKJS_VERSION}

check-pljs:
	! $(PREFIX)/bin/pg_ctl status -D "$(BUILD_PREFIX)/run" || $(PREFIX)/bin/pg_ctl stop -D "$(BUILD_PREFIX)/run"
	rm -Rf "$(BUILD_PREFIX)/run"
	$(PREFIX)/bin/initdb -D "$(BUILD_PREFIX)/run" --encoding=UTF-8 --locale=en_US.UTF-8
	$(PREFIX)/bin/pg_ctl start -D "$(BUILD_PREFIX)/run" -l "$(BUILD_PREFIX)/run/postgresql.log"
	make -C pljs-${PLJS_VERSION} installcheck || (ret=$$?; $(PREFIX)/bin/pg_ctl stop -D "$(BUILD_PREFIX)/run" && exit $$ret)
	$(PREFIX)/bin/pg_ctl stop -D "$(BUILD_PREFIX)/run"


#########################
##### Tests #############
#########################

check-arch:
# This checks if all the built executables are universal binaries:
# Find all files that are named .a or executable but not named .la and not shell scripts
# execute lipo -verify_arch and if that fails, produce an output by executing lipo -info.

	find $(PREFIX) \
		\( -name "*.a" \
		-or -type f -perm -u+x \! -name "*.la" \! -exec sh -c 'test "$$(head -c2 "$$0")" == "#!"' {} \; \
		\) \! -exec lipo {} -verify_arch arm64 x86_64 \; \
		-exec lipo {} -info \; 

check-libs:
# This checks if the built executables and libraries do not link shared libraries
# from macports or homebrew:
# Find all files that are executable, check if the output of otool -L contains
# /local or /opt (errors are ignored), produce output by executing otool -L again.
	find $(PREFIX) \
		-type f -perm -u+x \
		-exec sh -c 'otool -L "$$0" | grep --silent -e "/local" -e "/opt"' {} \; \
		-exec otool -L {} \;

check-rpath:
# This checks if the built executables and libraries do not link to shared libraries
# using @rpath:
# Find all files that are executable, check if the output of otool -L contains
# @-references (errors are ignored), produce output by executing otool -L again.
	find $(PREFIX) \
		-type f -perm -u+x \
		-exec sh -c 'otool -L "$$0" | grep --silent -e "@rpath"' {} \; \
		-exec otool -L {} \;

check-python:
# This checks if the specified python version is installed and is universal
	$(PYTHON) -V | grep -q $(PYTHON_VERSION_FULL) && lipo $(PYTHON) -verify_arch arm64 x86_64
	