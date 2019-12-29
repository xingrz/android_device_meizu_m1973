#!/sbin/sh

if [ ! -d /tmp/system_root ]; then
    mkdir /tmp/system_root
fi
mount -t ext4 -o ro "/dev/block/bootdevice/by-name/system" /tmp/system_root
ret=$?
if [ $ret != 0 ]; then
    echo "Could not read build properties from /system"
    setprop crypto.ready 1
    exit 0
fi

system_build_prop="/tmp/system_root/system/build.prop"
if [ -r $system_build_prop ]; then
    osver=$(grep 'ro.build.version.release' $system_build_prop  | cut -d'=' -f2)
    system_patchlevel=$(grep 'ro.build.version.security_patch' $system_build_prop  | cut -d'=' -f2)

    if [ "x$osver" != "x" ]; then
        setprop ro.build.version.release "$osver"
    fi
    if [ "x$system_patchlevel" != "x" ]; then
        setprop ro.build.version.security_patch "$system_patchlevel"
    fi
fi

umount /tmp/system_root

if [ ! -d /tmp/vendor ]; then
    mkdir /tmp/vendor
fi
mount -t ext4 -o ro "/dev/block/bootdevice/by-name/vendor" /tmp/vendor
ret=$?
if [ $ret != 0 ]; then
    echo "Could not read build properties from /vendor"
    setprop crypto.ready 1
    exit 0
fi

vendor_build_prop="/tmp/vendor/build.prop"
if [ -r $vendor_build_prop ]; then
    vendor_patchlevel=$(grep 'ro.vendor.build.security_patch' $vendor_build_prop  | cut -d'=' -f2)

    if [ "x$vendor_patchlevel" != "x" ]; then
        setprop ro.vendor.build.security_patch "$vendor_patchlevel"
    fi
fi

umount /tmp/vendor

setprop crypto.ready 1
exit 0
