#!/bin/bash

echo 1 >/proc/sys/net/ipv4/ip_forward

# Flush tables
iptables -F
iptables -t nat -F
iptables -X
iptables -P FORWARD ACCEPT
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT

# How to NAT a Linux virtual interface.
# May 13th, 2010 Posted in Documentation Write comment
# I was able to use the following iptables configuration to NAT from a
# linux virtual interface (eth1:1) to an email/web server on my LAN (192.168.0.x).
# eth0:0 is the IP address
# I assigned to eth1:1, and 192.168.0.6 is the IP address of the server on my LAN.
# This works with both INPUT and FORWARD chains set to DROP.

# This may not be the best solution, but it took quite a while to figure out how get something in place that works.

######################
# nat PREROUTING Chain Rules
######################

-A PREROUTING -d eth0:0 -p tcp –dport 53 -j DNAT –to 192.168.1.9:53
-A PREROUTING -d eth0:0 -p udp –dport 53 -j DNAT –to 192.168.1.9:53

######################
# nat POSTROUTING Chain Rules
######################

-A POSTROUTING -o eth1 -j SNAT –to-source eth0:0

######################
# filter FORWARD Chain Rules
######################

-A FORWARD -p tcp -i eth0 -o eth1 -s 192.168.0.6 -m multiport –sports 25 -j ACCEPT
-A FORWARD -p tcp -i eth1 -o eth0 -d 192.168.0.6 -m multiport –dports 25 -m state –state NEW -j ACCEPT
-A FORWARD -p tcp -i eth1 -o eth0 -d 192.168.0.6 -m multiport –dports 25 -j ACCEPT

-A FORWARD -p tcp -i eth0 -o eth1 -s 192.168.0.6 -m multiport –sports 80 -j ACCEPT
-A FORWARD -p tcp -i eth1 -o eth0 -d 192.168.0.6 -m multiport –dports 80 -m state –state NEW -j ACCEPT
-A FORWARD -p tcp -i eth1 -o eth0 -d 192.168.0.6 -m multiport –dports 80 -j ACCEPT