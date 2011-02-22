#!/bin/bash

SCRIPT=$(readlink -f $0)
BASEDIR=`dirname $SCRIPT`/..

REPO=$BASEDIR/repo

rm -rf $REPO; mkdir $REPO; pushd $REPO; git init; popd;

for server in $BASEDIR/server/minecraft_server.0.2.1.jar \
$BASEDIR/server/minecraft_server.0.2.1_00.jar \
$BASEDIR/server/minecraft_server.0.2.2.jar \
$BASEDIR/server/minecraft_server.0.2.2_01.jar \
$BASEDIR/server/minecraft_server.0.2.3.jar \
$BASEDIR/server/minecraft_server.0.2.4.jar \
$BASEDIR/server/minecraft_server.0.2.5.jar \
$BASEDIR/server/minecraft_server.0.2.5_00.jar \
$BASEDIR/server/minecraft_server.0.2.5_01.jar \
$BASEDIR/server/minecraft_server.0.2.5_02.jar \
$BASEDIR/server/minecraft_server.0.2.6.jar \
$BASEDIR/server/minecraft_server.0.2.6_01.jar \
$BASEDIR/server/minecraft_server.0.2.6_02.jar \
$BASEDIR/server/minecraft_server.0.2.7.jar \
$BASEDIR/server/minecraft_server.0.2.8.jar \
$BASEDIR/server/minecraft_server.1.1_02.jar \
$BASEDIR/server/minecraft_server.1.2.jar \
$BASEDIR/server/minecraft_server.1.2_01.jar \
$BASEDIR/server/minecraft_server.1.3.jar \
$BASEDIR/server/minecraft_server.1.3_00.jar \
; \

do \
    V=`echo $server | sed -e 's/^[^0-9]*//' -e 's/[.][^.]*$//'`; \
    bin/rename.sh $server; bin/decompile.sh; \
    pushd $REPO; git rm -rf *; unzip $BASEDIR/minecraft_server.src.zip; cp $BASEDIR/devbin/README.copyright README.md; git add .; git commit -m$V; popd; \
    #read -sn 1 -p "Press any key to continue..."
done;
