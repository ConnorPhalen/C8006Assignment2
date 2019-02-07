#!/bin/sh
#-------------
# rule_testing.sh
# Script made by Connor Phalen and Greg Little
# February 6, 2019: Setup Test Scripts
#-------------

# ---- Test Config ----
PORT_RANGE="1;1024"         # Range of ports to test from min to max
HIGH_PORTS="1025-65535" # high ports that need to be checked

PORTS_1="32768-32775"
PORTS_2="137-139"
PORTS_3="111,515"

DEST="192.168.0.1"
SPOOF="192.168.10.5"

FILE="results.txt"


# ---- Test Section: PORT RANGES ---- 
  echo STARTING SCRIPT


hping3 $DEST -S -p 80 -c 2 -k -V &>$FILE
hping3 $DEST -S -F -p 80 -c 2 -k -V &>>$FILE
echo might want to get a coffee or something
hping3 $DEST -S -p 443 -c 2 -k -V &>>$FILE
hping3 $DEST -p 443 -c 2 -k -V &>>$FILE

hping3 $DEST -S -a $SPOOF -c 2 -V &>>$FILE
hping3 $DEST -a $SPOOF -c 2 -V &>>$FILE
hping3 $DEST -a $SPOOF -p 80 -c 2 -V &>>$FILE


hping3 $DEST -2 -d 100 -f -c 2 -V &>>$FILE

hping3 $DEST -p 23 -k -c 2 -V &>>$FILE
hping3 $DEST -s 23 -k -c 2 -V &>>$FILE
hping3 $DEST -S -p 23 -k -c 2 -V &>>$FILE
echo soooo how you been?
hping3 $DEST -1 -K 0 -c 5 -V &>>$FILE
hping3 $DEST -1 -K 3 -c 5 -V &>>$FILE
hping3 $DEST -1 -K 4 -c 5 -V &>>$FILE
hping3 $DEST -1 -K 8 -c 5 -V &>>$FILE
hping3 $DEST -1 -K 11 -c 5 -V &>>$FILE

echo HALFWAY THERE :0

hping3 $DEST -8 $PORTS_1 -V &>>$FILE
hping3 $DEST -8 $PORTS_2 -V &>>$FILE
echo "alright now you're half way I hope"
hping3 $DEST -8 $PORTS_3 -V &>>$FILE
echo "you've made it this far"
hping3 $DEST -8 $HIGH_PORTS -V &>>$FILE

echo DONE
echo "sorry :("
        # ---- Test Section: SPECIFIC PORTS ---- #

