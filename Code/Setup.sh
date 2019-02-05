#!/bin/sh
#-------------
# Setup.sh
# Script made by Connor Phalen and Greg Little
# February 1. 2019: Setup config variables and adapter information
#-------------

# ---- Notes ----
# Prints off the IP of this specific adapter
# ifconfig wlp3s0 | grep "inet " | awk -F'[: ]+' '{ print $3 }'

# prints off active adapter IP's, top one should be most active????
# route | grep "192.168." | awk -F'[: ]+' '{ print $1 }' 

# Gets the adapters that the above IP's use
# route | grep "192.168." | awk -F'[: ]+' '{ print $8 }' 

# Disable/ Enable network adapter. use "nmcli dev" to see list of devices
# nmcli dev disconnect wlp3s0
# nmcli dev connect wlp3s0

# BETTER ALTERNATIVE Disable/ Enable network adapter. use "nmcli dev" to see list of devices
# nmcli connection down ifname wlp3s0
# nmcli connection up ifname wlp3s0

# -------- Possible God Tier Extension Stuff ---------- Ignore for now
# Execute firewall_setup.sh -> Sets firewall rules for Forwarding
# SSH into inner comp, execute inner_setup.sh -> Disables adpt and sets firewall rules
# When done, execute, inner_revert.sh -> SSH into inner comp to revert firewall and adapter changes
# Then run firewall_revert.sh -> Reverts firewall computer back to normal.



# -------- User Config Section -------- #
# Simply modify the names of these adapters to suit needs

FIREWALL_ADPT_EXT="eno1" 		# Exterior Facing Firewall
FIREWALL_ADPT_INT="enp3s2" 		# Exterior Facing Firewall
INNER_ADPT="enp3s2" 			# Interior Isolated Machine
INNER_SUB_IP="192.168.10.2"		# Inner Computer IP on Station #2
FIREWALL_SUB_IP="192.168.10.1"	# Firewall Computer IP on Station #1
FIREWALL_HOST_IP="192.168.0.1"	# Firewall's Default IP

# -------- End User Config Section -------- #


# ---- Variable Setup Section ---- #




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

./forward_gen.sh # Execute next script