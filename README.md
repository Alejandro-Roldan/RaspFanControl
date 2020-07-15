# RaspFanControl
A script to automatically control a raspberry fan with the CPU temperature.

Completly written in bash. No libraries and/or extra packages needed.

It works by setting a pin high when the CPU temperature raises above a certain level, and setting it low when it is below that same level.
That means that it works to drive directly the fan by connecting it to the pin, or you can also connect a transistor to the pin to use as a switch and drive the fan with 5V instead.

## Configuration
The temperature threshold, pin nunber and time between checks can be changed in the ```fan-control.sh``` script.

## Install
You can launch this script at startup your preferred way, but also, included with the actual script is a systemd service. To use it place the ```fan-control.service``` inside the ```/etc/systemd/system``` directory and the ```fan-control.sh``` inside ```/usr/local/bin``` (you can change where you place the ```fan-control.sh```, just make sure to specify it inside the ```fan-control.service``` file).

Then run ```systemctl start fan-control.service``` to start the script and ```systemctl enable fan-control.service``` to automatically start it at boot. If you reboot you should see the service as active if you run ```systemctl status fan-control.service```.

Keep in mind that you need to run this script as root user or it will fail. The way I specified above does that.
