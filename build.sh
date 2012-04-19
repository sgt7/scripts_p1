#!/bin/bash

# default
DEVICE=p1
# alternatives
for i in p1 p1c p1l p1n; do
  [ "$1" == "$i" ] && DEVICE="$i"
done

# VARIANT 	use
# user 		limited access; suited for production
# userdebug 	like "user" but with root access and debuggability; preferred for debugging
# eng		development configuration with additional debugging tools

# default
VARIANT=userdebug
# alternatives
for i in user userdebug eng; do
  [ "$2" == "$i" ] && VARIANT="$i"
done

# --------------------------------------------

# default
TARGET="cm_$DEVICE-$VARIANT"

# exceptions
case "$DEVICE" in
  p1l|p1n)
      TARGET="cm_p1-$VARIANT"
      OTHER="TARGET_KERNEL_CONFIG=cyanogenmod_"$DEVICE"_defconfig"
esac

# --------------------------------------------

THREADS=$(grep processor /proc/cpuinfo | wc -l)

case "$1" in

  distclean)
      repo forall -c 'git clean -xdf'
      ;&
  clean)
      make clobber
      ( cd kernel/samsung/p1  ; make mrproper )
      ( cd kernel/samsung/p1c ; make mrproper )
      ;;
  $DEVICE|"")
      time {
        source build/envsetup.sh
        [ ! -d vendor/cm/proprietary ] && ( cd vendor/cm ; ./get-prebuilts )
        lunch "$TARGET"
        make -j$THREADS bacon $OTHER
      }
      ;;
  *)
      echo
      echo "usage:" 
      echo "       ${0##*/} [ <action> ]"
      echo "       ${0##*/} [ <device> ] [ <build-variant> ]"
      echo
      echo "  <action> : clean|distclean|help"
      echo "  <device> : p1|p1c|p1l|p1n       default=$DEVICE"
      echo "  <variant>: user|userdebug|eng   default=$VARIANT"
      ;;
esac
