#!/bin/bash
# I suggest adding this to cron once you have tested it.
# */2 * * * /bin/bash /home/current/cron-split >> /home/current/logs/cron-split.log 2>&1
# Minimum number of UTXOs to maintain 150 seems to work well
MINUTXOS=150
# Amount of UTXOs to create at one time - 50 seems okay
SPLITAMNT=5
#FULL PATH TO chips-cli binary
CHIPSPATH="/usr/local/bin/chips/chips-cli"
# FULL PATH TO komodo-cli binary
KOMODOPATH="/home/current/komodo/src/komodo-cli"

function acsplit {
  echo ""
  RESULT="$(curl -s --url "http://127.0.0.1:7776" --data "{\"coin\":\""${1}"\",\"agent\":\"iguana\",\"method\":\"splitfunds\",\"satoshis\":\"50000\",\"sendflag\":1,\"duplicates\":"${2}"} ")"
  echo "$RESULT"
}

echo "======================================================"
date
echo "======================================================"

# Manual Check of BTC, CHIPS, KMD
echo "Checking BTC, CHIPS, KMD"
cd ~
echo -n BTC
UTXOS="$(bitcoin-cli listunspent | grep .0005 | wc -l)"
echo -n -e '\t\t';echo -n "$UTXOS"
  # Validate that $UTXOS returned an actual number of some sort.
  if [[ $UTXOS == ?([-+])+([0-9])?(.*([0-9])) ]] ||
       [[ $UTXOS == ?(?([-+])*([0-9])).+([0-9]) ]]
    then
     if [ "$UTXOS" -lt "$MINUTXOS" ]
      then 
        echo -n " - SPLITFUNDING BTC"
        acsplit BTC $SPLITAMNT
      fi
    fi
echo ""
echo -n CHIPS
UTXOS="$(/usr/local/bin/chips-cli listunspent | grep .0005 | wc -l)"
echo -n -e '\t\t';echo -n "$UTXOS"
  # Validate that $UTXOS returned an actual number of some sort.
  if [[ $UTXOS == ?([-+])+([0-9])?(.*([0-9])) ]] ||
       [[ $UTXOS == ?(?([-+])*([0-9])).+([0-9]) ]]
    then
      if [ "$UTXOS" -lt "$MINUTXOS" ]
      then
        echo -n "- SPLITFUNDING CHIPS"
        acsplit CHIPS $SPLITAMNT
      fi
    fi
echo ""

echo -n KMD
UTXOS="$($KOMODOPATH listunspent | grep .0005 | wc -l)"
echo -n -e '\t\t';echo -n "$UTXOS"
  # Validate that $UTXOS returned an actual number of some sort.
  if [[ $UTXOS == ?([-+])+([0-9])?(.*([0-9])) ]] ||
       [[ $UTXOS == ?(?([-+])*([0-9])).+([0-9]) ]]
    then
      if [ "$UTXOS" -lt "$MINUTXOS" ]
       then
         echo -n " - SPLITFUNDING KMD"
         acsplit KMD $SPLITAMNT
      fi
    fi
echo ""
echo "Checking Other Coins"
# Check the rest of the coins using a loop
# Feel free to add coins as required here

coinlist=(
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
'VOTE2018'
'NINJA'
)

count=0
while [ "x${coinlist[count]}" != "x" ]
do
  echo -n "${coinlist[count]}"
  UTXOS="$(${KOMODOPATH} -ac_name=${coinlist[count]} listunspent | grep .0005 | wc -l)"
  echo -n -e '\t\t';echo -n "$UTXOS"
  # Validate that $UTXOS returned an actual number of some sort.
  if [[ $UTXOS == ?([-+])+([0-9])?(.*([0-9])) ]] ||
       [[ $UTXOS == ?(?([-+])*([0-9])).+([0-9]) ]]
    then
    if [ "$UTXOS" -lt "$MINUTXOS" ]
       then 
         echo -n " - SPLIT FUNDING: ${coinlist[count]}"
         acsplit ${coinlist[count]} $SPLITAMNT
     fi
  fi
  count=$(( $count +1 ))
  echo ""
done
echo "FINISHED"
