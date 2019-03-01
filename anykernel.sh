# AnyKernel2 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() { '
kernel.string=RenderZenith by RenderBroken and joshuous
do.devicecheck=1
do.modules=0
do.cleanup=1
do.cleanuponabort=0
device.name1=OnePlus5T
device.name2=dumpling
device.name3=OnePlus5
device.name4=cheeseburger
device.name5=
supported.versions=9
'; } # end properties

# shell variables
block=/dev/block/bootdevice/by-name/boot
is_slot_device=0;
ramdisk_compression=auto;


## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. /tmp/anykernel/tools/ak2-core.sh;


## AnyKernel file attributes
# set permissions/ownership for included ramdisk files
chmod -R 750 $ramdisk/*;
chown -R root:root $ramdisk/*;

## begin vendor changes
mount -o rw,remount -t auto /vendor >/dev/null;

# Cleanup previous performance additions
remove_section /vendor/etc/init/hw/init.target.performance.rc "##START_RZ" "##END_RZ"

# Add performance tweaks
append_file /vendor/etc/init/hw/init.target.performance.rc "R4ND0MSTR1NG" init.target.performance.rc


## AnyKernel install
dump_boot;

# begin ramdisk changes

# Remove recovery service so that TWRP isn't overwritten
remove_section init.rc "service flash_recovery" ""

# end ramdisk changes

write_boot;

## end install

