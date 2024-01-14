#!/bin/sh
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
NC='\033[0m' # No Color


main() {
  while true;
  do
    banner

    read -p " -Enter option number: " choice
    
    case $choice in
      1)
        new_sip_user
        ;;
      2)      
        delete_sip_user
        ;;
      3)
        show_users
        ;;
      4)
        quit
        ;;
      *)
        invalid_option
        ;;
    esac

  done
}

banner() {
  clear

  echo -e "${YELLOW}     ___________ ________ 
    / ____/ ___//  _/ __ \\
   / / __ \__ \ / // /_/ /
  / /_/ /___/ // // ____/ 
  \____//____/___/_/      
                          
    SIP Server Manager"
  echo " "
  echo -e "${YELLOW} 1.${NC} ${CYAN} New SIP User ${NC}"
  echo -e "${YELLOW} 2.${NC} ${CYAN} Delete SIP User ${NC}"
  echo -e "${YELLOW} 3.${NC} ${CYAN} Show Users ${NC}"
  echo -e "${YELLOW} 4.${NC} ${RED} EXIT ${NC}"
  echo " "
}

new_sip_user() {
  dialplan=${sed -nr 's/exten => _(X+),.+/\1/p' /etc/asterisk/extensions.conf}
  user=0
  while  [ $user -lt 1 ]; 
  do
    read -p " -Enter SIP User: (* ${#dialplan} digits numbers $dialplan *) : " user
    if ! [[ $user =~ ^[0-9]+$ ]]; 
      then exec >&2; echo -e "${RED}  ERROR : ${user} is not a number! ${NC}"; user=0; sleep 1;
    else 
      if ! [[ ${#user} -eq ${#dialplan} ]];
        then exec >&2; echo -e "${RED}  ERROR : ${user} needs to be ${#dialplan} digits! ${NC}"; user=0; sleep 1;
      fi
    fi
  done
  read -p " -Enter SIP Password: " pass

  USR=`grep -o "aors = ${user}" /etc/asterisk/pjsip.conf | grep -o '[[:digit:]]*' | sed -n '1p'`

  if [ "$USR" == "${user}" ]; then
    echo -e "${RED}  ERROR : User ${user} already exists ${NC}" 
    sleep $SL
  else
    echo "			
    [${user}] ;${user}
    type = endpoint ;${user}
    context = internal ;${user}
    disallow = all ;${user}
    allow = alaw ;${user}
    aors = ${user} ;${user}
    auth = auth${user} ;${user}
    direct_media = no ;${user}

    [${user}] ;${user}
    type = aor ;${user}
    max_contacts = 1 ;${user}
    support_path = yes ;${user}

    [auth${user}] ;${user}
    type=auth ;${user}
    auth_type=userpass ;${user}
    password=${pass} ;${user}
    username=${user} ;${user}
    ">> /etc/asterisk/pjsip.conf
              
    echo -e "${GREEN}  User ${user} Created Successfully ${NC}"  
    
    service asterisk restart
    sleep 3  
  fi
}

delete_sip_user() {
  dele=0
  while  [ $dele -lt 1 ]; 
  do
    read -p " -Enter SIP User: " dele
    if ! [[ $dele =~ ^[0-9]+$ ]]; 
      then exec >&2; echo -e "${RED}  ERROR : ${dele} is not a number! ${NC}"; dele=0; sleep 1;
    fi
  done
			
	PUSR=`grep -o "aors = ${dele}" /etc/asterisk/pjsip.conf | grep -o '[[:digit:]]*' | sed -n '1p'`

  if [ "$PUSR" == "${dele}" ]; then
    sed -i "/\;$dele\>/d" /etc/asterisk/pjsip.conf	
    echo -e "${GREEN}  User Deleted Successfully ${NC}"
    service asterisk restart
  else
    echo -e "${RED}  ERROR : User ${dele} is not exists ${NC}"              
  fi
  sleep 3
}

show_users() {
  asterisk -rx "pjsip list endpoints"
  echo ""
  echo -e "  Press ${RED}ENTER${NC} to continue"
  read -s -n 1
}

quit() {
  echo ""
  echo -e "${GREEN}Exiting...${NC}"
  exit 0
}

invalid_option() {
  echo "  Invalid option !"
  echo ""
  echo -e "  Press ${RED}ENTER${NC} to continue"
  read -s -n 1
}


main "$@"; exit