#!/bin/bash

INCLUDES="--include=*.md --include=*.html --include=*.yml"
EXCLUDES="--exclude-dir=.sass-cache --exclude-dir=_site --exclude-dir=.git --exclude=*license.md"

test_regex () {
  echo "Testing pattern: " $1
  if [ "$2" == "noinclude" ] ; then
    include=''
  else
    include=$INCLUDES
  fi
  grep -HIinrP $include $EXCLUDES $1 . && exit 1
}

test_url() {
  body=$(http -Fh --ignore-stdin --check-status $1 2>&1 > /dev/null)
  status=$?
  if [ $status -eq 0 ] ; then
    echo "     OK | $1"
  else
    echo "FAIL($status) | $1"
  fi
}

echo "Test regex results:"

test_regex "href=.{0,1}/"
test_regex "[a-z]'m"
test_regex "[a-z]'re"
test_regex "[a-z]'s"
test_regex "\t" noinclude

echo "Everything seems good..."

echo "Test URL results:"
urls=$(grep -hrPo "https?://[a-zA-Z0-9./?=_%:()-]*" _site | grep -v 0.0.0.0 | grep -v localhost  | sort | uniq)
for url in $urls; do
  test_url $url &
done

wait

echo "Done"
exit 0
