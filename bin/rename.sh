#!/bin/bash

set -e

SCRIPT=$(readlink -f $0)
BASEDIR=`dirname $SCRIPT`/..

JARJAR="java -jar $BASEDIR/tools/jarjar.jar"
RETROGUARD="java -jar $BASEDIR/tools/retroguard.jar"

SERVER=$BASEDIR/server/minecraft_server.jar
RULES=$BASEDIR/rules/latest.rules
RETRO_CONFIG=$BASEDIR/rules/latest.rgs
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
        RETRO_CONFIG=$BASEDIR/rules/`unzip -p $SERVER net/minecraft/server/MinecraftServer.class | strings | grep 'server version' | sed -e 's/^[^0-9]*//' -e 's/_.*//'`.rgs
        echo "Extracted rules: $RETRO_CONFIG"
    fi
else
    echo "Default server: $SERVER"
    echo "Default rules: $RULES"
    echo "Default rgs: $RETRO_CONFIG"
fi

if [[ ! -e $SERVER ]]; then
    echo; echo "ERROR: Server: $SERVER doesn't exist";
    exit 0;
fi
if [[ ! -e $RULES ]]; then
    echo; echo "ERROR: Rules: $RULES doesn't exist";
    exit 0;
fi
if [[ ! -e $RETRO_CONFIG ]]; then
    echo; echo "ERROR: Retroconfig: $RETRO_CONFIG doesn't exist";
    exit 0;
fi

OUTPUT=$BASEDIR/minecraft_server.jar
OUTPUT_TMP=$OUTPUT.tmp
OUTPUT_TMP2=$OUTPUT.tmp2

echo "Renaming classfiles according to $RULES"
$JARJAR process $RULES $SERVER $OUTPUT_TMP

echo "Repackaging classfiles into net.minecraft.server"
if [[ -e $OUTPUT ]]; then rm -rf $OUTPUT; fi
$JARJAR process $NAMESPACE_RULES $OUTPUT_TMP $OUTPUT_TMP2

rm $OUTPUT_TMP

echo "Renaming constants using retroguard"
$RETROGUARD $OUTPUT_TMP2 $OUTPUT $RETRO_CONFIG retro.log

rm retro.log $OUTPUT_TMP2

echo "New modified minecraft_server.jar: $OUTPUT"
