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
if [ "$RESULT" -eq 255 ]; then
    CVES_FOUND=true
elif [ "$RESULT" -ne 0 ]; then
    exit $RESULT
else
    CVES_FOUND=false
fi

if [ "$CREATE_ISSUE" == "true" ] && [ "$CVES_FOUND" == "true" ]; then
    clojure -M:create-issue
    RESULT2=$?
    if [ "$RESULT2" -ne 0 ]; then
        exit $RESULT2
    fi
fi

if [ "$FAIL_ON_CVE" == "true" ] && [ "$CVES_FOUND" == "true" ]; then
    exit $RESULT
fi
