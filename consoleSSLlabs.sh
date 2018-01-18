#!/bin/bash
# Call script as such:   ./consoleSSLlabs URLFILE
# URLFILE has the following syntax: first line containing urls, delimited by semicolon ;

api="https://api.ssllabs.com/api/v2/analyze?host="

# Get position of substring in string
strindex() {
  x="${1%%$2*}"
  [[ "$x" = "$1" ]] && echo -1 || echo "${#x}"
}

getResult() {
  ret=$(curl -sS "$api${array[i]}")
  ready=$(strindex "$ret" "\"statusMessage\": \"Ready")
  error=$(strindex "$ret" "\"status\": \"ERROR")
  certinvalid=$(strindex "$ret" "Certificate not valid for domain name")

  if [  $certinvalid -ne "-1" ]
  then
    echo "Scan result of ${array[i]}"
    echo "URL is using an invalid certificate or no https connection can be established."
    echo "<br><br>Scan result of ${array[i]}" >> $resultfilename
    echo "<br><span style=\"color:#FF0000\">URL is using an invalid certificate or no https connection can be established.</span><br><a href=\"https://ssllabs.com/ssltest/analyze.html?d=${array[i]}&hideResults=on&latest\">SSLLabs.com</a>" >> $resultfilename
  fi

  if [  $ready -eq "-1" ]
  then
    if [  $error -ne "-1" ];
    then
      echo "Error with URL ${array[i]} ----> Check manually $api${array[i]}"
      pos=$(strindex "$ret" "\"statusMessage\"")
      endpos=$(strindex "$ret" "\"startTime\"")
      len=$endpos-$pos
      val=${ret:$pos:$len}
      echo "ERROR = $val"
      echo "<br><br><span style=\"color:#FF0000\">Error with URL ${array[i]}, $val</span><br><a href=\"https://ssllabs.com/ssltest/analyze.html?d=${array[i]}&hideResults=on&latest\">SSLLabs.com</a>" >> $resultfilename
       #     "statusMessage": "In progress",
       #     "status": "ERROR",
    fi
  else
    echo "Scan result of ${array[i]}"
    pos=$(strindex "$ret" "\"$1\"")
    endpos=$(strindex "$ret" "\"$2\"")
    len=$endpos-$pos
    val=${ret:$pos:$len}
    echo "$val"
    gradea=$(strindex "$val" "\"grade\": \"A")
    if [  $gradea -ne "-1" ];
    then
      echo "<br><br>Scan result of ${array[i]}<br><span style=\"color:#00B000\">$val</span><br><a href=\"https://ssllabs.com/ssltest/analyze.html?d=${array[i]}&hideResults=on&latest\">SSLLabs.com</a>" >> $resultfilename
    else
      echo "<br><br>Scan result of ${array[i]}<br><span style=\"color:#FF0000\">$val</span><br><a href=\"https://ssllabs.com/ssltest/analyze.html?d=${array[i]}&hideResults=on&latest\">SSLLabs.com</a>" >> $resultfilename
    fi
  fi
}


if [ -z $1 ]; then
  echo "Add URL file as commandline argument. Exiting.."
  exit
fi

urlfile=$(head -n 1 $1)
if [ ${#urlfile} -lt 2 ]; then
echo "Cannot read input file! Exiting.."
exit
fi


set -f
array=(${urlfile//;/ })
urlcount=${#array[@]}

start=`date +%s`
resultfilename="results_`date "+%Y-%m-%d_%H:%M:%S"`.html"
echo "<html>" > $resultfilename
echo "<h1>Qualys SSL Labs Checker </h1><h2>`date "+%Y-%m-%d %H:%M:%S"`</h2>" >> $resultfilename

while true; do
  for i in "${!array[@]}"
  do
      if [ ${#array[i]} -gt 1 ];
      then
        res=$(getResult "grade" "gradeTrustIgnored")
        if [ ${#res} -gt 2 ];
        then
          echo ""
          echo "$((i+1)) / $urlcount - $res"
          array[i]="" #unsetting is for beginners ;)
        fi
      fi
  done

  notfinished=0
  for i in "${!array[@]}"
  do
      if [ ${#array[i]} -gt 1 ];
      then
        notfinished=1
      fi
  done
  if [ $notfinished -ne 1 ];
  then
    end=`date +%s`
    runtime=$((end-start))
    echo "<br><br><i>Script executed in $runtime seconds</i>" >> $resultfilename
    echo "</html>" >> $resultfilename
    exit
  fi
done
