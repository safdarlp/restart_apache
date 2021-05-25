#!/bin/bash
CONFIG="$1"
COMMAND="$2"

# Does the first parameter an actual virtual-host
# Declare a boolean FILEMATCH and set it to false
FILEMATCH=false


# A concatenated string of virtual hosts
VALID_VHOSTS=''

# Grab a list of all virtual-host files
VHOSTS=/etc/apache2/sites-available/*.conf

if [ $# -ne 2 ]
then
    echo -e "ERROR: ${0} requires two paramters \n * a virtual-host configuration \n * a service command"
    exit 1
fi

# Loop through the all files in the sites-avaliable directory
# Build a list of filenames to display in the error message
# If we find a match set $FILEMATCH to true and stop build the list
for FILENAME in $VHOSTS
do

  CURRHOST="${FILENAME:29:-5}"
  # Add each virtual-host in the sites-available directory to 
  # the VHOSTS string. This will provide user feedback if there
  # is an error
  if [ -z  "$VALID_VHOSTS" ]
    then
      VALID_VHOSTS="\n * $CURRHOST"
    else
      VALID_VHOSTS="${VALID_VHOSTS}\n * $CURRHOST"
    fi

  if [ "$FILENAME" == "/etc/apache2/sites-available/${CONFIG}.conf" ]
  then
    # Set $FILEMATCH to true if one of those files matches an actual
    # virtual-host configuration and break the loop
    FILEMATCH=true
    break
  fi
done

# We could not match the firstargument to a virtual-host preset the user with an error
if [ $FILEMATCH  == false ]
then
    echo  "ERROR ${CONFIG} is NOT a valid virtual-host. Please choose from the following ${VALID_VHOSTS}"
    exit 1
fi

if [ "$COMMAND" == "reload" ] || [ "$COMMAND" == "restart" ]
then
    # Move the current execution state to the proper directory
    cd /etc/apache2/sites-available

    # Disable a vhost configuration
    sudo a2dissite "$CONFIG"
    sudo service apache2 "$COMMAND"

    # Enable a vhost configuration
    sudo a2ensite "$CONFIG"
    sudo service apache2 "$COMMAND"
else
    echo  "ERROR: $COMMAND is an invalid service command, either select {restart OR reload}"
    exit 1
fi