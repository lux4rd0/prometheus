#!/bin/bash
#
# Shell script for pulling host names and bandwidith usage from Darkstat and returning Prometheus Exporter metrics.
#
# Dave Schmid
# https://github.com/lux4rd0/prometheus/tree/main/darkstat-exporter
#

# Change value to represent URL of your DarkStat instance

tmp_page=$(curl -s "http://gw.tylephony.com:666/hosts/?full=yes")

# Change value to match on each host

host_list=$(echo "$tmp_page" | grep -i '.tylephony.com' |sed 's/ <td>//g' | sed 's/<\/td>//g')

echo "# HELP darkstat_net_in Network collected metric"
echo "# TYPE darkstat_net_in counter"

for line in $host_list
do

rx=$(echo "$tmp_page" |grep -A 3 -i "${line}" |tail -n 2 |head -n 1 |sed 's/ <td class="num">//'|sed 's/<\/td>//' |sed 's/,//g')

echo "darkstat_net_in{host=\"${line/.*/}\"} ${rx}"

done

echo "# HELP darkstat_net_out Network collected metric"
echo "# TYPE darkstat_net_out counter"

for line in $host_list
do

tx=$(echo "$tmp_page" |grep -A 3 -i "${line}" |tail -n 1 |sed 's/ <td class="num">//'|sed 's/<\/td>//' |sed 's/,//g')

echo "darkstat_net_out{host=\"${line/.*/}\"} ${tx}"

done
