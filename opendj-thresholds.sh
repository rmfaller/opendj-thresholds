#!/bin/bash
OPENDJ_HOME=$HOME/opendj
LOGS_HOME=$OPENDJ_HOME/logs
# OPERATIONS="ABANDON~100 ADD~100 BIND~100 DELETE~100 MODIFY~100 MODIFYDN~100 SEARCH~100"
OPERATIONS="BIND~100 MODIFY~500 SEARCH~100"
echo "Operation,total,total-time-ms,threshold,ops-under-threshold,ms-under-threshold,percent-under-threshold,ops-over-threshold,ms-over-threshold"
for oper in $OPERATIONS
  do
  let totalops=0
  let totalms=0
  let opsunder=0
  let opsover=0
  let timeunder=0
  let timeover=0
  operation=`echo $oper | cut -d"~" -f1`
  threshold=`echo $oper | cut -d"~" -f2`
  values=`grep " $operation " $LOGS_HOME/access* | grep etime= | sed 's/.*etime=//' | sort -n | uniq --count | sed "s/^[ \t]*//" | sed "s/ /,/"`
  for value in $values
    do
    opcount=`echo $value | cut -d"," -f1`
    optime=`echo $value | cut -d"," -f2`
    if [[ $optime -eq 0 ]]
      then
      let optime=1
    fi
    let totalops=$totalops+$opcount
    let totalms=$totalms+$(($optime*$opcount))
    if [[ $optime -le $threshold ]]
      then
      let opsunder=$opsunder+$opcount
      let timeunder=$timeunder+$(($optime*$opcount))
    else
      let opsover=$opsover+$opcount
      let timeover=$timeover+$(($optime*$opcount))
    fi
  done
  percentunder=0
  if [[ $totalops -gt 0 ]]
    then
      percentunder=$(echo "scale=2; $opsunder/$totalops*100" | bc)
  fi
  echo "$operation,$totalops,$totalms,$threshold,$opsunder,$timeunder,$percentunder%,$opsover,$timeover"
done
