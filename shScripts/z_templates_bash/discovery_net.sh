#!/bin/sh


x=$(sudo nmap -sn 192.168.1.144/32)
sampleString='Starting Nmap 7.94SVN ( https://nmap.org ) at 2024-12-16 14:36 CET Nmap scan report for Unused-852E00.lan (192.168.1.144) Host is up (0.037s latency). MAC Address: BC:DD:C2:85:2E:00 (Espressif) Nmap done: 1 IP address (1 host up) scanned in 0.15 seconds'

# dns_name=$(echo $x | grep -oP '(?<=report for).*?(?=\()') # find all occurrency
# dns_name=$(echo $x | grep -oP '(?<=report for).*(?=\()'); echo $dns_name

fromStr="report for"; toStr=' (19'
# dns_name=$(echo $x | grep -oP '(?<=report for).*?(?=\()'); echo $dns_name


# ip_addr=$(echo $x | grep -oP '(?<= \()).*?(?=\) )'); echo $ip_addr
sq="'"
dq='"'


# fromStr='\"report for\"'; toStr='\" (19\"'
foo=${x##*${fromStr} }; echo $foo
dns=${foo%% ${toStr}*}; echo $dns
# echo $x | sed -e 's/${fromStr}\(.*\)${toStr}/\1/'
# echo "s/${fromStr}\(.*\)${toStr}/\1/"
# echo $x | sed -e "s/${fromStr}\(.*\)${toStr}/\1/"