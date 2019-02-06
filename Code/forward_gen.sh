#!/bin/sh
#-------------
# forward_gen.sh
# Script made by Connor Phalen abd Greg Little
# January 31, 2019: Setup varibales and User Chains
# February 4, 2019: Refactored and added Firewall Setup Rules
# February 5, 2019: Added Firewall NAT Rules
#-------------

#Variable Section
#IFS=";" read -r -a PORT_ARRAY <<< "$APPROVED_PORTS" #Create an array of ports

# Initialization Section
# setting up
ifconfig enp3s2 192.168.10.1 up
echo "1" > /proc/sys/net/ipv4/ip_forward
route add -net 192.168.0.0 netmask 255.255.255.0 gw 192.168.0.1
route add -net 192.168.10.0/24 gw 192.168.10.1

# pre and post routing
# makes everything aming for the firewall to go to internal device
iptables -t nat -A PREROUTING -i eno1 -j DNAT --to 192.168.10.2
iptables -t nat -A POSTROUTING -o eno1 -j MASQUERADE

#Allow For this machine to be a TEMP Forwarding machine, has to be rerun every restart
sysctl -w net.ipv4.ip_forward=1

#Backups to flush and delete user chains in case they already exist
iptables -F INPUT
iptables -F OUTPUT
iptables -F FORWARD

iptables -P INPUT DROP #Set Default Input to Drop all packets
iptables -P OUTPUT DROP #Set Default Output to Drop all packets
iptables -P FORWARD DROP #Set Default Output to Drop all packets

# ports to block
# will be at very top
iptables -A FORWARD -p tcp --dport 32768:32775 -j DROP
iptables -A FORWARD -p tcp --dport 137:139 -j DROP
iptables -A FORWARD -p tcp --dport 111 -j DROP
iptables -A FORWARD -p tcp --dport 515 -j DROP
iptables -A FORWARD -p udp --dport 32768:32775 -j DROP
iptables -A FORWARD -p udp --dport 137:139 -j DROP

# chain rules

# drop anything from port 23
iptables -A FORWARD -p tcp --sport 23 -j DROP
iptables -A FORWARD -p tcp --dport 23 -j DROP

iptables -A FORWARD -p udp --sport 23 -j DROP
iptables -A FORWARD -p udp --dport 23 -j DROP

#iptables -A FORWARD -s 192.168.10.0/24 -j DROP # drop subnet traffic -> Put onto inner comp

# drop all traffic with a syn and fin bit set
iptables -A FORWARD -p tcp --tcp-flags ALL SYN,FIN -j DROP # output syn fin not needed

iptables -A FORWARD -p tcp -mstate --state ESTABLISHED -j ACCEPT # need to have user chain tcp

iptables -A FORWARD -p tcp --tcp-flags ALL SYN --dport 1024:65535 -j DROP

iptables -A FORWARD -t mangle -p tcp -mstate --state NEW,ESTABLISHED --dport 20 -j TOS --set-tos 0x08 #FTPD
iptables -A FORWARD -t mangle -p tcp -mstate --state NEW,ESTABLISHED --dport 21 -j TOS --set-tos 0x10 #FTP
iptables -A FORWARD -t mangle -p tcp -mstate --state NEW,ESTABLISHED --dport 22 -j TOS --set-tos 0x10 #SSH
iptables -A FORWARD -p tcp -mstate --state NEW,ESTABLISHED --sport 22 --dport 22 -j ACCEPT

iptables -A FORWARD -p udp -f -j ACCEPT # needs more work add to each accepted udp and user chain
