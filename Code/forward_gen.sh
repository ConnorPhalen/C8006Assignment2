#!/bin/sh
#-------------
# forward_gen.sh
# Script made by Connor Phalen abd Greg Little
# January 31, 2019: Setup varibales and User Chains
# February 4, 2019: Refactored and added Firewall Setup Rules
# February 5, 2019: Added Firewall NAT Rules
#-------------

#How the Script Progresses
# ---------------- Setup Gateway/Network ---------------- #

# ---------------- Setup Chains ---------------- #

# ---------------- DNAT & MASQUERADE ---------------- #

# ---------------- Block Ranges ---------------- #

# ---------------- Block Flags -------------------- #

# ---------------- Specific Ports ---------------- #

# ---------------- Data Flags ---------------- #


#Variable Section
#IFS=";" read -r -a PORT_ARRAY <<< "$APPROVED_PORTS" #Create an array of ports
BASE_IP="192.168.0.0"

# ---------------- Setup Gateway/Network ---------------- #
# setting up hardcoded
#ifconfig enp3s2 down
#ifconfig enp3s2 192.168.10.1 up
#echo "1" > /proc/sys/net/ipv4/ip_forward
#route add -net 192.168.0.0 netmask 255.255.255.0 gw 192.168.0.1
#route add -net 192.168.10.0/24 gw 192.168.10.1

# SETUP WITH EXPORTED VALUES
ifconfig "$FAI" down
ifconfig "$FAI" "$FSI" up
echo "1" > /proc/sys/net/ipv4/ip_forward
route add -net "$BASE_IP" netmask "$FM" gw "$FHI"
#route add -net "$FSB"/24 gw "$FSI"
route add -net 192.168.10.0/24 gw "$FSI"

# ---------------- Setup Chains ---------------- #
iptables -F INPUT
iptables -F OUTPUT
iptables -F FORWARD
iptables -t nat -F

iptables -P INPUT DROP #Set Default Input to Drop all packets
iptables -P OUTPUT DROP #Set Default Output to Drop all packets
iptables -P FORWARD DROP #Set Default Output to Drop all packets

#Backups to flush and delete user chains in case they already exist

# pre and post routing
# makes everything aming for the firewall to go to internal device
iptables -t nat -A PREROUTING -i eno1 -j DNAT --to 192.168.10.2
iptables -t nat -A POSTROUTING -o eno1 -j MASQUERADE

# ---------------- Block Ranges ---------------- #
# ports to block
# will be at very top
iptables -A FORWARD -p tcp --dport 32768:32775 -j DROP
iptables -A FORWARD -p tcp --dport 137:139 -j DROP
iptables -A FORWARD -p tcp --dport 111 -j DROP
iptables -A FORWARD -p tcp --dport 515 -j DROP
iptables -A FORWARD -p udp --dport 32768:32775 -j DROP
iptables -A FORWARD -p udp --dport 137:139 -j DROP

# Drops traffic from outside spoofing as inside
iptables -A FORWARD -i eno1 -s 192.168.10.0/24 -j DROP # drop subnet traffic
# chain rules

# ---------------- Block Flags -------------------- #
# drop all traffic with a syn and fin bit set
iptables -A FORWARD -p tcp --tcp-flags ALL SYN,FIN -j DROP # output syn fin not needed

# ACCEPTS ALL ESTABLISHED CONNECTIONS
iptables -A FORWARD -p tcp -mstate --state ESTABLISHED -j ACCEPT # need to have user chain tcp

iptables -A FORWARD -p tcp --tcp-flags ALL SYN --dport 1024:65535 -j DROP

# ---------------- Specific Ports ---------------- #
# drop anything from port 23
iptables -A FORWARD -p tcp --sport 23 -j DROP
iptables -A FORWARD -p tcp --dport 23 -j DROP

iptables -A FORWARD -p udp --sport 23 -j DROP
iptables -A FORWARD -p udp --dport 23 -j DROP

# DNS Section
iptables -A FORWARD -p udp --dport 53 -j ACCEPT # forward_out
iptables -A FORWARD -p udp --sport 53 -j ACCEPT # forward_in

#/////////////
    #Could Setup FOR Loop to do these
#\\\\\\\\\\\\\
#SSL Section - Only allow connections if inner wanted to connect
iptables -A FORWARD -p tcp --dport 443 -j ACCEPT # forward_out
iptables -A FORWARD -p tcp --sport 443 -mstate --state ESTABLISHED -j ACCEPT # forward_in

#SSL Section - Only allow connections if inner wanted to connect
iptables -A FORWARD -p tcp --dport 80 -j ACCEPT # forward_out
iptables -A FORWARD -p tcp --sport 80 -mstate --state ESTABLISHED -j ACCEPT # forward_in

# ---------------- Data Flags ---------------- #
iptables -A PREROUTING -t mangle -p tcp -mstate --state NEW,ESTABLISHED --dport 20 -j TOS --set-tos 0x08 #FTPD
iptables -A PREROUTING -t mangle -p tcp -mstate --state NEW,ESTABLISHED --dport 21 -j TOS --set-tos 0x10 #FTP
iptables -A PREROUTING -t mangle -p tcp -mstate --state NEW,ESTABLISHED --dport 22 -j TOS --set-tos 0x10 #SSH
iptables -A FORWARD -p tcp -mstate --state NEW,ESTABLISHED --sport 22 --dport 22 -j ACCEPT

iptables -A FORWARD -p udp -f -j ACCEPT # needs more work add to each accepted udp and user chain
