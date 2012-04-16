#!/bin/bash

DEVICE=p1
for i in p1 p1c; do
  [ "$2" == "$i" ] && DEVICE="$i"
done

# these devices currently use the P1 system tree, but have their own kernel
KERNEL_DEVICE=$DEVICE
for i in p1l p1n; do
  [ "$2" == "$i" ] && KERNEL_DEVICE="$i"
done

# VARIANT 	use
# user 		limited access; suited for production
# userdebug 	like "user" but with root access and debuggability; preferred for debugging
# eng		development configuration with additional debugging tools

VARIANT=userdebug
for i in user userdebug eng; do
  [ "$3" == "$i" ] && VARIANT="$i"
done

# --------------------------------------------

KERNELDIR="kernel/samsung/$KERNEL_DEVICE"
DEVICEDIR="device/samsung/$DEVICE"

# --------------------------------------------

THREADS=$(grep processor /proc/cpuinfo | wc -l)

case "$1" in

  distclean)
      repo forall -c 'git clean -xdf'
      ;&
  clean)
      make clobber
      cd $KERNELDIR
      make mrproper
      ;;
  kernel)
      time (
        cd $KERNELDIR
        if "$DEVICE" = "p1c" ; then
        make ARCH=arm p1_defconfig
        else
        make ARCH=arm "$KERNEL_DEVICE"_cm9_defconfig
        make -j$THREADS
      )
      cp $KERNELDIR/arch/arm/boot/zImage $DEVICEDIR/kernel
      find $KERNELDIR -name '*.ko' | xargs -i cp {} $DEVICEDIR/modules
      ;;
  system)
      time {
        source build/envsetup.sh
        [ ! -d vendor/cm/proprietary ] && ( cd vendor/cm ; ./get-prebuilts )
        lunch "cm_"$DEVICE"-"$VARIANT
        make -j$THREADS bacon
      }
      ;;
  *)
      echo
      echo "usage: ${0##*/} <action> [ <device> ] [ <build-variant> ]"
      echo
      echo "  <action> : clean|distclean|kernel|system"
      echo "  <device> : p1|p1c|p1l|p1n       default=$DEVICE"
      echo "  <variant>: user|userdebug|eng   default=$VARIANT"

esac
