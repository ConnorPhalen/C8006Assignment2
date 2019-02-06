#!/bin/sh
#-------------
# iptable_gen.sh
# Script made by Connor Phalen
# February 2, 2019: Initial user chain setup
# February 4, 2019: Setup Inner Computer Setup Rules
# February 5, 2019: Added Inner Firewall Rules
#-------------

#Varibale Section
#APPROVED_PORTS="20;21;22;53;67;68;80;443" # In Setup.sh

# Setup the connection details
# REPLACE THESE VALUES WITH THE EXPORTED ONES
ifconfig eno1 down                          # Disable the internet connected device
ifconfig enp3s2 down                        # Disable the Firewall connection device
ifconfig ifconfig enp3s2 192.168.10.2 up    # Setup the Inner IP connection to the device
route add default gw 192.168.10.1           # Setup the default routing gateway to be the Firewall

# Echo the nameserver to the resolv.conf file, as it flushes every so often
echo "nameserver 142.232.76.191" > /etc/resolv.conf  # Set the name server to be the name server


#Port Breakdown
# 20 - FTP (tcp)
# 21 - FTP (tcp)
# 22 - SSH (tcp)
# 53 - DNS (tcp and udp)
# 67 - DHCP (udp)
# 68 - DHCP (udp)
# 80 - http (tcp)
# 443- SSL (tcp)

#Backups to flush and delete user chains in case they already exist
iptables -F INPUT
iptables -F OUTPUT

IFS=";" read -r -a PORT_ARRAY <<< "$APPROVED_PORTS" #Create an array of ports

iptables -P INPUT DROP #Set Default Input to Drop all packets
iptables -P OUTPUT DROP #Set Default Output to Drop all packets
iptables -P FORWARD DROP #Set Default Forward to drop packets
