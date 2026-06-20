#!/bin/bash

# nohup sudo bash /home/pi/Loreto/conf/Ln-iptables.sh

echo 1 >/proc/sys/net/ipv4/ip_forward
# iptables -t nat -A POSTROUTING -o eth0:0 -s 192.168.1.22 -p tcp --dport 53 -j SNAT --to 192.168.1.9:53
# iptables -t nat -D POSTROUTING -o eth0:0 -s 192.168.1.22 -p tcp --dport 53 -j SNAT --to 192.168.1.9:53

iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

iptables -A FORWARD -i eth0 -o eth0:0 -m state --state RELATED,ESTABLISHED -j ACCEPT

iptables -A FORWARD -i eth0:0 -o eth0 -j ACCEPT