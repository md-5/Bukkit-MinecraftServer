#!/bin/bash

SCRIPT=$(readlink -f $0)
BASEDIR=`dirname $SCRIPT`/..

JARJAR=$BASEDIR/tools/jarjar.jar

SERVER=$BASEDIR/server/minecraft_server.jar
RULES=$BASEDIR/rules/latest.rules
NAMESPACE_RULES=$BASEDIR/rules/namespace.rules

if [[ $# -ge 1 ]]; then
    SERVER=$1
    echo "Custom server: $SERVER"
    if [[ $# -ge 2 ]]; then
        RULES=$2
        echo "Custom server: $SERVER"
    else
        # Dynamicly find the server version
        RULES=$BASEDIR/rules/`unzip -p $SERVER net/minecraft/server/MinecraftServer.class | strings | grep 'server version' | sed -e 's/^[^0-9]*//' -e 's/_.*//'`.rules
        echo "Extracted rules: $RULES"
    fi
else
    echo "Default server: $SERVER"
    echo "Default rules: $RULES"
fi

if [[ ! -e $SERVER ]]; then
    echo; echo "ERROR: Server: $SERVER doesn't exist";
    exit 0;
fi
if [[ ! -e $RULES ]]; then
    echo; echo "ERROR: Rules: $RULES doesn't exist";
    exit 0;
fi

OUTPUT=$BASEDIR/minecraft_server.jar
OUTPUT_TMP=$OUTPUT.tmp

echo "Renaming classfiles according to $RULES"
java -jar $JARJAR process $RULES $SERVER $OUTPUT_TMP > /dev/null 2>&1

echo "Repackaging classfiles into net.minecraft.server"
java -jar $JARJAR process $NAMESPACE_RULES $OUTPUT_TMP $OUTPUT > /dev/null 2>&1

echo "Fix stupid jarjar touching resource files"
TMPFOLDER=tmp.$$
rm -rf $TMPFOLDER
mkdir $TMPFOLDER
unzip -d $TMPFOLDER $OUTPUT net/minecraft/server/font.txt net/minecraft/server/null
zip -d $OUTPUT net/minecraft/server/font.txt net/minecraft/server/null
zip -r -j $OUTPUT $TMPFOLDER
rm -rf $TMPFOLDER

rm $OUTPUT_TMP

echo "New modified minecraft_server.jar: $OUTPUT"
