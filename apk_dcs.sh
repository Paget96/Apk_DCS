#!/bin/bash
# Copyright (C) 2015 Paget96@xda
# APKtool by The Android Open Source Project
# Thanks to Zipalign/sign script for Linux by aureljared@XDA.
#=======================================================================#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.
#=======================================================================#

while true; do

echo "1. Decompile"
echo "2. Compile"
echo "3. Signing .apk package"
echo ""
echo -n "Please select an option: "
read -r option

if [ "$option" -eq 1 ]; then
echo -n "Filename without .apk extension: "
read -r appname
	if [ -f $appname.apk ]; then
			sh ./binary/apktool/apktool d $appname.apk
			echo "Apk file is decompiled"
		else
			echo -e "$appname.apk doesn't exist. Check file name!!!"
	fi
sleep 2
clear
	elif [ "$option" -eq 2 ]; then
		echo -n "Filename without .apk extension: "
		read -r appfolder
			if [ -d ./$appfolder ]; then
 				cd ./$appfolder
 				java -jar ../binary/apktool/apktool.jar b -d -o ../Output/$appfolder+modified.apk
				cd ..
				echo "Apk file is compiled"
			else
				echo -e "$appfolder doesn't exist. Check source folder!!!"
		fi
	sleep 2
clear	
	elif [ "$option" -eq 3 ]; then
# Remove scroll buffer
echo -e '\0033\0143'

# Colourful terminal output (from AOSPA building script)
cya=$(tput setaf 6)             #  cyan
txtbld=$(tput bold)             # Bold
bldred=${txtbld}$(tput setaf 1) #  red
bldgrn=${txtbld}$(tput setaf 2) #  green
bldcya=${txtbld}$(tput setaf 6) #  cyan

# Phase 1
echo -e "${bldcya}Enter the name of the apk you want to sign."
echo -e "${bldcya}Example: ${cya}SystemUI"
echo -e ""
echo -e "${bldred}NOTES:"
echo -e "${cya}What you enter here will also be the filename of your final APK."
echo -e "${cya}APK must be in the same folder as this script."
echo -n "Filename without .apk extension: "
read appname

# Check existence
if [ -f $appname.apk ]
then
	echo -e ""
	echo -e "${bldgrn}APK exists."
else
	echo -e "${bldred}$appname.apk does not exist. Exiting..."
	exit 1
fi

# Phase 2
echo -e "${bldgrn}Signing APK..."
java -jar ./binary/zipaligner/signapk.jar ./binary/testkey.x509.pem ./binary/testkey.pk8 $appname.apk temp.apk

# Check existence
if [ -f temp.apk ]; then
	mv $appname.apk $appname-original.apk
	clear
	echo -e "${bldgrn}Zipaligning..."
else
	echo -e "${bldred}FATAL: Temporary APK not found. Exiting..."
	exit 1
fi

# Phase 3
chmod a+x ./binary/zipaligner/zipalign
./binary/zipalign -f -v 4 temp.apk $appname.apk

# Check existence
if [ -f $appname.apk ]
then
	rm temp.apk
	echo -e "${bldcya}Would you like to push to your device now?"
else
	echo -e "${bldred}FATAL: Final APK does not exist. Exiting..."
    mv $appname-original.apk $appname.apk
	exit 1
fi

# Push to device
read -p "y/n: " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]
then
	echo -e '\0033\0143'
	chmod a+x ./adb
	echo -e "${cya}Firing up ADB 1.0.31..."
	./binary/zipaligner/adb start-server
	echo -e "${cya}Waiting for device - make sure device is connected in ${bldcya}debugging mode"
	./binary/zipaligner/adb wait-for-device
	echo -e "${cya}Installing apk to device..."
	./binary/zipaligner/adb install $appname.apk
	echo -e "${bldgrn}Done. Exiting..."
	./binary/zipaligner/adb kill-server
	exit 0
else
	echo -e ""
	read -p "Press any key to go back."
	break
fi
	fi
done


