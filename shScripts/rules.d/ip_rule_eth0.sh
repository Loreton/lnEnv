#!/bin/bash

#  https://www.thegeekstuff.com/2014/08/add-route-ip-command/

# netstat -rn
# Destination     Gateway         Genmask         Flags   MSS Window  irtt Iface
# 0.0.0.0         192.168.1.1     0.0.0.0         UG        0 0          0 eth0
# 192.168.1.0     0.0.0.0         255.255.255.0   U         0 0          0 eth0
# 192.168.3.0     0.0.0.0         255.255.255.0   U         0 0          0 wlan1
#

# When you ping the IP address 192.168.3.176 from outside your network you may notice
# that it will not be pingable.
# crate routing table in: /etc/iproute2/rt_tables
    ip rule show


# First, take a backup of the rt_Tables before making any changes.
    # cd /etc/iproute2
    # cp rt_tables rt_tables.orig

# Next, create a new policy routing table entry in /etc/iproute2/rt_tables file:
    # echo "1 ln_wlan0" >> /etc/iproute2/rt_tables


# Now add the routing entries in the $TABLE table.
    IFC='eth0'
    TABLE="ln_${IFC}"
    IFC_ADDR=$(ip addr show ${IFC} | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)
    IFC_ADDR=$(ip addr show dev ${IFC} | grep "inet\b" | awk 'NR==1{print $2}' | cut -d'/' -f 1)
    SUBNET_24=$(ip route | grep "src $IFC_ADDR" | grep -v "default"| awk '{print $1}')
    SUBNET_0=$(ip route | grep "src $IFC_ADDR" | grep -v "default"| cut -d'/' -f 1)
    suffix='.0'
    SUBNET=${SUBNET_0/%$suffix}

    GW_ADDR=$(ip route show | grep default | awk '{print $3}' |grep "$SUBNET")
    # GW_ADDR="${SUBNET}.1"

    echo "-----------------------------------"
    echo "-  IFC       :   $IFC"
    echo "-  TABLE     :   $TABLE"
    echo "-  SUBNET    :   $SUBNET"
    echo "-  SUBNET_0  :   $SUBNET_0"
    echo "-  SUBNET_24 :   $SUBNET_24"
    echo "-  IFC_ADDR  :   $IFC_ADDR"
    echo "-  GW_ADDR   :   $GW_ADDR"
    echo "-----------------------------------"

    # adding subnet 192.168.3.0 with a netmask 255.255.255.0 with
    #   the source IP address 192.168.3.176 & device $IFC to the loreto table.
    ip route add ${SUBNET_24} dev $IFC src $IFC_ADDR table $TABLE

    # adding the route 192.168.3.1 to the $TABLE table.
    # This way all the rules defined in $TABLE table routes traffic through device $IFC.
    ip route add default via $GW_ADDR dev $IFC table $TABLE



    ip rule
    # 0:      from all lookup local
    # 32764:  from 192.168.3.0/24 lookup Loreto
    # 32765:  from 192.168.1.0/24 lookup Pina
    # 32766:  from all lookup main
    # 32767:  from all lookup default

# instruct the OS how to use this table
# All the rules are executed in the ascending order.
# So, we will add rule entries above the $TABLE table.
    ip rule add from $IFC_ADDR/24 table $TABLE
    ip rule add to $IFC_ADDR/24 table $TABLE
    ip route flush cache
    # 1. The first command adds the rule that all the traffic going to wlan1’s IP needs to use the "$TABLE" routing table instead of "main" one.
    # 2. The second command adds the rule that all the outgoing traffic from wlan1’s IP needs to use the "$TABLE" routing table instead of "main" one.
    # 3. The third command is used to commit all these changes in the previous commands

# Finally, verify that your changes are made appropriately using the following command:
    ip rule show

# To make these changes persistent across reboot,
#   you can add these commands to /etc/init.d/boot.local (for SUSE Linux),
#   or /etc/rc.d/rc.local (for Redhat, CentOS).