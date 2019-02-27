#/bin/sh
#webcam_hxsj_setup.sh:
#A script to bind a webcam with incorrect vendor/model to the proper drivers in Linux. Run as root.
#Written in 2018 by Jonathan Dukes jdukes123@gmail.com
#To the extent possible under law, the author(s) have dedicated all copyright and related 
#and neighboring rights to this software to the public domain worldwide. 
#
#This software is distributed without any warranty.
#You should have received a copy of the CC0 Public Domain Dedication
#along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
#CHANGELOG:
#JD v1.0: Initial version
#JD v1.1: Rewrote device port detection routine to allow a Raspberri PI to use the webcam


#Enter bogus vendor and model numbers for the webcam:
vendorid=1410 #  InTeching 720P HD Webcam model HXSJ vendor ID
productid=1410 # InTeching 720P HD Webcam model HXSJ product ID

devicedir="/sys/bus/usb/devices"
driverdir="/sys/bus/usb/drivers"

#Unbind the device from any drivers it is currently assigned to
unbind () {
   #Scan for currently active driver bindings
   for binding in $(find "$driverdir/" -name "$device:*") ; do
	  #Assign $driver to the driver directory and $interface specific device interface
      driver=$(echo $binding | cut -d '/' -f 6)
      interface=$(echo $binding | cut -d '/' -f 7)
      echo "Unbinding $interface from $driver."
      #Remove the driver binding by putting the interface id into the unbind file
      echo "$interface" > "$driverdir/$driver/unbind"
   done
}

echo -n "Scanning for matching devices"
found=0
for device in $(ls $devicedir) ; do
   echo -n "."
   if [ -f "$devicedir/$device/idVendor" ] && 
      [ $(cat "$devicedir/$device/idVendor") = "$vendorid" ] &&
      [ $(cat "$devicedir/$device/idProduct") = "$productid" ]; then
      echo ""
      echo "Found device on USB $device"
      found=$((found+1))
      unbind
   fi
done

if [ $found -gt 0 ] ; then
	#Register camera device with the uvcvideo driver
	echo ""
	echo "Found $found devices"
	echo "Registering camera(s) as uvcvideo..."
	echo "$vendorid $productid" > "$driverdir/uvcvideo/new_id"

	#Register microphone device with the snd-usb-audio driver
	echo "Registering microphone(s) as snd-usb-audio..."
	echo "$vendorid $productid" > "$driverdir/snd-usb-audio/new_id"

	echo "Done!"
else
	echo "no devices found with vendorID $vendorid and productID $productid."
fi
