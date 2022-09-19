#!/bin/bash

#  CopyBinariesScript.sh
#  Postgres
#
#  Created by Jakob Egger on 31/08/2016.
#  Copyright © 2016 postgresapp. All rights reserved.

set -e
set -o pipefail

TARGET_VERSIONS_DIR="$BUILT_PRODUCTS_DIR/$CONTENTS_FOLDER_PATH/Versions"

cd "$PG_BINARIES_DIR"

for VERSION in ${PG_BINARIES_VERSIONS//_/ }
do
	if [ ! -e "${TARGET_VERSIONS_DIR}/${VERSION}" ]
	then
		# copy binaries
		cd "${PG_BINARIES_DIR}/${VERSION}/bin/"
		mkdir -p "${TARGET_VERSIONS_DIR}/${VERSION}/bin/"
		# copy postgresql binaries
		cp -a clusterdb createdb createuser dropdb dropuser ecpg initdb oid2name pg_* pgbench postgres postmaster psql reindexdb vacuumdb vacuumlo "${TARGET_VERSIONS_DIR}/${VERSION}/bin/"
        if [ -e createlang ]
        then
            # removed in PostgreSQL 10
            cp -a createlang droplang "${TARGET_VERSIONS_DIR}/${VERSION}/bin/"
        fi
		# copy proj binaries
		cp -a cs2cs geod invgeod invproj proj "${TARGET_VERSIONS_DIR}/${VERSION}/bin/"
		# copy gdal binaries
		cp -a gdal* nearblack ogr* "${TARGET_VERSIONS_DIR}/${VERSION}/bin/"
        if [ -e testepsg ]
        then
			# testepsg was removed in GDAL 3.5, see https://github.com/OSGeo/gdal/pull/3992
            cp -a testepsg "${TARGET_VERSIONS_DIR}/${VERSION}/bin/"
        fi
		# copy postgis binaries
		cp -a pgsql2shp raster2pgsql shp2pgsql "${TARGET_VERSIONS_DIR}/${VERSION}/bin/"
        if [ -e pgtopo_export ]
        then
            # added in PostGIS 3.3
            cp -a pgtopo_export pgtopo_import "${TARGET_VERSIONS_DIR}/${VERSION}/bin/"
        fi
        
		# copy all dynamic libraries
		cd "${PG_BINARIES_DIR}/${VERSION}/lib/"
		mkdir -p "${TARGET_VERSIONS_DIR}/${VERSION}/lib/"
		cp -af *.dylib "${TARGET_VERSIONS_DIR}/${VERSION}/lib/"
		cp -afR postgresql "${TARGET_VERSIONS_DIR}/${VERSION}/lib/"
		if [ -e gdalplugins ]
		then
			# added in GDAL 3.5
			cp -af gdalplugins "${TARGET_VERSIONS_DIR}/${VERSION}/lib/"
		fi 
		
		# copy static libraries where a dynamic one doesn't exist
		for file in *.a
		do
            if [[ $file == *LLVM* ]]
            then
                continue
            fi
			if  [ ! -f "${file%.*}.dylib" ]
			then
				cp -af $file "${TARGET_VERSIONS_DIR}/${VERSION}/lib/"
			fi
		done

		# make all links within the bundle use @loader_path
		# if the binaries are signed this will break the code signature
		# you must make sure to re-sign them afterwards
		cd "${TARGET_VERSIONS_DIR}/${VERSION}"
		for file in bin/* lib/* lib/*/*
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
		
		# copy include, share
		rm -f "${TARGET_VERSIONS_DIR}/${VERSION}/include/json"
		cp -afR "${PG_BINARIES_DIR}/${VERSION}/include" "${PG_BINARIES_DIR}/${VERSION}/share" "${TARGET_VERSIONS_DIR}/${VERSION}/"
	fi
done

# create symbolic link
cd "$BUILT_PRODUCTS_DIR/$CONTENTS_FOLDER_PATH/Versions/"
ln -sfh ${LATEST_STABLE_PG_VERSION} latest
