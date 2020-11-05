#!/bin/bash

curl -s "http://gw.tylephony.com:666/hosts/?full=yes&sort=total" > /tmp/gw-darkstat.html
cat /tmp/gw-darkstat.html | grep -i '.tylephony.com' |sed 's/ <td>//g' | sed 's/<\/td>//g' > /tmp/host-list.txt

echo "Content-type: text/plain"
echo ""
echo "# HELP darkstat_net_in Network collected metric"
echo "# TYPE darkstat_net_in counter"

IFS=$'\n'
for line in $(printf "$(cat /tmp/host-list.txt )")
do

rx=$(cat /tmp/gw-darkstat.html |grep -A 3 -i "${line}" |tail -n 2 |head -n 1 |sed 's/ <td class="num">//'|sed 's/<\/td>//' |sed 's/,//g')

echo "darkstat_net_in{host=\"${line}\"} ${rx}"

done

echo "# HELP darkstat_net_out Network collected metric"
echo "# TYPE darkstat_net_out counter"

IFS=$'\n'
for line in $(printf "$(cat /tmp/host-list.txt )")
do

tx=$(cat /tmp/gw-darkstat.html |grep -A 3 -i "${line}" |tail -n 1 |sed 's/ <td class="num">//'|sed 's/<\/td>//' |sed 's/,//g')

echo "darkstat_net_out{host=\"${line}\"} ${tx}"

done
