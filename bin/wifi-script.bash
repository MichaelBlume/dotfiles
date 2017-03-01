#!/usr/bin/env bash
export DISPLAY=:0
wifis=`sudo iwlist wlan0 scan`

echo "$wifis" > /home/mike/.wifilist

hwwifis=`echo "$wifis" | grep "Volterra"`

tether=`echo "$wifis" | grep "Mike"`

transmission=`ps aux | grep -i Transmission | grep -v grep`

if [ -n "$hwwifis" ] && [ -n "$tether" ]; then
  logger -s 'notifying tethering'
  su mike -c 'notify-send "stop tethering"'
fi

if [ -n "$transmission" ] && [ -n "$tether" ]; then
  logger -s 'notifying torrenting'
  sudo -u mike notify-send "do not tether and torrent"
fi
