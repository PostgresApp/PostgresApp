#!/bin/bash

#  CopyBinariesScript.sh
#  Postgres
#
#  Created by Jakob Egger on 31/08/2016.
#  Copyright © 2016 postgresapp. All rights reserved.

set -e
set -o pipefail

TARGET_VERSIONS_DIR="$BUILT_PRODUCTS_DIR/$CONTENTS_FOLDER_PATH/Versions"

for VERSION in ${PG_BINARIES_VERSIONS//_/ }
do
	if [ -e "${TARGET_VERSIONS_DIR}/${VERSION}" ]
	then
		rm -r "${TARGET_VERSIONS_DIR}/${VERSION}"
	fi
	if [ ! -e "${PG_BINARIES_DIR}/${VERSION}.zip" ]
	then
		echo >&2 "Binaries Archive not found. CopyBinaries.sh expected to find a ZIP archive of the binaries at ${PG_BINARIES_DIR}/${VERSION}.zip"
		exit 1
	fi
	
	
	# Core PostgreSQL tools
	unzip "${PG_BINARIES_DIR}/${VERSION}.zip" -d "${TARGET_VERSIONS_DIR}" "${VERSION}/bin/clusterdb"
	unzip "${PG_BINARIES_DIR}/${VERSION}.zip" -d "${TARGET_VERSIONS_DIR}" "${VERSION}/bin/createdb"
	unzip "${PG_BINARIES_DIR}/${VERSION}.zip" -d "${TARGET_VERSIONS_DIR}" "${VERSION}/bin/createuser"
	unzip "${PG_BINARIES_DIR}/${VERSION}.zip" -d "${TARGET_VERSIONS_DIR}" "${VERSION}/bin/dropdb"
	unzip "${PG_BINARIES_DIR}/${VERSION}.zip" -d "${TARGET_VERSIONS_DIR}" "${VERSION}/bin/dropuser"
	unzip "${PG_BINARIES_DIR}/${VERSION}.zip" -d "${TARGET_VERSIONS_DIR}" "${VERSION}/bin/ecpg"
	unzip "${PG_BINARIES_DIR}/${VERSION}.zip" -d "${TARGET_VERSIONS_DIR}" "${VERSION}/bin/initdb"
	unzip "${PG_BINARIES_DIR}/${VERSION}.zip" -d "${TARGET_VERSIONS_DIR}" "${VERSION}/bin/oid2name"
	unzip "${PG_BINARIES_DIR}/${VERSION}.zip" -d "${TARGET_VERSIONS_DIR}" "${VERSION}/bin/pg_*"
	unzip "${PG_BINARIES_DIR}/${VERSION}.zip" -d "${TARGET_VERSIONS_DIR}" "${VERSION}/bin/pgbench"
	unzip "${PG_BINARIES_DIR}/${VERSION}.zip" -d "${TARGET_VERSIONS_DIR}" "${VERSION}/bin/postgres"
	unzip "${PG_BINARIES_DIR}/${VERSION}.zip" -d "${TARGET_VERSIONS_DIR}" "${VERSION}/bin/psql"
	unzip "${PG_BINARIES_DIR}/${VERSION}.zip" -d "${TARGET_VERSIONS_DIR}" "${VERSION}/bin/reindexdb"
	unzip "${PG_BINARIES_DIR}/${VERSION}.zip" -d "${TARGET_VERSIONS_DIR}" "${VERSION}/bin/vacuumdb"
	unzip "${PG_BINARIES_DIR}/${VERSION}.zip" -d "${TARGET_VERSIONS_DIR}" "${VERSION}/bin/vacuumlo"
	unzip "${PG_BINARIES_DIR}/${VERSION}.zip" -d "${TARGET_VERSIONS_DIR}" "${VERSION}/bin/createlang" || true # removed in PostgreSQL 10
	unzip "${PG_BINARIES_DIR}/${VERSION}.zip" -d "${TARGET_VERSIONS_DIR}" "${VERSION}/bin/droplang" || true # removed in PostgreSQL 10
	unzip "${PG_BINARIES_DIR}/${VERSION}.zip" -d "${TARGET_VERSIONS_DIR}" "${VERSION}/bin/postmaster" || true # removed in PostgreSQL 16
	
	# PostGIS related tools
	unzip "${PG_BINARIES_DIR}/${VERSION}.zip" -d "${TARGET_VERSIONS_DIR}" "${VERSION}/bin/cct" || test $IGNORE_MISSING_BINARIES
	unzip "${PG_BINARIES_DIR}/${VERSION}.zip" -d "${TARGET_VERSIONS_DIR}" "${VERSION}/bin/cs2cs" || test $IGNORE_MISSING_BINARIES
	unzip "${PG_BINARIES_DIR}/${VERSION}.zip" -d "${TARGET_VERSIONS_DIR}" "${VERSION}/bin/geod" || test $IGNORE_MISSING_BINARIES
	unzip "${PG_BINARIES_DIR}/${VERSION}.zip" -d "${TARGET_VERSIONS_DIR}" "${VERSION}/bin/invgeod" || test $IGNORE_MISSING_BINARIES
	unzip "${PG_BINARIES_DIR}/${VERSION}.zip" -d "${TARGET_VERSIONS_DIR}" "${VERSION}/bin/proj" || test $IGNORE_MISSING_BINARIES
	unzip "${PG_BINARIES_DIR}/${VERSION}.zip" -d "${TARGET_VERSIONS_DIR}" "${VERSION}/bin/invproj" || test $IGNORE_MISSING_BINARIES
	unzip "${PG_BINARIES_DIR}/${VERSION}.zip" -d "${TARGET_VERSIONS_DIR}" "${VERSION}/bin/projinfo" || true # added in proj 6.0.0
	unzip "${PG_BINARIES_DIR}/${VERSION}.zip" -d "${TARGET_VERSIONS_DIR}" "${VERSION}/bin/projsync" || true # added in proj 7.0.0
	unzip "${PG_BINARIES_DIR}/${VERSION}.zip" -d "${TARGET_VERSIONS_DIR}" "${VERSION}/bin/geosop" || true # added in geos 3.10
	unzip "${PG_BINARIES_DIR}/${VERSION}.zip" -d "${TARGET_VERSIONS_DIR}" "${VERSION}/bin/gdal*" || test $IGNORE_MISSING_BINARIES
	unzip "${PG_BINARIES_DIR}/${VERSION}.zip" -d "${TARGET_VERSIONS_DIR}" "${VERSION}/bin/nearblack" || test $IGNORE_MISSING_BINARIES
	unzip "${PG_BINARIES_DIR}/${VERSION}.zip" -d "${TARGET_VERSIONS_DIR}" "${VERSION}/bin/ogr*" || test $IGNORE_MISSING_BINARIES
	unzip "${PG_BINARIES_DIR}/${VERSION}.zip" -d "${TARGET_VERSIONS_DIR}" "${VERSION}/bin/testepsg" || true # testepsg was removed in GDAL 3.5, see https://github.com/OSGeo/gdal/pull/3992
	unzip "${PG_BINARIES_DIR}/${VERSION}.zip" -d "${TARGET_VERSIONS_DIR}" "${VERSION}/bin/sozip" || true # added in gdal 3.7.0
	unzip "${PG_BINARIES_DIR}/${VERSION}.zip" -d "${TARGET_VERSIONS_DIR}" "${VERSION}/bin/pgsql2shp" || test $IGNORE_MISSING_BINARIES
	unzip "${PG_BINARIES_DIR}/${VERSION}.zip" -d "${TARGET_VERSIONS_DIR}" "${VERSION}/bin/raster2pgsql" || test $IGNORE_MISSING_BINARIES
	unzip "${PG_BINARIES_DIR}/${VERSION}.zip" -d "${TARGET_VERSIONS_DIR}" "${VERSION}/bin/shp2pgsql" || test $IGNORE_MISSING_BINARIES
	unzip "${PG_BINARIES_DIR}/${VERSION}.zip" -d "${TARGET_VERSIONS_DIR}" "${VERSION}/bin/pgtopo_export" || true # added in PostGIS 3.3
	unzip "${PG_BINARIES_DIR}/${VERSION}.zip" -d "${TARGET_VERSIONS_DIR}" "${VERSION}/bin/pgtopo_import" || true # added in PostGIS 3.3
	unzip "${PG_BINARIES_DIR}/${VERSION}.zip" -d "${TARGET_VERSIONS_DIR}" "${VERSION}/bin/postgis" || true # added in PostGIS 3.4
	unzip "${PG_BINARIES_DIR}/${VERSION}.zip" -d "${TARGET_VERSIONS_DIR}" "${VERSION}/bin/postgis_restore" || true # added in PostGIS 3.4
	
	# Dynamic libraries
	unzip "${PG_BINARIES_DIR}/${VERSION}.zip" -d "${TARGET_VERSIONS_DIR}" "${VERSION}/lib/*.dylib" -x "${VERSION}/lib/*/*"
	unzip "${PG_BINARIES_DIR}/${VERSION}.zip" -d "${TARGET_VERSIONS_DIR}" "${VERSION}/lib/postgresql/*"
	unzip "${PG_BINARIES_DIR}/${VERSION}.zip" -d "${TARGET_VERSIONS_DIR}" "${VERSION}/lib/gdalplugins/*" || true # added in GDAL 3.5
	
	# Static libraries
	unzip "${PG_BINARIES_DIR}/${VERSION}.zip" -d "${TARGET_VERSIONS_DIR}" "${VERSION}/lib/libpgcommon.a"
	unzip "${PG_BINARIES_DIR}/${VERSION}.zip" -d "${TARGET_VERSIONS_DIR}" "${VERSION}/lib/libpgcommon_shlib.a"
	unzip "${PG_BINARIES_DIR}/${VERSION}.zip" -d "${TARGET_VERSIONS_DIR}" "${VERSION}/lib/libpgfeutils.a"
	unzip "${PG_BINARIES_DIR}/${VERSION}.zip" -d "${TARGET_VERSIONS_DIR}" "${VERSION}/lib/libpgport.a"
	unzip "${PG_BINARIES_DIR}/${VERSION}.zip" -d "${TARGET_VERSIONS_DIR}" "${VERSION}/lib/libpgport_shlib.a"
	unzip "${PG_BINARIES_DIR}/${VERSION}.zip" -d "${TARGET_VERSIONS_DIR}" "${VERSION}/lib/libpq-oauth.a" || true # added in PG 18
	
	# include, share
	unzip "${PG_BINARIES_DIR}/${VERSION}.zip" -d "${TARGET_VERSIONS_DIR}" "${VERSION}/include/*"
	unzip "${PG_BINARIES_DIR}/${VERSION}.zip" -d "${TARGET_VERSIONS_DIR}" "${VERSION}/share/*"
	
	# make all links within the bundle use @loader_path
	# if the binaries are signed this will break the code signature
	# you must make sure to re-sign them afterwards
	cd "${TARGET_VERSIONS_DIR}/${VERSION}"
	for file in $(find lib bin -perm +111 -type f)
	do
	  if [[ -f $file && ! -L $file ]]
	  then
		echo $file
		otool -L $file | sed '/:$/d;s/ [(].*$//;s/^\s+//' | sort | uniq | while read line
		do
		  if [[ ! $line == *"$file" && $line == /Applications/Postgres.app/Contents/Versions/* ]]
		  then
			basename=${line#/Applications/Postgres.app/Contents/Versions/*/lib/}
			if [[ $file == bin/* ]]
			then
			  newname=@loader_path/../lib/$basename
			elif [[ $file == lib/*/*/*/*/*/*/* ]]
			then
			  newname=@loader_path/../../../../../../$basename
			elif [[ $file == lib/*/*/*/*/*/* ]]
			then
			  newname=@loader_path/../../../../../$basename
			elif [[ $file == lib/*/*/*/*/* ]]
			then
			  newname=@loader_path/../../../../$basename
			elif [[ $file == lib/*/*/*/* ]]
			then
			  newname=@loader_path/../../../$basename
			elif [[ $file == lib/*/*/* ]]
			then
			  newname=@loader_path/../../$basename
			elif [[ $file == lib/*/* ]]
			then
			  newname=@loader_path/../$basename
			elif [[ $file == lib/* ]]
			then
			  newname=@loader_path/$basename
			else
			  newname=$file
			fi
			echo install_name_tool "$file" -change $line $newname
			install_name_tool "$file" -change $line $newname
		  fi
		done
	  fi
	done
done

# create symbolic link
if [ -n "$LATEST_STABLE_PG_VERSION" ];
then
    cd "$BUILT_PRODUCTS_DIR/$CONTENTS_FOLDER_PATH/Versions/"
	test -e "$LATEST_STABLE_PG_VERSION" || (echo "LATEST_STABLE_PG_VERSION ($LATEST_STABLE_PG_VERSION) does not exist"; exit 1)
    ln -sfh ${LATEST_STABLE_PG_VERSION} latest
fi
