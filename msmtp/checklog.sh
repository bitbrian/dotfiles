#!/bin/bash

# Author: Marianne Promberger
# Distributed under GNU GPL v2 or later
# No warranty of any kind --  not fit for any purpose

LOGFILE="/home/mpromber/.msmtp.queue.log"  # msmtpQ logfile as set in ~/bin/msmtpQ
LOGFILE2="/home/mpromber/.msmtp-log"       # msmtp logfile as set in ~/.msmtprc

##### First, we check the log file for msmtpQ and msmtpq  #######################

# We check this file for errors, and if there are any, we send mail to the user
# containing the error line(s), then remove them from the logfile (so that it
# won't get reported twice when this script runs before the user checks mail).

if [ -f $LOGFILE ]; then  # check wether the logfile exists
    if [ -n "$(/bin/grep -i error $LOGFILE)" ]; then  
		if
			echo "I'm afraid these errors were in $LOGFILE:$(/bin/grep -i error $LOGFILE)" | mail mpromber@localhost -s "msmtpQ errors"
		then
	    	/bin/sed -i '/[Ee]rror/d' $LOGFILE
		fi
	fi

##### Then, we check for queued mail ##########################################

# Check whether there is queued mail in the queue directory, and if there is, we
# notify the user:

	if [ -n "$(/usr/bin/find /home/mpromber/.msmtp.queue/ -iname '*mail' -print0)" ]; then
		echo "You have $(ls /home/mpromber/.msmtp.queue/*mail | wc -l) queued Mail message(s) in ~/.msmtp.queue. maybe you want to send them with 'msmtpq -r'?" \
    	| mail mpromber@localhost -s "You have queued mail"
	fi
	else  # If the logfile doesn't exist, notify the user:
    	echo "I'm just checking for errors, and there is no file $LOGFILE. Maybe check that everything is okay?" | mail mpromber@localhost -s "No msmtpQ logfile?"
	fi

# Crop logfile so it doesn't get longer than 50 lines:
	if [ "$(wc -l $LOGFILE | cut -d ' ' -f 1)"  -gt 50 ]; then
    	/bin/sed -i '1,10d' $LOGFILE                              # cut first ten lines
	fi

##### Now, the msmtp logfile itself ###################################################

# Check for errors and if needed notify the user, then remove the error lines

	if [ -f $LOGFILE2 ]; then 
    	if [ -n "$(/bin/grep -i error $LOGFILE2)" ]; then   # if there are errors
			if
				echo  "I'm afraid these errors were in $LOGFILE2:$(/bin/grep -i error $LOGFILE2)" | mail mpromber@localhost -s "msmtp errors" # notify the user   
			then
	    		/bin/sed -i '/[Ee]rror/d' $LOGFILE2   # remove the error lines
			fi
    	fi
    	if [ "$(wc -l $LOGFILE2 | cut -d ' ' -f 1)"  -gt 50 ]; then  # if the logfile is too long
			/bin/sed -i '1,10d' $LOGFILE2                            # cut the first 10 lines
    	fi
else         # if there isn't a logfile, notify the user:
    echo -n "~/bin/checklog cannot find a logfile $LOGFILE2. Did you forget to set one?" | mail mpromber@localhost -s "no msmtp logfile?" 
fi


