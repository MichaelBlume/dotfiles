#!/usr/bin/env bash
wifis=`/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -s`

hwwifis=`echo "$wifis" | grep "Climate\|Volterra"`

tether=`echo "$wifis" | grep "   Mike"`

transmission=`ps aux | grep -i Transmission | grep -v grep`

if [ -n "$hwwifis" ] && [ -n "$tether" ]; then
  /usr/local/bin/growlnotify -s -m "stop tethering"
fi

if [ -n "$transmission" ] && [ -n "$tether" ]; then
  /usr/local/bin/growlnotify -s -m "do not tether and torrent"
fi
