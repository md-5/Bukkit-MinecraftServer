#!/bin/bash

set -e

SCRIPT=$(readlink -f $0)
BASEDIR=`dirname $SCRIPT`/..

FERN="java -jar $BASEDIR/tools/fernflower.jar"

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

OUTPUT=$BASEDIR/minecraft_server.src.zip
OUTPUT_TMP=$$.tmp

$FERN -dgs=1 -hdc=0 -das=0 $SERVER $OUTPUT_TMP

unzip -d $OUTPUT_TMP $OUTPUT_TMP/`basename $SERVER`
rm $OUTPUT_TMP/`basename $SERVER`

echo "Reformatting source";
$JACOBE -cfg=$JACOBECFG -nobackup -overwrite -outext=java $OUTPUT_TMP/net/minecraft/server/*.java

echo "Removing comments and excess newlines"
perl -i -nlpe'BEGIN { $/ = undef; use Encode; }; $_ = Encode::decode( "utf8", $_ ); s#^import net.minecraft.server.*?;$##gm; s#^\s*// .*\n#\n#gm; s/\r//g; s/\n{2,}/\n\n/g; s/(^\n*|\n*$)//gs; s/\n\s+( implements )/$1/gs; s/(, )\n\s+/$1/gs; s/\(Object\) //g; s/(\})\n{2,}(\s*\})/$1\n$2/gs; s/(\})\n{2,}(\s*\})/$1\n$2/gs; s/([\x80-\xff])/sprintf "\\u%04X",ord($1)/eg;' $OUTPUT_TMP/net/minecraft/server/*.java

echo "Renaming variables"
for i in $OUTPUT_TMP/net/minecraft/server/*.java; do perl $BASEDIR/tools/var_rename.pl $i && mv $i.new $i; done

echo "Creating source zip"
pushd $OUTPUT_TMP > /dev/null
if [[ -e $OUTPUT ]]; then rm -rf $OUTPUT; fi
zip -r $OUTPUT * > /dev/null 2>&1
popd > /dev/null

rm -rf $OUTPUT_TMP
echo; echo "New decompiled minecraft_server.src.zip: $OUTPUT"
