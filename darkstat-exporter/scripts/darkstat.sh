#!/bin/sh
#
# Shell script for pulling host names and bandwidith usage from Darkstat and returning Prometheus Exporter metrics.
# 
# Dave Schmid
# https://github.com/lux4rd0/prometheus/tree/main/darkstat-exporter
#

# Timer Start

start_at=$(date +%s,%N)
_s1=$(echo "$start_at" | cut -d',' -f1)   # sec
_s2=$(echo "$start_at" | cut -d',' -f2)   # nano sec

# Change value to represent URL of your DarkStat instance

tmp_page=$(curl -s "http://gw.tylephony.com:666/hosts/?full=yes")

# Change value to remove the domain name

host_list=$(echo "$tmp_page" | grep -i '.tylephony.com' |sed 's/ <td>//g' | sed 's/<\/td>//g')

echo "# HELP darkstat_net_in Network collected metric"
echo "# TYPE darkstat_net_in counter"

for line in $host_list
do

rx=$(echo "$tmp_page" |grep -A 3 -i "${line}" |tail -n 2 |head -n 1 |sed 's/ <td class="num">//'|sed 's/<\/td>//' |sed 's/,//g')

echo "darkstat_net_in{host=\"${line}\"} ${rx}"

done

echo "# HELP darkstat_net_out Network collected metric"
echo "# TYPE darkstat_net_out counter"

for line in $host_list
do

tx=$(echo "$tmp_page" |grep -A 3 -i "${line}" |tail -n 1 |sed 's/ <td class="num">//'|sed 's/<\/td>//' |sed 's/,//g')

echo "darkstat_net_out{host=\"${line}\"} ${tx}"

done

# Timer End

end_at=$(date +%s,%N)
_e1=$(echo "$end_at" | cut -d',' -f1)
_e2=$(echo "$end_at" | cut -d',' -f2)
duration=$(bc <<< "scale=3; $_e1 - $_s1 + ($_e2 -$_s2)/1000000000")

echo "# HELP darkstat_timer_seconds Darkstat script timer metric"
echo "# TYPE darkstat_timer_seconds gauge"
echo "darkstat_timer_seconds ${duration}"
