#!/bin/sh

NOTMUTED=$(amixer -M | head -5 | grep "\[on\]")
if [ -z "$NOTMUTED" ]; then
  echo "muted"
else
  amixer sget Master | grep 'Left:' | awk -F'[][]' '{ print $2  }'
fi
