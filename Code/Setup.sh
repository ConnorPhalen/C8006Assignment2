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

# -------- Possible God Tier Extension Stuff ---------- Ignore for now
# Execute firewall_setup.sh -> Sets firewall rules for Forwarding
# SSH into inner comp, execute inner_setup.sh -> Disables adpt and sets firewall rules
# When done, execute, inner_revert.sh -> SSH into inner comp to revert firewall and adapter changes
# Then run firewall_revert.sh -> Reverts firewall computer back to normal.



# -------- User Config Section -------- #
# Simply modify the names of these adapters to suit needs

FIREWALL_ADPT_EXT="wlp3s0" 	# Exterior Facing Firewall
FIREWALL_ADPT_INT="eth1" 	# Exterior Facing Firewall
INNER_ADPT="eth0" 			# Interior Isolated Machine

# -------- End User Config Section -------- #


# ---- Variable Setup Section ---- #
FIREWALL_IP_EXT="$(ifconfig "$FIREWALL_ADPT_EXT" | grep "inet " | awk -F'[: ]+' '{ print $3 }')"
FIREWALL_IP_INT="0.0.0.0"
INNER_IP="192.0.2.100" 

echo "$FIREWALL_IP_EXT"


# ---- Export and Script Execution Section ---- #
export IIP="$INNER_IP" # Export variable for use in the next scripts, alt: source next scripts to use the variables

.forward_gen.sh # Execute next script