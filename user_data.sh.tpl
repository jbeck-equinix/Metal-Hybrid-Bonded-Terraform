#!/bin/bash
yum update -y
yum install vlan -y
cat <<\EOF >> /etc/sysconfig/network-scripts/ifcfg-bond0.3001
DEVICE=bond0.3001
NAME=bond0.3001
IPADDR=10.0.3.10
NETMASK=255.255.255.0
GATEWAY=10.0.3.0
VLAN=yes
BOOTPROTO=none
ONBOOT=yes
USERCTL=no
TYPE=Bond
BONDING_OPTS="mode=4 miimon=100 downdelay=200 updelay=200"
EOF
service network restart
