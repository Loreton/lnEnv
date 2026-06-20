#!/bin/env python3

import netifaces as ni          # https://pypi.python.org/pypi/netifaces
#   >>> import netifaces as ni
#   >>> ni.interfaces()
#   ['lo', 'eth0', 'eth1', 'vboxnet0', 'dummy1']
#   >>> ni.ifaddresses('eth0')
#   {
#       17: [
#           {
#               'broadcast': 'ff:ff:ff:ff:ff:ff',
#               'addr': '00:02:55:7b:b2:f6'
#           }
#       ],
#       2: [
#           {
#               'broadcast': '172.16.161.7',
#               'netmask': '255.255.255.248',
#               'addr': '172.16.161.6'
#           }
#       ],
#       10: [
#           {
#               'netmask': 'ffff:ffff:ffff:ffff::',
#               'addr': 'fe80::202:55ff:fe7b:b2f6%eth0'
#           }
#       ]
#   }
#   >>>
#   >>> print(ni.ifaddresses.__doc__)
#


# typo error in import

import subprocess
import os

def checkSubnet():
    with open(os.devnull, "wb") as limbo:
        for n in xrange(1, 10):
            ip="192.168.0.{0}".format(n)
            result=subprocess.Popen(["ping", "-c", "1", "-n", "-W", "2", ip],
                stdout=limbo, stderr=limbo).wait()
            if result:
                print (ip, "inactive")
            else:
                print (ip, "active")



def ping(ipAddress, verbose=False):
    with open(os.devnull, "wb") as limbo:
        result=subprocess.Popen(["ping", "-c", "1", "-n", "-W", "2", ipAddress], stdout=limbo, stderr=limbo).wait()
        if verbose:
            if result:
                print (ipAddress, "inactive")
            else:
                print (ipAddress, "active")

        return result





def ping2(address):
    res = subprocess.call(['ping', '-c', '1', address])
    return res

    for n in xrange(1,10):
        address = ip="192.168.0.{0}".format(n)
        res = subprocess.call(['ping', '-c', '3', address])
        return res
        if res == 0:
            print ("ping to", address, "OK")
        elif res == 2:
            print ("no response from", address)
        else:
            print ("ping to", address, "failed!")



# def delTable(table):



def execCommand(cmdString):
    # cmdList = ['sudo']
    cmdList = []
    cmdList.extend(cmdString.split())
    print(cmdList)
    rCode = subprocess.call( cmdList ) # solo per usare il sudo
    print('rcode', rCode)

    return rCode



# /etc/iproute2/rt_tables
interface = ni.interfaces()
for ifc in interface:
    addrs = ni.ifaddresses(ifc)
    # print (ifc, addrs[ni.AF_INET])
    afInet = addrs.get(ni.AF_INET)
    if afInet:
        afLink = (ifc, addrs[ni.AF_LINK])
        for inet in afInet:
            ip = inet['addr']
            MASK = inet['netmask']
            bCast = inet.get('broadcast')
            octet = ip.split('.')
            if octet[0] == '127':
                continue
            if octet[2] == '0':
                Table = 'rtLoreto'
            elif octet[2] == '1':
                Table = 'rtPina'
            else:
                continue

                # --------------------
                # - check Gateway
                # --------------------
            Gateway = '.'.join(octet[:3])+ '.1'
            # print (Gateway)
            if ping(Gateway, verbose=True) == 0:
                execCommand('ip rule del table {TABLE}'.format(TABLE=Table))
                execCommand('ip rule add from {IP}/24 table {TABLE}'.format(IP=ip, TABLE=Table))

            else:
                execCommand('ip rule del table {TABLE}'.format(TABLE=Table))

            # print('sudo', cmdString)
            # print('sudo', cmdString.split())

    print()

