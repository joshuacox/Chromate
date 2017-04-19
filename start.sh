#!/bin/bash

export CHROME_BIN=google-chrome


if [ -s /LINK ]; then
  echo "cat /LINKS |xargs -n1 -I{} nice -n $NICENESS $CHROME_BIN {}"
  echo "cat /LINKS |xargs -n1 -I{} google-chrome {}"
  #cat $LINK |xargs -n1 -I{} nice -n $NICENESS $CHROME_BIN {}
  nice -n $NICENESS $CHROME_BIN \
  --restore-last-session \
  --user-data-dir=/data \
  --host-resolver-rules="$MAP" \
  --proxy-server="$PROXY" \
  `cat /LINK`
else
  nice -n $NICENESS google-chrome \
  --restore-last-session \
  --user-data-dir=/data \
  --proxy-server="$PROXY" \
  --host-resolver-rules="$MAP"
fi