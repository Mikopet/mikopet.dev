#!/bin/bash

INCLUDES="--include=\*.md --include=\*.html"
EXCLUDES="--exclude-dir=_site --exclude-dir=.git --exclude=LICENSE.md"

test_command () {
  echo "Testing pattern: " $1
  if [ "$2" == "noinclude" ] ; then
    include=''
  else
    include=$INCLUDES
  fi
  grep -HIinrP $include $EXCLUDES $1 . && exit 1
}

echo "Test results:"

test_command "href=.{0,1}/"
test_command "[a-z]'m"
test_command "[a-z]'re"
test_command "[a-z]'s"
test_command "\t" noinclude

echo "Everything seems good..."
exit 0
