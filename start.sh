#!/bin/bash

MYCWD=$(pwd)
#TZ=${TZ:-America/Chicago}
CHROME_BIN=google-chrome

#rm /etc/localtime
#cd /etc; ln -s /usr/share/zoneinfo/$TZ localtime
cd $MYCWD

if [ -s /SANDBOX ]; then
  SANDBOX_OPT=--no-sandbox
fi

if [ -s /LINK ]; then
  echo "cat /LINKS |xargs -n1 -I{} nice -n $NICENESS $CHROME_BIN {}"
  echo "cat /LINKS |xargs -n1 -I{} google-chrome {}"
  #cat $LINK |xargs -n1 -I{} nice -n $NICENESS $CHROME_BIN {}
  nice -n $NICENESS $CHROME_BIN \
  --restore-last-session \
  --user-data-dir=/data \
  --host-resolver-rules="$MAP" \
  --proxy-server="$PROXY" \
  $SANDBOX_OPT \
  `cat /LINK`
else
  nice -n $NICENESS $CHROME_BIN \
  --restore-last-session \
  --user-data-dir=/data \
  --host-resolver-rules="$MAP" \
  --proxy-server="$PROXY" \
  --password-store="$PWSTORE" \
  $SANDBOX_OPT \
  'http://bokbot.org/'
fi
