#!/bin/bash

SCRIPT=$(readlink -f $0)
BASEDIR=`dirname $SCRIPT`/..

JADRETRO=$BASEDIR/tools/jadretro.jar
# No linux version for this :(
JAD="wine $BASEDIR/tools/jad.exe"

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

OUTPUT=$BASEDIR/minecraft_server.src.zip
OUTPUT_TMP=$$.tmp
OUTPUT_TMP2=$$.tmp2

echo "Unpacking $SERVER"
mkdir $OUTPUT_TMP
unzip -d $OUTPUT_TMP $SERVER > /dev/null 2>&1

echo "Preparing classfiles with jadretro"
java -jar $JADRETRO $OUTPUT_TMP/*{,/*{,/*{,/*}}}/ > /dev/null 2>&1

echo "Decompiling with jad"
mkdir $OUTPUT_TMP2
$JAD -ff -nonlb -dead -o -r -s .java -d $OUTPUT_TMP2 `find $OUTPUT_TMP -name '*.class' -print` > /dev/null 2>&1
rm -rf $OUTPUT_TMP

echo "Creating source zip"
pushd $OUTPUT_TMP2 > /dev/null
zip -r $OUTPUT * > /dev/null 2>&1
popd > /dev/null

rm -rf $OUTPUT_TMP2
echo; echo "New decompiled minecraft_server.src.zip: $OUTPUT"
