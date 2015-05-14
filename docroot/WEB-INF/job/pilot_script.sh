#!/bin/sh 
#
# mpi - portlet pilot script
#
# Hostname Grid job can be considered the equivalent of the 'hello world' code
# of computer programming languages.
#
# The following script does:
#   o The hostname
#   o The execution start/end dates
#   o Listing of the worker node' $HOME directory
#   o Listing of the worker node' $PWD current directory
#   o Shows the input file
#   o Simulates the creation of an output file  
# 
# It is kindly suggested to keep all informative echoes
# below; they will help developers and system administrators
# to identify possible troubles
#
# Author: Riccardo Bruno (riccardo.bruno@ct.infn.it)
#

# Get the hostname
HOSTNAME=$(hostname -f)
STARTTS=$(date)

echo "--------------------------------------------------"
echo "Job landed on: '"$HOSTNAME"'"
echo "--------------------------------------------------"
echo "Job execution starts on: '"$STARTTS"'"

#
# AppInfo.sh script (contains portal info and macros)
#
echo "--------------------------------------------------"
# 1st Argument by default points to the PortalInfo script
PORTAL_INFO=$1
if [ ! -z $PORTAL_INFO -a -f $(basename "${PORTAL_INFO}") ]
then
  SG_PORTAL_INFO=$(basename $1)
  echo "Sourcing PortalInfo script"
  chmod +x $SG_PORTAL_INFO
  . ./$SG_PORTAL_INFO
   
  echo "Testing portal info values:"
  echo "---------------------------"
  echo "SG_PORTAL_SCREEN_NAME: '${SG_PORTAL_SCREEN_NAME}'"
  echo "SG_PORTAL_USER_EMAIL : '${SG_PORTAL_USER_EMAIL}'"
  echo "SG_PORTAL_NAME       : '${SG_PORTAL_NAME}'" 
  echo "SG_PORTAL_APP_ID     : '${SG_PORTAL_APP_ID}'"
  echo "SG_PORTAL_APP_NAME   : '${SG_PORTAL_APP_NAME}'"
  echo "SG_PORTAL_JOB_DESC   : '${SG_PORTAL_JOB_DESC}'"
  echo "SG_PORTAL_MIDDLEWARE : '${SG_PORTAL_MIDDLEWARE}'"
else
  echo "WARNING: No portal info script given as argument"
fi
echo "--------------------------------------------------"

# Multi-middleware
case "${SG_PORTAL_MIDDLEWARE}" in
  "glite")
  #
  # Multi-infrastructure job submission needs
  # to build some environment variables
  # if the application needs a sw directory
  # set and uncomment the SW_NAME value
  # then enable code lines related to PATH and
  # LD_LIBRARY_PATH settings 
  # hostname example does not require to define
  # library and path directories
  #
  #SW_NAME="MyAppDir" # Place here the software dir name and uncomment it
  VO_NAME=$(voms-proxy-info -vo)
  VO_VARNAME=$(echo $VO_NAME | sed s/"\."/"_"/g | sed s/"-"/"_"/g | awk '{ print toupper($1) }')
  VO_SWPATH_NAME="VO_"$VO_VARNAME"_SW_DIR"
  VO_SWPATH_CONTENT=$(echo $VO_SWPATH_NAME | awk '{ cmd=sprintf("echo $%s",$1); system(cmd); }')

  echo "Multi infrastructure variables:"
  echo "-------------------------------"
  echo "VO_NAME          : "$VO_NAME
  echo "VO_VARNAME       : "$VO_VARNAME
  echo "VO_SWPATH_NAME   : "$VO_SWPATH_NAME
  echo "VO_SWPATH_CONTENT: "$VO_SWPATH_CONTENT

  #
  # Assign PATH and LD_LIBRARY_PATH
  #
  # You may assign VO specific values uncommenting the
  # lines below
  #
  #case $VO_NAME in
  #    'prod.vo.eu-eela.eu')
  #    export PATH=$PATH:$VO_SWPATH_CONTENT/$SW_NAME/bin
  #    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$VO_SWPATH_CONTENT/$SW_NAME/lib
  #    ;;
  #    'cometa')
  #    export PATH=$PATH:$VO_SWPATH_CONTENT/$SW_NAME/bin
  #    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$VO_SWPATH_CONTENT/$SW_NAME/lib    
  #    ;;
  #    'eumed')
  #    export PATH=$PATH:$VO_SWPATH_CONTENT/$SW_NAME/bin
  #    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$VO_SWPATH_CONTENT/$SW_NAME/lib
  #    ;;
  #    *)
  #    echo "ERROR: Unsupported VO '"$VO_NAME"'"
  #    exit 1
  #esac
  #
  # Otherwise use a common setting like:
  #
  #export PATH=$PATH:$VO_SWPATH_CONTENT/$SW_NAME/bin
  #export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$VO_SWPATH_CONTENT/$SW_NAME/lib
  #echo
  #echo "PATH and LD_LIBRARY_PATH:"
  #echo "-------------------------"
  #echo "PATH: "$PATH
  #echo "LD_LIBRARY_PATH: "$LD_LIBRARY_PATH
  # Check if the software directory exists
  #echo
  #echo "Software directory : '"$VO_SWPATH_CONTENT/$SW_NAME"'"
  #echo "------------------"
  #ls -ld $VO_SWPATH_CONTENT/$SW_NAME
  #echo
  ;;
  "unicore")
  echo "unicore specific settings ..."
  ;;
  "wsgram")
  echo "wsgram specific settings ..."
  ;;
  "ourgrid")
  echo "OurGrid specific settings ..."
  ;;
  *)
  echo "Unsupported middleware: '${SG_PORTAL_MIDDLEWARE}'"
esac
  
##
## Pilot script main code ...
##

# You may ovverride these values in order to point 
# a different Science Gateway Job Perusal service
SG_PORTAL_SGJP_SERVER=jessica.trigrid.it
SG_PORTAL_SGJP_PORT=8660

# Notify user about job execution start
job_notify_start


echo "---[WN HOME directory]----------------------------"
ls -l $HOME

echo "---[WN Working directory]-------------------------"
ls -l $(pwd)

echo "---[EXECUTION ... ]-------------------------------"
##
## Multimiddleware 
##
## In this demo the different middleware are chosed at
## portlet java code level by the GridEngine setExecutable 
## statement
case "${SG_PORTAL_MIDDLEWARE}" in
  "glite")
  # Enable the x flag to mpi wrappers
  chmod +x mpi-start-wrapper.sh 
  chmod +x mpi-hooks.sh

  # Now call the mpi-start-wrapper
  ./mpi-start-wrapper.sh cpi mpich2 
  ;;
*)
    echo "Unsupported middleware at pilot_script.sh level"
esac

echo "---[end timestamp]------------------------------"
date

# Notify user about job execution stop
ENDTS=$(date)
job_notify_stop
