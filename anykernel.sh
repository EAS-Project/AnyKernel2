# AnyKernel2 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() {
kernel.string=RenderZenith by RenderBroken and Joshuous!
do.devicecheck=0
do.modules=1
do.cleanup=1
do.cleanuponabort=0
do.system_blobs=0
device.name1=
device.name2=
device.name3=
device.name4=
device.name5=
} # end properties

# shell variables
block=/dev/block/bootdevice/by-name/boot;
is_slot_device=0;

## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. /tmp/anykernel/tools/ak2-core.sh;

## AnyKernel permissions
# set permissions for included ramdisk files
chmod -R 755 $ramdisk

## AnyKernel install
dump_boot;

# begin ramdisk changes

# init.rc
backup_file init.rc
insert_line init.rc "init.qcom.power.rc" after "import /init.environ.rc" "import /init.qcom.power.rc\n";

# init.qcom.rc
backup_file init.qcom.rc
remove_section init.qcom.rc "service qcom-post-boot" "oneshot"

# end ramdisk changes

write_boot;

## end install


