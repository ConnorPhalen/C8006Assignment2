#!/bin/sh
#-------------
# iptable_gen.sh
# Script made by Connor Phalen
# January 17, 2019: Added tcp and udp port rule additions through user chain tcpin
# January 22, 2019: Added some OUTPUT rules
# January 23, 2019: Added port 443 for SSL traffic and SYN restrictions
# January 24, 2019: Testing and general checks
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

#Backups to flush and delete user chains in case they already exist
iptables -F INPUT
iptables -F OUTPUT
iptables -F tcpfwd_in
iptables -X tcpfwd_in
iptables -F udpfwd_in
iptables -X udpfwd_in
iptables -F tcpfwd_out
iptables -X tcpfwd_out
iptables -F udpfwd_out
iptables -X udpfwd_out
iptables -F servconn_fwd
iptables -X servconn_fwd

#Make user-defined chains
iptables -N tcpfwd_in
iptables -N udpfwd_in
iptables -N tcpfwd_out
iptables -N udpfwd_out
iptables -N servconn_fwd

IFS=";" read -r -a PORT_ARRAY <<< "$APPROVED_PORTS" #Create an array of ports

iptables -P INPUT DROP #Set Default Input to Drop all packets
iptables -P OUTPUT DROP #Set Default Output to Drop all packets
iptables -P FORWARD DROP #Set Default Output to Drop all packets

# Initial prototype
#for i in "${PORT_ARRAY[@]}"; do #Accept tcp conn for ports destined to the lab
#    iptables -A tcpin -p tcp -d 192.168.1.0/24 --sport $i -j ACCEPT
#done
