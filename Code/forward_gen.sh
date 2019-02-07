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

# ---------------- Specific ICMP ---------------- #

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
iptables -t mangle -F
iptables -F FWD_ICMP
iptables -X FWD_ICMP
iptables -F FWD_UDP
iptables -X FWD_UDP
iptables -F FWD_TCP
iptables -X FWD_TCP

iptables -N FWD_ICMP
iptables -N FWD_UDP
iptables -N FWD_TCP

iptables -P INPUT DROP #Set Default Input to Drop all packets
iptables -P OUTPUT DROP #Set Default Output to Drop all packets
iptables -P FORWARD DROP #Set Default Output to Drop all packets

#Backups to flush and delete user chains in case they already exist

# pre and post routing
# makes everything aming for the firewall to go to internal device
iptables -t nat -A PREROUTING -i eno1 -j DNAT --to 192.168.10.2
iptables -t nat -A POSTROUTING -o eno1 -j MASQUERADE

# ---------------- Block Ranges ---------------- #
# Drops traffic from outside spoofing as inside
iptables -A FORWARD -i eno1 -s 192.168.10.0/24 -j DROP # drop subnet traffic
# chain rules

# APPLY User Chains #
iptables -A FORWARD -p tcp -j FWD_TCP
iptables -A FORWARD -p udp -j FWD_UDP

# ports to block
# will be at very top
iptables -A FWD_TCP -p tcp --dport 32768:32775 -j DROP
iptables -A FWD_TCP -p tcp --dport 137:139 -j DROP
iptables -A FWD_TCP -p tcp --dport 111 -j DROP
iptables -A FWD_TCP -p tcp --dport 515 -j DROP
iptables -A FWD_TCP -p udp --dport 32768:32775 -j DROP
iptables -A FWD_TCP -p udp --dport 137:139 -j DROP

# ---------------- Block Flags -------------------- #
# drop all traffic with a syn and fin bit set
iptables -A FWD_TCP -p tcp --tcp-flags ALL SYN,FIN -j DROP # output syn fin not needed

# DOESN'T SPECIFY PORTS
iptables -A FWD_TCP -p tcp -mstate --state ESTABLISHED -j ACCEPT # need to have user chain tcp

iptables -A FWD_TCP -p tcp --tcp-flags ALL SYN --dport 1024:65535 -j DROP

# ---------------- Specific ICMP ---------------- # ARE ICMP REPLEIS ALWAYS ESTABLISHED???????????
iptables -A FORWARD -p icmp -j FWD_ICMP

# Accept all ICMP declared in User Config
# NOTE: All Echo Requests are NEW, and all ECHO Replies are ESTABLISHED
IFS=";" read -r -a ICMP_ARRAY <<< "$APPROVED_ICMP"
for itype in "${ICMP_ARRAY[@]}"; do
    iptables -A FWD_ICMP -p icmp --icmp-type $itype -j ACCEPT
done
iptables -A FWD_ICMP -p icmp -j DROP # DROP all other types

# ---------------- Specific Ports ---------------- #
# drop anything from port 23
iptables -A FWD_TCP -p tcp --sport 23 -j DROP
iptables -A FWD_TCP -p tcp --dport 23 -j DROP

iptables -A FWD_UDP -p udp --sport 23 -j DROP
iptables -A FWD_UDP -p udp --dport 23 -j DROP

# SSH Section
iptables -A FWD_TCP -p tcp -o eno1 --dport 22 -j ACCEPT # forward_out
iptables -A FWD_TCP -p tcp -i eno1 --dport 22 -s 192.168.0.0/24 -j ACCEPT # forward_in
iptables -A FWD_TCP -p tcp -o eno1 --sport 22 -s 192.168.0.0/24 -j ACCEPT # forward_in
iptables -A FWD_TCP -p tcp -i eno1 --sport 22 -j ACCEPT # forward_in

IFS=";" read -r -a UDP_PORT_ARRAY <<< "$APPROVED_UDP_PORTS"
for uports in "${UDP_PORT_ARRAY[@]}"; do
    iptables -A FWD_UDP -p udp -o eno1 --dport $uports -j ACCEPT # forward_out
    iptables -A FWD_UDP -p udp -i eno1 --sport $uports -j ACCEPT # forward_in
done
# REFERENCE
#iptables -A FORWARD -p udp -o eno1 --dport 53 -j ACCEPT # forward_out
#iptables -A FORWARD -p udp -i eno1 --sport 53 -j ACCEPT # forward_in

IFS=";" read -r -a TCP_PORT_ARRAY <<< "$APPROVED_TCP_PORTS"
for tports in "${TCP_PORT_ARRAY[@]}"; do
    iptables -A FWD_TCP -p tcp --dport $tports -j ACCEPT # forward_out
    iptables -A FWD_TCP -p tcp --sport $tports -mstate --state ESTABLISHED -j ACCEPT # forward_in
done
# REFERENCE
#iptables -A FORWARD -p tcp --dport 443 -j ACCEPT # forward_out
#iptables -A FORWARD -p tcp --sport 443 -mstate --state ESTABLISHED -j ACCEPT # forward_in


# ---------------- Data Flags ---------------- #
iptables -A PREROUTING -t mangle -p tcp -mstate --state NEW,ESTABLISHED --sport 20 -j TOS --set-tos 0x08 #FTPD
iptables -A PREROUTING -t mangle -p tcp -mstate --state NEW,ESTABLISHED --sport 21 -j TOS --set-tos 0x10 #FTP
iptables -A PREROUTING -t mangle -p tcp -mstate --state NEW,ESTABLISHED --sport 22 -j TOS --set-tos 0x10 #SSH
iptables -A FWD_TCP -p tcp -mstate --state NEW,ESTABLISHED --sport 22 --dport 22 -j ACCEPT

iptables -A FORWARD -f -j ACCEPT # needs more work add to each accepted udp and user chain
