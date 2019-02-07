#!/bin/sh
#-------------
# rule_testing.sh
# Script made by Connor Phalen and Greg Little
# February 6, 2019: Setup Test Scripts
#-------------

# ---- Test Config ----
PORT_RANGE="1;1024" 		# Range of ports to test from min to max
SPECIFIC_TESTS="22;80;443"	# Specific ports to test
FIP="192.168.10.1"			# Firewall IP
IIP="192.168.10.2"			# Inner IP
TIP="192.168.40.1"			# Test IP

IFS=";" read -r -a TEST_RANGE <<< "$PORT_RANGE" # Create an array of ports

# ---- Test Section: PORT RANGES ---- #
min="${TEST_RANGE[0]}"
max="${TEST_RANGE[1]}"

while [ $min -le $max ] 
do 
	hping3 "$FIP" -p "$min" -c 2
	((min++)) # Increment min
done


# ---- Test Section: SPECIFIC PORTS ---- #
