# GetFile Shell Script 0.1
#
# Written by George D. Sotirov <gsotirov@obs.bg>
#
# Request file to be downloaded and renamed, so it can be downloaded
# thru restrictive proxies.
#

#!/bin/bash

# Uncomment the following line to enable debug
set -x

# Defaults
TMP_DIR_DFLT=/tmp
R_DIR_DFLT=/tmp/requests
LOG_FILE_DFLT=/var/log/getfile.log
WGET_NAME_DFLT=wget
WGET_TRIES_DFLT=5
WGET_TIMEOUT_DFLT=30s

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

# Input parameters
SCRIPT=$0
REQUESTER=$1
URL=$2

if [ $CGI == 1 ]; then
  SCRIPT="${SCRIPT} (${$})"
fi

print_msg "${SCRIPT}: Info: Processing file ${URL} requested by ${REQUESTER}"

LOG_FILE=${LOG_FILE:-$LOG_FILE_DFLT}

# Create the temporary dir if not created yet
TMP_DIR=${TMP_DIR:-$TMP_DIR_DFLT}
if [ -e $TMP_DIR ]; then
  if [ ! -d $TMP_DIR ]; then
    print_msg "${SCRIPT}: Error: The temporary directory '${TMP_DIR}' is not a directory!"
    exit -2
  fi
else
  mkdir $TMP_DIR
  if [ $? != 0 ]; then
    print_msg "${SCRIPT}: Error: Can't create temporary directory '${TMP_DIR}'!"
    exit -3
  fi
fi

# Try to create the requests directory if no created yet
R_DIR=${R_DIR:-$R_DIR_DFLT}
if [ -e $R_DIR ]; then
  if [ ! -d $R_DIR ]; then
    print_msg "${SCRIPT}: Error: The requests directory '${R_DIR}' is not a directory!"
    exit -2
  fi
else
  mkdir $R_DIR
  if [ $? != 0 ]; then
    print_msg "${SCRIPT}: Error: Can't create temporary directory '${R_DIR}'!"
    exit -3
  fi
fi

# Try to find wget command and determine its options
WGET_NAME=${WGET_NAME:-$WGET_NAME_DFLT}
WGET_DFLT_PATH=$(which $WGET_NAME)
WGET_CMD=${WGET_PATH:-$WGET_DFLT_PATH}
if [ ! -x $WGET_CMD ]; then
  print_msg "${SCRIPT}: Error: Can't execute the ${WGET_NAME} command '${WGET_CMD}'!"
  exit -4
fi
WGET_TRIES=${WGET_TRIES:-$WGET_TRIES_DFLT}
WGET_TIMEOUT=${WGET_TIMEOUT:-$WGET_TIMEOUT_DFLT}
WGET_OPTNS="-t $WGET_TRIES --waitretry=$WGET_TIMEOUT -c"

R_FILE=$(basename $URL)
L_FILE="${R_DIR}/${R_FILE}"
TMP_FILE_PATH="${TMP_DIR}/${R_FILE}"
DESCR_FILE="${R_DIR}/${R_FILE}.txt"

print_msg "${SCRIPT}: Info: Start retrieving file ${URL}"

RETRIEVE_CMD_STR="${WGET_CMD} ${WGET_OPTNS} -O ${TMP_FILE_PATH} ${URL}"

echo "Requested URL : ${URL}" > $DESCR_FILE
echo "Local file    : ${L_FILE}" >> $DESCR_FILE
echo "Command line  : ${RETRIEVE_CMD_STR}" >> $DESCR_FILE
echo "Command output:" >> $DESCR_FILE

$WGET_CMD $WGET_OPTNS -O $TMP_FILE_PATH $URL 1>> $DESCR_FILE 2>> $DESCR_FILE

if [ $? != 0 ]; then
  print_msg "${SCRIPT}: Error: Error retrieving file ${URL}!"
  exit -5
fi

print_msg "${SCRIPT}: Info: Finished retrieving file ${URL}."

