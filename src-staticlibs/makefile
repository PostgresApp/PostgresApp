POSTGRES_VERSION=17.4
POSTGRES_DOWNLOAD_URL=https://ftp.postgresql.org/pub/source/v$(POSTGRES_VERSION)

# compiler options
MACOSX_DEPLOYMENT_TARGET=10.15
CFLAGS=-arch arm64 -arch x86_64 -mmacosx-version-min=10.15 -g -Os
CXXFLAGS=-arch arm64 -arch x86_64 -mmacosx-version-min=10.15 -g -Os

export CFLAGS CXXFLAGS MACOSX_DEPLOYMENT_TARGET

# command shortcuts
CURL=/usr/bin/curl -L10 --silent --show-error --remote-name
TAR=/usr/bin/tar xzf

all: postgresql

clean: clean-postgresql

download: postgresql-$(POSTGRES_VERSION).tar.bz2

#########################
###### PostgreSQL #######
#########################

postgresql: libpq.a postgres_ext.h libpq-fe.h pg_config_ext.h

postgres_ext.h: postgresql-$(POSTGRES_VERSION)/GNUmakefile
	cp postgresql-$(POSTGRES_VERSION)/src/include/postgres_ext.h postgres_ext.h

pg_config_ext.h: postgresql-$(POSTGRES_VERSION)/GNUmakefile
	cp postgresql-$(POSTGRES_VERSION)/src/include/pg_config_ext.h pg_config_ext.h

libpq-fe.h: postgresql-$(POSTGRES_VERSION)/GNUmakefile
	cp postgresql-$(POSTGRES_VERSION)/src/interfaces/libpq/libpq-fe.h libpq-fe.h

libpq.a: postgresql-$(POSTGRES_VERSION)/GNUmakefile
	MAKELEVEL=0 make -C postgresql-$(POSTGRES_VERSION)/src/interfaces/libpq all-static-lib
	cp postgresql-$(POSTGRES_VERSION)/src/interfaces/libpq/libpq.a postgresql-$(POSTGRES_VERSION)/src/port/libpgport.a postgresql-$(POSTGRES_VERSION)/src/common/libpgcommon.a postgresql-$(POSTGRES_VERSION)/src/common/libpgcommon_shlib.a .

postgresql-$(POSTGRES_VERSION)/GNUmakefile: postgresql-$(POSTGRES_VERSION)/configure
	cd "postgresql-$(POSTGRES_VERSION)" && export PATH="$(PREFIX)/bin:$$PATH" && ./configure --prefix=$(CURDIR)/install --without-icu

postgresql-$(POSTGRES_VERSION)/configure: postgresql-$(POSTGRES_VERSION).tar.bz2
	$(TAR) "postgresql-$(POSTGRES_VERSION).tar.bz2"
	touch $@

postgresql-$(POSTGRES_VERSION).tar.bz2:
	$(CURL) "$(POSTGRES_DOWNLOAD_URL)/postgresql-$(POSTGRES_VERSION).tar.bz2"

clean-postgresql:
	rm -Rf postgresql-$(POSTGRES_VERSION)
