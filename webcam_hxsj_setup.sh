#!/bin/bash
#webcam_hxsj_setup.sh:
#A script to bind a webcam with incorrect vendor/model to the proper drivers in Linux. Run as root.
#Written in 2018 by Jonathan Dukes jdukes123@gmail.com
#To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this software to the public domain worldwide. This software is distributed without any warranty.
#You should have received a copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

#productid: bogus vendor and model numbers for the "InTeching 720P HD Webcam model HXSJ"
vendor=1410
model=1410

#Scan USB for device and assign bus and dev variables if found
echo -n "Scanning for device..."
eval $(lsusb | grep "$vendor:$model" | awk '{printf "bus=%s;dev=%s\n",$2+0,$4+0}')
if [ -z "$bus" ]; then
    echo "error - No device found"
    exit
fi
echo "found device on USB $bus-$dev."

cd /sys/bus/usb/drivers

echo -n "Unbinding device..."
for binding in $(find -name "$bus-$dev:*") ; do
    #Scan for driver bindings for the device and assign to driver and port variables
    eval $(awk -F / '{printf "driver=%s;port=%s\n",$2,$3}' <<< $binding )
    #Unbind any currently active drivers
    echo "$port" > "$driver/unbind"
done

#Register camera device with the uvcvideo driver
echo -n "registering camera..."
echo "$vendor $model" > uvcvideo/new_id

#Register microphone device with the snd-usb-audio driver
echo -n "registering microphone..."
echo "$vendor $model" > snd-usb-audio/new_id

echo "done!"
