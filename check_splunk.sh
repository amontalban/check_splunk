#!/bin/sh
#
# Author: Andres Montalban
# Date: 19/06/2014
# Purpose: Checks Splunk status
#
# Based on Matthew Harman example (http://tuxers.com/main/writing-custom-nagios-check-scripts-plugins/)
#

PROGNAME=`basename $0`
PROGPATH=`echo $0 | sed -e 's,[\\/][^\\/][^\\/]*$,,'`
REVISION=`echo '$Revision: 1.00 $' | sed -e 's/[^0-9.]//g'`
NETSTAT=`which netstat`
PORTS="8089 8000 9997 80 443"

. $PROGPATH/utils.sh

SPLUNKD_STATUS=`service splunk status | grep -i splunkd | cut -d" " -f3`
SPLUNKHELPERS_STATUS=`service splunk status | grep -i "splunk helpers" | cut -d" " -f4`
SPLUNKWEB_STATUS=`service splunk status | grep -i splunkweb | cut -d" " -f3`

if [ ${SPLUNKD_STATUS} = "running" ] ; then
  if [ ${SPLUNKHELPERS_STATUS} = "running" ] ; then
    if [ ${SPLUNKWEB_STATUS} = "running" ] ; then
      SPLUNK_SERVICES_STATUS="OK"
    else
      echo -n "Splunkweb not running: "
      STATUS=`service splunk status | grep -i splunkweb`
      echo ${STATUS}
      exit ${STATE_CRITICAL}
    fi
  else
    echo -n "Splunk helpers not running: "
    STATUS=`service splunk status | grep -i "splunk helpers"`
    echo ${STATUS}
    exit ${STATE_CRITICAL}
  fi
else
  echo -n "Splunkd not running: "
  STATUS=`service splunk status | grep -i splunkd`
  echo ${STATUS}
  exit ${STATE_CRITICAL}
fi

for port in $PORTS; do
  PORT_STATUS=`${NETSTAT} -lna | grep -i LISTEN | grep ":${port} "`
  if [ $? -ne 0 ] ; then
    echo "Splunk TCP port $port not listening!"
    exit ${STATE_WARNING}
  fi
done

if [ ${SPLUNK_SERVICES_STATUS} = "OK" ] ; then
  echo "Splunk is running"
  exit ${STATE_OK}
fi
