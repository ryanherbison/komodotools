#!/bin/bash
# Script to report status of processes, utxo's and balances in color
# You can also generate emails with the mailx-command at the bottom
# Suggest using with this command: watch --color -n 60 ./status
# For help contact @herbison on Komodo slack
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
printf "Notary Node Status\n"
printf "==================\n"

function process_check () {
  ps_out=`ps -ef | grep $1 | grep -v 'grep' | grep -v $0`
  result=$(echo $ps_out | grep "$1")
 if [[ "$result" != "" ]];then
    echo "here"
    return 1
  else
    echo "other"
    return 0
fi
}

UP="$(/usr/bin/uptime)"

echo "Server Uptime: $UP"
#TO DO
#ADD UPTIME CHECK
#ADD LOW BALANCE CHECK
#ADD LOW CPU USAGE CHECK

processlist=(
'iguana'
'komodod'
'bitcoind'
'chipsd'
'REVS'
'SUPERNET'
'DEX'
'PANGEA'
'JUMBLR'
'BET'
'CRYPTO'
'HODL'
'MSHARK'
'BOTS'
'MGW'
'COQUI'
'WLC'
'KV'
'CEAL'
'MESH'
'MNZ'
'AXO'
'BTCH'
'ETOMIC'
'PIZZA'
'BEER'
'VOTE2018'
'NINJA'
)

count=0
while [ "x${processlist[count]}" != "x" ]
do
  echo -n "${processlist[count]}"
  #fixes formating issues
  size=${#processlist[count]}
  if [ "$size" -lt "8" ]
  then
    echo -n -e "\t\t"
  else
    echo -n -e "\t"
  fi
  #echo -n -e  "FUNCRETURN="
  #echo $(process_check ${processlist[count]})
  # "$(/home/current/scripts/checkRunningProcess.sh ${processlist[count]})"
  if [ $(process_check $processlist[count]) ]
  then 
    printf "Process: ${GREEN} Running ${NC}"
    if [ "$count" = "1" ]
    then
            cd ~/komodo/src
            RESULT="$(./komodo-cli listunspent | grep .0005 | wc -l)"
            RESULT2="$(./komodo-cli getbalance)"
    fi
    if [ "$count" = "2" ]
    then
            RESULT="$(bitcoin-cli listunspent | grep .0005 | wc -l)"
            RESULT2="$(bitcoin-cli getbalance)"

    fi
    if [ "$count" = "3" ]
    then
            RESULT="$(chips-cli listunspent | grep .0005 | wc -l)"
            RESULT2="$(chips-cli getbalance)"

    fi
    if [ "$count" -gt "3" ]
    then
            cd ~/komodo/src
            RESULT="$(./komodo-cli -ac_name=${processlist[count]} listunspent | grep .0005 | wc -l)"
            RESULT2="$(./komodo-cli -ac_name=${processlist[count]} getbalance)"
    fi
# Check if we have actual results next two lines check for valid number.
    if [[ $RESULT == ?([-+])+([0-9])?(.*([0-9])) ]] ||
       [[ $RESULT == ?(?([-+])*([0-9])).+([0-9]) ]]
    then
    if [ "$RESULT" -lt "70" ]
    then
    printf  " - Avail UTXOs: ${RED}$RESULT\t${NC}"
    else
    printf  " - Avail UTXOs: ${GREEN}$RESULT\t${NC}"
    fi
    fi

    if [[ $RESULT2 == ?([-+])+([0-9])?(.*([0-9])) ]] ||
       [[ $RESULT2 == ?(?([-+])*([0-9])).+([0-9]) ]]
    then
    if (( $(echo "$RESULT2 > 0.05" | bc -l) ));
    then
    printf  " - Avail Funds: ${GREEN}$RESULT2\t${NC}\n"
 #   printf "\t - Current Block: X\t - Longest Chain: X - Last Notarized: X\n"

    else
    printf  " - Avail Funds: ${RED}$RESULT2\t${NC}\n"
#    printf "\t - Current Block: X\t - Longest Chain: X - Last Notarized: X\n"

    fi
    else
      printf "\n"
    fi


    RESULT=""
    RESULT2=""

  else
    printf "Process: ${RED} Not Running ${NC}\n"
    echo "Not Running"
# send an email needs mailx
#    echo "Process: ${processlist[count]} is not Running on Notary NODE GALT_MINES_NA" | mailx -v -r "sendto@someone.com" -s "Alert Process ${processlist[count]} Not Running on GALT_MINES_NA" -S smtp="mail.server.ca:587" -S smtp-use-starttls -S smtp-auth=login -S smtp-auth-user="USERNAME@" -S smtp-auth-password="PASSWORD" -S ssl-verify=ignore EMAILADDRESS@SOMETHING.COM
  fi
  count=$(( $count +1 ))
done
