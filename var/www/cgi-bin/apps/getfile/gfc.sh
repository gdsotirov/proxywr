# GetFile Checker 0.1 (2004-06-25)
# 
# Written by George D. Sotirov <gsotirov@obs.bg>
#
# Check if given URL is valid or not.

#!/bin/bash

# Defaults
WGET_NAME_DFLT=wget

# Search for the config file
if [ -e gf.conf ]; then
  CONFIG=gf.conf
else
  if [ -e /etc/gf.conf ]; then
    CONFIG=gf.conf
  else
    echo "${SCRIPT}: Error: Can't find config file neither in the current dir ot /etc!"
    exit -1
  fi
fi

. $CONFIG

# Functions
print_msg() {
  MSG=$1
  if [ $CGI == 1 ]; then
    CURR_DATE=$(date)
    LOG_LINE="${CURR_DATE} : ${MSG}"
    echo $LOG_LINE >> $LOG_FILE
  else
    echo $MSG
  fi
}

# Try to find wget command and determine its options
WGET_NAME=${WGET_NAME:-$WGET_NAME_DFLT}
WGET_DFLT_PATH=$(which $WGET_NAME)
WGET_CMD=${WGET_PATH:-$WGET_DFLT_PATH}
if [ ! -x $WGET_CMD ]; then
  print_msg "${SCRIPT}: Error: Can't execute the ${WGET_NAME} command '${WGET_CMD}'!"
  exit -4
fi

URL=$1

$WGET_CMD --spider $URL 1>/dev/null 2>/dev/null

if [ $? == 0 ]; then
  if [ $CGI == 0 ]; then
    echo "The URL '${URL}' is valid."
  fi
else
  if [ $CGI == 0 ]; then
    echo "The URL '${URL}' is invalid!"
  fi
fi

