#!/bin/bash
#
# Shell script for pulling host names and bandwidith usage from Darkstat and returning Prometheus Exporter metrics.
#
# Dave Schmid
# https://github.com/lux4rd0/prometheus/tree/main/darkstat-exporter
#

# Change value to represent URL of your DarkStat instance

tmp_page=$(curl -s "http://gw.tylephony.com:666/hosts/?full=yes&sort=total")

# Change value to match on each host

host_list=$(echo "$tmp_page" | grep -i '.tylephony.com' |sed 's/ <td>//g' | sed 's/<\/td>//g' | tr '[:upper:]' '[:lower:]')

echo "# HELP darkstat_net_in Network collected metric"
echo "# TYPE darkstat_net_in counter"

for line in $host_list
do

rx=$(echo "$tmp_page" |grep -A 3 -i "${line}" | tail -n 2 | head -n 1 | sed 's/ <td class="num">//' | sed 's/<\/td>//' | sed 's/,//g')
tx=$(echo "$tmp_page" |grep -A 3 -i "${line}" | tail -n 1 | sed 's/ <td class="num">//' | sed 's/<\/td>//' | sed 's/,//g')
ip=$(echo "$tmp_page" |grep -B 1 -i "${line}" | head -n 1 | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}" | head -n 1)
mac=$(echo "$tmp_page" |grep -A 1 -i "${line}" | tail -n 1 | head -n 1 | sed 's/ <td><tt>//' | sed 's/<\/tt><\/td>//' | tr '[:lower:]' '[:upper:]')

echo "darkstat_network_receive_bytes_total{host=\"${line}\",ip=\"${ip}\",mac=\"${mac}\"} ${rx}"
echo "darkstat_network_transmit_bytes_total{host=\"${line}\",ip=\"${ip}\",mac=\"${mac}\"} ${tx}"

done
