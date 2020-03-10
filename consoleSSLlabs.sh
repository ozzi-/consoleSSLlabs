#!/bin/bash

api="https://api.ssllabs.com/api/v3/analyze?host="
resultfilename="results_$(date "+%Y-%m-%d_%H:%M:%S").html"

# Basic Checks
if [ -z "$BASH" ]; then
  echo "Please use BASH."
  exit 3
fi

curl=$(which curl)
if [ $? -ne 0 ]; then
  echo "Please install curl."
  exit 3
fi

# Usage Info
usage() {
  echo '''Usage: consoleSSLlabs.sh [OPTIONS]
  [OPTIONS]:
  -U URLS           Path to file containing the URLs to be scanned, use ; as delimiter (required)
  -O OUTPUT         Output file (HTML report) (default: results_%Y-%m-%d_%H:%M:%S.html)
  -V VERBOSE        Use verbose output'''
}

# Handle Command Line Args
while getopts "U:O:V" opt; do
  case $opt in
    U)
      urlfile=$OPTARG
      ;;
    V)
      verbose=true
      ;;
    O)
      resultfilename=$OPTARG
      ;;
    *)
      usage
      exit 6
      ;;
  esac
done


echo ''
echo ' _ _  _  _ _ | _ (~(~| |  _ |_  _'
echo '(_(_)| |_\(_)|(/__)_)|_|_(_||_)_\  by ozzi-'
echo ""
echo "Using $api"
echo "*********************************"
echo ""


# returns 0 if check successfully
# returns 1 if check failed
# returns 2 if check is still in progress
getResult() {
  ret=$(curl -sS "$api${array[i]}")
  status=$(echo $ret | jq -r '.status')
  statusMessage=$(echo $ret | jq -r '.statusMessage')
  grade=$(echo $ret | jq -r ".endpoints[0].grade")
  progress=$(echo $ret | jq -r ".endpoints[0].progress")

  if [ "$verbose" = true  ] ; then
    echo "${array[i]} - Status = $status - Progress = $progress"
  fi

  if [ "$status" == "ERROR" ]; then
    echo "* Error scanning ${array[i]}"
    echo "  \_ ERROR = $statusMessage"
    echo "  \_ $((i+1)) / $urlcount"
    echo ""
    echo "<br><br><span style=\"color:#FF0000\">Error with URL ${array[i]}, $statusMessage</span><br><a href=\"https://ssllabs.com/ssltest/analyze.html?d=${array[i]}&hideResults=on&latest\">Details</a>" >> $resultfilename
    return 1
  fi

  if [[ ! $grade == "null" ]]; then
    fgrade=$(echo $grade | cut -c1)
    echo "* Scan successful for ${array[i]} - Grade: $grade"
    echo "  \_ $((i+1)) / $urlcount"
    echo ""
    if [[ $fgrade == "A" ]]; then
      color="#00B000"
    elif [[ $fgrade == "B" ]]; then
      color="#999900"
    else
      color="#FF0000"
    fi
    echo "<br><br>Scan result of ${array[i]}<br><span style=\"color:$color\"><b>$grade</b></span><br><a href=\"https://ssllabs.com/ssltest/analyze.html?d=${array[i]}&hideResults=on&latest\">Details</a>" >> $resultfilename
    return 0
  fi

  return 2
}

# Check if we are good to go
if [ -z $urlfile ]; then
  echo "Error: URL file is required"
  usage
  exit 3
fi

urlfile=$(head -n 1 $urlfile)
if [ ${#urlfile} -lt 2 ]; then
  echo "Cannot read input file!"
  exit 4
fi

touch $resultfilename
if ! [[ -w "$resultfilename" ]]; then
   echo "Cannot write to result file!"
   exit 5
fi

# Lets go
set -f
array=(${urlfile//;/ })
urlcount=${#array[@]}

start=`date +%s`
echo "<html>" > $resultfilename
echo "<h1>Qualys SSL Labs Checker </h1><h2>`date "+%Y-%m-%d %H:%M:%S"`</h2>" >> $resultfilename

echo -n "Starting scan for $urlcount URLs"
for i in "${!array[@]}"
do
    printf ". "
    ret=$(curl -sS "$api${array[i]}")
done

echo " "
sleep 2
echo ""
echo "Polling API to check if scans are done, this will take some time"
echo ""

while true; do
  for i in "${!array[@]}"
  do
    if [ ${#array[i]} -gt 1 ]; then
      getResult
      res=$?
      if [ $res -eq 0 ] || [ $res -eq 1 ]; then
        array[i]="" #unsetting is for beginners ;)
      fi
    fi
    sleep 1
  done

  notfinished=0
  for i in "${!array[@]}"
  do
      if [ ${#array[i]} -gt 1 ];
      then
        notfinished=1
      fi
  done

  if [ $notfinished -ne 1 ]; then
    end=`date +%s`
    runtime=$((end-start))
    echo "<br><br><i>Script executed in $runtime seconds</i>" >> $resultfilename
    echo "</html>" >> $resultfilename
    exit
  fi
done
