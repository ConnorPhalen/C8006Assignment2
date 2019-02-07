#!/bin/sh
#-------------
# Setup.sh
# Script made by Connor Phalen and Greg Little
# February 1. 2019: Setup config variables and adapter information
#-------------

# ---- Notes ---- #


# -------- User Config Section -------- #
# Simply modify the names of these adapters to suit needs

FIREWALL_ADPT_EXT="eno1" 		# Exterior Facing Firewall
FIREWALL_ADPT_INT="enp3s2" 		# Exterior Facing Firewall
INNER_ADPT="enp3s2" 			# Interior Isolated Machine
INNER_SUB_IP="192.168.10.2"		# Inner Computer IP on Station #2
FIREWALL_SUB_IP="192.168.10.1"	# Firewall Computer IP on Station #1
FIREWALL_BASE_SUB="192.168.10.0" # Firewall Computer Base Subnet
FIREWALL_HOST_IP="192.168.0.1"	# Firewall's Default IP
FIREWALL_MASK="255.255.255.0"   # Firewall Mask
DNS_NAMESERVER="142.232.76.191"	# DNS Server

# -------- End User Config Section -------- #


# ---- Variable Setup Section ---- #
APRROVED_SERVICES="20;21;22"    #Approved Services (mainly data Services)
APPROVED_TCP_PORTS="80;443"     #Approved ports for TCP Ports
APPROVED_UDP_PORTS="53"         #Approved ports for UDP Ports
APPROVED_ICMP="0;3;4;8;11"      #Approved ports for ICMP Types

DENIED_TCP="23;111;515;137;139;1024;32768;32775;65535" # Specific Denied Ports
DENIED_UDP="23"

#IFS=";" read -r -a PORT_ARRAY <<< "$APPROVED_PORTS" #Create an array of ports

#Port Breakdown
# 20 - FTP (tcp)
# 21 - FTP (tcp)
# 22 - SSH (tcp)
# 53 - DNS (tcp and udp)
# 67 - DHCP (udp)
# 68 - DHCP (udp)
# 80 - http (tcp)
# 443- SSL (tcp)

#ICMP Breakdown
# 0 - Echo Reply
# 3 - Destination Unreachable
# 4 - Source Quench
# 8 - Echo
# 11- TTL Exceeded # Possibly Remove This


#FIREWALL_IP_EXT="$(ifconfig "$FIREWALL_ADPT_EXT" | grep "inet " | awk -F'[: ]+' '{ print $3 }')"
#FIREWALL_IP_INT="0.0.0.0"
#INNER_IP="192.168.0.11"

#echo "$FIREWALL_IP_EXT"

# ---- Export and Script Execution Section ---- #
#export IIP="$INNER_IP" # Export variable for use in the next scripts, alt: source next scripts to use the variables

export FAE="$FIREWALL_ADPT_EXT"
export FAI="$FIREWALL_ADPT_INT"
export IA="$INNER_ADPT"
export FSI="$FIREWALL_SUB_IP"
export FHI="$FIREWALL_HOST_IP"
export ISI="$INNER_SUB_IP"
export FM="$FIREWALL_MASK"
export FBS="$FIREWALL_BASE_SUB"
export APRROVED_SERVICES="$APRROVED_SERVICES"
export APPROVED_TCP_PORTS="$APPROVED_TCP_PORTS"
export APPROVED_UDP_PORTS="$APPROVED_UDP_PORTS"
export APPROVED_ICMP="$APPROVED_ICMP"
export DNS_NAMESERVER="$DNS"

#./forward_gen.sh   # Execute Firewall script
#./inner_gen.sh     # Execute Inner Computer script
