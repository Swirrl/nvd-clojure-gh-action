#!/usr/bin/env bash

DIR=$1

cp $DIR/nvd-clojure-suppress.xml .

if [ -f nvd-clojure-suppress.xml ]; then
    CONFIG=nvd-config.json
    echo "Using suppression config $CONFIG:"
    cat nvd-clojure-suppress.xml
fi

if [ -z "${BUILD_TOOL}" ]; then
    BUILD_TOOL=clj
fi

if [ -z "${CLASSPATH_CMD}" ]; then
    if [ "${BUILD_TOOL}" == "clj" ]; then
        CLASSPATH_CMD='clojure -Spath'
    elif [ "${BUILD_TOOL}" == "lein" ]; then
        CLASSPATH_CMD='lein classpath'
    fi
fi

CLASSPATH=$(cd $DIR; $CLASSPATH_CMD)

if [ "$?" -ne 0 ]; then
  exit 1
fi

clojure -M:nvd-clojure -m "nvd.task.check" "$CONFIG" "$CLASSPATH"

RESULT=$?
if [ "$CREATE_ISSUE" == "true" ]; then
    if [ "$RESULT" -ne 0 ]; then
        clojure -M:create-issue
    fi
fi
exit $RESULT
