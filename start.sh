#!/bin/bash

MYCWD=$(pwd)
TZ=${TZ:-America/Chicago}
export CHROME_BIN=google-chrome

cd $MYCWD

if [ -s /LINK ]; then
  nice -n $NICENESS $CHROME_BIN \
  --restore-last-session \
  --user-data-dir=/data \
  --no-sandbox \
  --host-resolver-rules="$MAP" \
  --proxy-server="$PROXY" \
  `cat /LINK`
else
  nice -n $NICENESS $CHROME_BIN \
  --restore-last-session \
  --user-data-dir=/data \
  --host-resolver-rules="$MAP" \
  --proxy-server="$PROXY" \
  'http://bokbot.org/'
fi
