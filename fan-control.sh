#!/bin/bash

############################################################################################################
#
#  RASPBERRY PI AUTOMATIC FAN CONTROL
#
#    This script initializes the fan pin (on a variable defined pin number), exporting it and setting
#    it as output.
#    Checks the CPU temperature, compares it to a variable defined cutoff point and turns the fan
#    On or OFF, then sleeps for a variable defined number of seconds
#
############################################################################################################

# THERES A BUG WITH THE RASPBERRY WHERE YOU NEED TO BE LOGGED AS ROOT TO BE ABLE TO CHANGE THE PINS STATES
# (ALTHOUGH IT IS POSSIBLE TO GET IT TO RUN BY DOING SOME CHANGES TO THE RASPBERRY CONFIGURATION FILES)
# FOR THAT REASON THE SCRIPT STARTS BY CHECKING IF THE SCRIPT IS RUNNING AS ROOT AND IF NOT, EXITS


##################
# INITIALIZATION #
##################

# Set Constants
pin=17
top_cutoff=73
bot_cutoff=68
sleeptime=10

# Initialize the fan state; 0=OFF 1=ON
state=0


## Print initialization messages

echo "Starting fan control script:"

echo "Running as $(whoami)"
# If the user running the script is not root, kill the script
if [[ $(whoami) != 'root' ]]; then
	logger -s "[E] Try running the script as root"
	exit
fi

echo "Set fan on pin $pin"
echo "Set temperature top cutoff point to $top_cutoff ºC"
echo "Set temperature bottom cutoff point to $bot_cutoff ºC"
echo "Checking temperature every $sleeptime seconds"



########
# MAIN #
########

# Check if the pin has already been exported and export it otherwise
# Using a trailing slash on the path makes sure that we are checking for a directory
if [[ ! -d "/sys/class/gpio/gpio$pin/" ]]; then
	# Export pin
	echo $pin > /sys/class/gpio/export
	echo "Exported pin $pin"

	# Set the pin as OUTPUT
	echo out > "/sys/class/gpio/gpio$pin/direction"
	echo "Set pin $pin as OUTPUT"
fi

# Infinite loop 
while true; do
	# Check the temperature of the CPU and feed it to grep to extract only the integer number
	temp=$(/opt/vc/bin/vcgencmd measure_temp | grep -Eo '[0-9]{2}')

	# If the temp is higher than the cutoff and the fan state is not already ON
	if (( $temp >= $top_cutoff )) && (( $state == 0 )); then
		# Turn fan ON, if that suceeds set state=1 and if that suceeds print log msg
		echo 1 > "/sys/class/gpio/gpio$pin/value" &&
		state=1 &&
		echo "Temp=$tempºC: Turning fan ON"

	# If the temp is lower than the cutoff and the fan state is not already OFF
	elif (( $temp < $bot_cutoff )) && (( $state == 1 )); then
		# Turn fan OFF, if that suceeds set state=0 and if that suceeds print log msg
		echo 0 > "/sys/class/gpio/gpio$pin/value" &&
		state=0 &&
		# Info message
		echo "Temp=$tempºC: Turning fan OFF"

	fi

	sleep $sleeptime

done

