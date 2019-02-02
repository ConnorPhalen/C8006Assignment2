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
iptables -F tcpin
iptables -X tcpin
iptables -F udpin
iptables -X udpin
iptables -F tcpout
iptables -X tcpout
iptables -F udpout
iptables -X udpout
iptables -F server_connections
iptables -X server_connections

#Make user-defined chains
iptables -N tcpin
iptables -N udpin
iptables -N tcpout
iptables -N udpout
iptables -N server_connections

IFS=";" read -r -a PORT_ARRAY <<< "$APPROVED_PORTS" #Create an array of ports

iptables -P INPUT DROP #Set Default Input to Drop all packets
iptables -P OUTPUT DROP #Set Default Output to Drop all packets
iptables -P FORWARD DROP #Set Default Output to Drop all packets

#iptables -A INPUT -p tcp --tcp-flags SYN,ACK,FIN SYN -j DROP #Drop all inbound SYN packets
iptables -A INPUT -p tcp --sport 0:1024 --dport 80 -j DROP #Drop all from ports 0-1024 to 80
iptables -A INPUT -p tcp --tcp-flags SYN,ACK,FIN SYN -j server_connections #Drop all inbound SYN packets

iptables -A INPUT -p tcp --tcp-flags SYN,ACK,FIN SYN,FIN -j DROP # Will drop SIN&FIN, but have to test other drops
iptables -A server_connections -p tcp --dport 22 -j ACCEPT # SSH SYN req
iptables -A server_connections -p tcp --dport 80 -j ACCEPT # HTTP SYN req
iptables -A server_connections -p tcp -j DROP # Add more server requests above, else, drop

# Initial prototype
#for i in "${PORT_ARRAY[@]}"; do #Accept tcp conn for ports destined to the lab
#    iptables -A tcpin -p tcp -d 192.168.1.0/24 --sport $i -j ACCEPT
#done

#------------
# REPLACE WITH CASE STATEMENT
#vvvvvvvvvvvvvvvvvvvvvvvvvvvvvv

for i in "${PORT_ARRAY[@]}"; do #Accepted connections from array above
    if [[ $i -eq 22 ]] # specifically require two-way connections (Server Ports)
    then
        iptables -A tcpin -p tcp --sport $i -j ACCEPT
        iptables -A tcpin -p tcp --dport $i -j ACCEPT
        iptables -A tcpout -p tcp --dport $i -j ACCEPT
        iptables -A tcpout -p tcp --sport $i -j ACCEPT
    elif [[ $i -eq 80 ]] # specifically require two-way connections (Server Ports)
    then
        iptables -A tcpin -p tcp --sport $i -j ACCEPT
        iptables -A tcpin -p tcp --dport $i -j ACCEPT
        iptables -A tcpout -p tcp --dport $i -j ACCEPT
        iptables -A tcpout -p tcp --sport $i -j ACCEPT
    elif [[ $i -eq 67 ]] # for udp only ports
    then
        iptables -A udpin -p udp --sport $i -j ACCEPT
        iptables -A udpout -p udp --dport $i -j ACCEPT
    elif [[ $i -eq 68 ]] # for udp only ports
    then
        iptables -A udpin -p udp --sport $i -j ACCEPT
        iptables -A udpout -p udp --dport $i -j ACCEPT
    elif [[ $i -eq 53 ]] # for tcp and udp ports
    then
        iptables -A tcpin -p tcp --sport $i -j ACCEPT
        iptables -A tcpout -p tcp --dport $i -j ACCEPT
        iptables -A udpin -p udp --sport $i -j ACCEPT
        iptables -A udpout -p udp --dport $i -j ACCEPT
    elif [[ $i -eq 443 ]] # for tcp ports
    then
        iptables -A tcpin -p tcp --sport $i -j ACCEPT
        iptables -A tcpout -p tcp --dport $i -j ACCEPT
    else # is a port that was initally not needed,
        iptables -A tcpout -p tcp --sport $i -j ACCEPT
        iptables -A tcpin -p tcp --dport $i -j ACCEPT
        #iptables -A tcpout -p udp --dport $i -j ACCEPT # Blocks UDP
        #iptables -A tcpin -p udp --sport $i -j ACCEPT # Blocks UDP
    fi
done

iptables -A INPUT -p tcp --sport 0 -j DROP #Drop packets coming from port 0 for tcp
iptables -A INPUT -p udp --sport 0 -j DROP #Drop packets coming from port 0 for udp
iptables -A OUTPUT -p tcp --dport 0 -j DROP #Drop packets heading for port 0 for tcp
iptables -A OUTPUT -p udp --dport 0 -j DROP #Drop packets heading for port 0 for udp

iptables -A INPUT -p tcp -j tcpin #All tcp inputs jump to tcpin
iptables -A INPUT -p udp -j udpin #All udp inputs jump to udpin
iptables -A OUTPUT -p tcp -j tcpout #All tcp outputs jump to tcpout
iptables -A OUTPUT -p udp -j udpout #All udp outputs jump to udpout
