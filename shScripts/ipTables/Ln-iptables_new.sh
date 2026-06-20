#!/bin/bash

echo 1 >/proc/sys/net/ipv4/ip_forward

# Flush tables
iptables -F
iptables -t nat -F
iptables -X
iptables -P FORWARD ACCEPT
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT

iptables -t nat -A PREROUTING -d 25.25.25.26 -j DNAT --to-destination



# iptables -t nat -A POSTROUTING -o eth0:0 -s 192.168.1.22 -p tcp --dport 53 -j SNAT --to 192.168.1.9:53
# iptables -t nat -A POSTROUTING -o eth0:0 -s 192.168.1.22 -p udp --dport 53 -j SNAT --to 192.168.1.9:53
# iptables -t nat -A POSTROUTING -o eth0:0 -s 192.168.1.22 -p tcp --dport 53 -j SNAT --to 192.168.1.9
# iptables -t nat -A POSTROUTING -o eth0:0 -s 192.168.1.22 -p udp --dport 53 -j SNAT --to 192.168.1.9

# iptables-save > /etc/sysconfig/iptables
# service iptables restart


# iptables -t nat -A POSTROUTING -o eth0:0 -s 192.168.1.22 -p tcp --dport 53 -j SNAT --to 192.168.1.9:53
# iptables -t nat -D POSTROUTING -o eth0:0 -s 192.168.1.22 -p tcp --dport 53 -j SNAT --to 192.168.1.9:53

iptables -t nat -L -n -v