#!/usr/bin/env bash

DIR=$1

CLASSPATH=$(cd $DIR; clojure -Spath)

if [ "$?" -ne 0 ]; then
  exit 1
fi

clojure -J-Dclojure.main.report=stderr -M:dummy -m nvd.task.check "" "$CLASSPATH"

RESULT=$?
if [ "$RESULT" -ne 0 ]; then
  clojure -M:create-issue
  exit $RESULT
fi
