# AnyKernel2 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() {
kernel.string=RenderZenith kernel for OP3
do.devicecheck=1
do.modules=0
do.cleanup=1
do.cleanuponabort=0
device.name1=OnePlus3
device.name2=oneplus3
device.name3=OnePlus3T
device.name4=oneplus3t
} # end properties

# shell variables
block=/dev/block/bootdevice/by-name/boot;
is_slot_device=0;
ramdisk_compression=auto;


## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. /tmp/anykernel/tools/ak2-core.sh;


## AnyKernel file attributes
# set permissions/ownership for included ramdisk files
chmod -R 750 $ramdisk/*;
chown -R root:root $ramdisk/*;

## AnyKernel install
dump_boot;

# begin ramdisk changes
insert_line init.rc "init.renderzenith.rc" after "import /init.environ.rc" "import /init.renderzenith.rc\n";

# sepolicy
$bin/sepolicy-inject -s init -t rootfs -c file -p execute_no_trans,mounton -P sepolicy;
$bin/sepolicy-inject -s init -t rootfs -c system -p module_load -P sepolicy;
$bin/sepolicy-inject -s init -t system_file -c file -p mounton -P sepolicy;
$bin/sepolicy-inject -s init -t vendor_configs_file -c file -p mounton -P sepolicy;
$bin/sepolicy-inject -s init -t vendor_file -c file -p mounton -P sepolicy;
$bin/sepolicy-inject -s modprobe -t rootfs -c system -p module_load -P sepolicy;
$bin/sepolicy-inject -s msm_irqbalanced -t rootfs -c file -p getattr,read,open -P sepolicy;
$bin/sepolicy-inject -s hal_perf_default -t rootfs -c file -p getattr,read,open -P sepolicy;

# sepolicy_debug
$bin/sepolicy-inject -s init -t rootfs -c file -p execute_no_trans,mounton -P sepolicy_debug;
$bin/sepolicy-inject -s init -t rootfs -c system -p module_load -P sepolicy_debug;
$bin/sepolicy-inject -s init -t system_file -c file -p mounton -P sepolicy_debug;
$bin/sepolicy-inject -s init -t vendor_configs_file -c file -p mounton -P sepolicy_debug;
$bin/sepolicy-inject -s init -t vendor_file -c file -p mounton -P sepolicy_debug;
$bin/sepolicy-inject -s modprobe -t rootfs -c system -p module_load -P sepolicy_debug;
$bin/sepolicy-inject -s msm_irqbalanced -t rootfs -c file -p getattr,read,open -P sepolicy_debug;
$bin/sepolicy-inject -s hal_perf_default -t rootfs -c file -p getattr,read,open -P sepolicy_debug;

# Give modules in ramdisk appropriate permissions to allow them to be loaded
find $ramdisk/modules -type f -exec chmod 644 {} \;

# end ramdisk changes

write_boot;

## end install

