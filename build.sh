#!/bin/bash
#
# Script to build CM9 for Galaxy Tab (with Kernel)
# 2012 Chirayu Desai 

# Common defines
txtrst='\e[0m'  # Color off
txtred='\e[0;31m' # Red
txtgrn='\e[0;32m' # Green
txtylw='\e[0;33m' # Yellow
txtblu='\e[0;34m' # Blue

echo -e "${txtblu}##########################################"
echo -e "${txtblu}#                                        #"
echo -e "${txtblu}#         GALAXYTAB BUILDSCRIPT          #"
echo -e "${txtblu}#                                        #"
echo -e "${txtblu}##########################################"
echo -e "\r\n ${txtrst}"

BUILDTYPE="$1"
THREADS=`cat /proc/cpuinfo | grep processor | wc -l`

case "$BUILDTYPE" in
	clean)
		make clean
		cd kernel/samsung/p1
		./build.sh clean
		exit
		;;
	eng)
		LUNCH=cm_galaxytab-eng
		;;
	userdebug)
		LUNCH=cm_galaxytab-userdebug
		;;
	user)
		LUNCH=cm_galaxytab-user
		;;
	*)
		echo -e "${txtred} Choose a build type"
		echo -e "Default : userdebug"
		echo -e "Supported Buildtypes : eng userdebug user${txtrst}"
		;;
esac

if [ "$1" = "" ] ; then
LUNCH=cm_galaxytab-userdebug
fi

# Check for Prebuilts
		echo -e "${txtylw}Checking for Prebuilts...${txtrst}"
if [ ! -e vendor/cm/proprietary/RomManager.apk ] || [ ! -e vendor/cm/proprietary/Term.apk ] || [ ! -e vendor/cm/proprietary/lib/armeabi/libjackpal-androidterm3.so ]; then
		echo -e "${txtred}Prebuilts not found, downloading now...${txtrst}"
		cd vendor/cm
		./get-prebuilts
		cd ../..
else
		echo -e "${txtgrn}Prebuilts found.${txtrst}"
fi

START=$(date +%s)
# Setup build environment and start the build
. build/envsetup.sh
lunch $LUNCH

# Kernel build
cd kernel/samsung/p1
./build.sh 
cd ../../..

# Android build
make -j$THREADS bacon

END=$(date +%s)
ELAPSED=$((END - START))
E_MIN=$((ELAPSED / 60))
E_SEC=$((ELAPSED - E_MIN * 60))
printf "Elapsed: "
[ $E_MIN != 0 ] && printf "%d min(s) " $E_MIN
printf "%d sec(s)\n" $E_SEC
