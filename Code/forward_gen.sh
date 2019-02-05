#!/bin/sh
#-------------
# forward_gen.sh
# Script made by Connor Phalen abd Greg Little
# January 31, 2019: Setup varibales and User Chains
#-------------

#Varibale Section
APPROVED_PORTS="22;53;67;68;80;443" #Approved ports for easy changes
ADPT_IP="0.0.0.0" # Test variable for getting Adapter IP's later
#Port Breakdown
# 22 - SSH (tcp)
# 53 - DNS (tcp and udp)
# 67 - DHCP (udp)
# 68 - DHCP (udp)
# 80 - http (tcp)
# 443- SSL (tcp)

#Allow For this machine to be a TEMP Forwarding machine, has to be rerun every restart
sysctl -w net.ipv4.ip_forward=1

#Backups to flush and delete user chains in case they already exist
iptables -F INPUT
iptables -F OUTPUT
iptables -F FORWARD

IFS=";" read -r -a PORT_ARRAY <<< "$APPROVED_PORTS" #Create an array of ports

iptables -P INPUT DROP #Set Default Input to Drop all packets
iptables -P OUTPUT DROP #Set Default Output to Drop all packets
iptables -P FORWARD DROP #Set Default Output to Drop all packets

