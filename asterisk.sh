#!/bin/sh
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
NC='\033[0m' # No Color

URLBASE="https://raw.githubusercontent.com/ExtraordinaryBen/sip-server-router-wizard/main"

echo -e "${GREEN}Originally Made With Love By : AmirHossein Choghaei${NC}"
echo -e "${MAGENTA}Modified For Personal Use By : ExtraordinaryBen${NC}"

echo "Running as root..."
sleep 2
clear


opkg update

opkg install asterisk asterisk-pjsip asterisk-bridge-simple asterisk-codec-alaw asterisk-codec-ulaw asterisk-res-rtp-asterisk

rm /etc/asterisk/extensions.conf
>/etc/asterisk/pjsip.conf

cd /etc/asterisk/

DIGITS=0

while  [ $DIGITS -lt 1 ]; 
do
  read -p "Enter number of digits for Dial Plan: " DIGITS 
  if ! [[ "$DIGITS" =~ ^[0-9]+$ ]] ; 
    then exec >&2; echo "error: Not a number"; DIGITS=0;
  fi
done

DIALPLAN="_"
for i in $(seq $DIGITS); do DIALPLAN+="X"; done

echo "[internal]
exten => $DIALPLAN,1,Dial(PJSIP/\${EXTEN})

" >> /etc/asterisk/extensions.conf

echo "[simpletrans]
type=transport
protocol=udp
bind=0.0.0.0

" >> /etc/asterisk/pjsip.conf

uci set asterisk.general.enabled='1'

sed -i "s/option enabled '0'/option enabled '1'/g" /etc/config/asterisk 

service asterisk restart

sleep 5

cd

rm -f gsip.sh && wget $URLBASE/gsip.sh && chmod 777 gsip.sh

cp gsip.sh /sbin/gsip


