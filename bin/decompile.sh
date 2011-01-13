#!/bin/bash

set -e

SCRIPT=$(readlink -f $0)
BASEDIR=`dirname $SCRIPT`/..

JADRETRO=$BASEDIR/tools/jadretro.jar
# No linux version for this :(
JAD="wine $BASEDIR/tools/jad.exe"

JACOBE=$BASEDIR/tools/jacobe
JACOBECFG=$BASEDIR/tools/jacobe.cfg

SERVER=$BASEDIR/minecraft_server.jar

if [[ $# -ge 1 ]]; then
    SERVER=$1
    echo "Custom server: $SERVER"
else
    echo "Default server: $SERVER"
fi

if [[ ! -e $SERVER ]]; then
    echo; echo "ERROR: Server: $SERVER doesn't exist";
    exit 0;
fi

# Dynamicly find the server version
PATCH=$BASEDIR/patch/`unzip -p $SERVER net/minecraft/server/MinecraftServer.class | strings | grep 'server version' | sed -e 's/^[^0-9]*//' -e 's/_.*//'`.patch

OUTPUT=$BASEDIR/minecraft_server.src.zip
OUTPUT_TMP=$$.tmp
OUTPUT_TMP2=$$.tmp2

echo "Unpacking $SERVER"
mkdir $OUTPUT_TMP
unzip -d $OUTPUT_TMP $SERVER

echo "Preparing classfiles with jadretro"
java -jar $JADRETRO `find $OUTPUT_TMP -name '*.class' -print`

echo "Decompiling with jad"
mkdir $OUTPUT_TMP2
$JAD -safe -ff -nonlb -dead -o -r -s .java -d $OUTPUT_TMP2 `find $OUTPUT_TMP -name '*.class' -print`
rm -rf $OUTPUT_TMP

echo "Applying patch to fix some decompilation issues"
patch -d $OUTPUT_TMP2 -p1 < $PATCH

echo "Reformatting source";
$JACOBE -cfg=$JACOBECFG -nobackup -overwrite -outext=java $OUTPUT_TMP2/net/minecraft/server/*.java

echo "Removing comments and excess newlines"
perl -i -nlpe'BEGIN { $/ = undef }; s#^// .*\n##gm; s/\r//g; s/\n{2,}/\n\n/g; s/(^\n*|\n*$)//gs; s/\n\s+( implements )/$1/gs; s/(, )\n\s+/$1/gs; s/\(Object\) //g; s/(\})\n{2,}(\s*\})/$1\n$2/gs; s/(\})\n{2,}(\s*\})/$1\n$2/gs;' $OUTPUT_TMP2/net/minecraft/server/*.java

echo "Creating source zip"
pushd $OUTPUT_TMP2 > /dev/null
if [[ -e $OUTPUT ]]; then rm -rf $OUTPUT; fi
zip -r $OUTPUT * > /dev/null 2>&1
popd > /dev/null

rm -rf $OUTPUT_TMP2
echo; echo "New decompiled minecraft_server.src.zip: $OUTPUT"
