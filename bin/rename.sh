#!/bin/bash

SCRIPT=$(readlink -f $0)
BASEDIR=`dirname $SCRIPT`/..

JARJAR=$BASEDIR/tools/jarjar.jar

SERVER=$BASEDIR/server/minecraft_server.jar
RULES=$BASEDIR/rules/latest.rules
NAMESPACE_RULES=$BASEDIR/rules/namespace.rules

if [[ $# -ge 1 ]]; then
    SERVER=$1
fi

OUTPUT=$BASEDIR/minecraft_server.jar
OUTPUT_TMP=$OUTPUT.tmp

java -jar $JARJAR process $RULES $SERVER $OUTPUT_TMP
java -jar $JARJAR process $NAMESPACE_RULES $OUTPUT_TMP $OUTPUT

rm $OUTPUT_TMP
