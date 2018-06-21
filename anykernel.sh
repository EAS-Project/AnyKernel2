# AnyKernel2 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() {
kernel.string=RenderZenith by RenderBroken and Joshuous!
do.devicecheck=1
do.modules=0
do.cleanup=1
do.cleanuponabort=0
do.system_blobs=0
device.name1=OnePlus5T
device.name2=dumpling
device.name3=OnePlus5
device.name4=cheeseburger
device.name5=
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
cp -f /tmp/anykernel/system/vendor/etc/msm_irqbalance.conf $ramdisk/
cp -f /tmp/anykernel/system/vendor/etc/perf/perfboostsconfig.xml $ramdisk/
chmod 644 $ramdisk/perfboostsconfig.xml
chmod 644 $ramdisk/msm_irqbalance.conf
find $ramdisk/modules -type f -exec chmod 644 {} \;
chown -R root:root $ramdisk/*;


## AnyKernel install
dump_boot;

# begin ramdisk changes
rm $ramdisk/init.oem.early_boot.sh
rm $ramdisk/init.oem.engineermode.sh

# init.rc
insert_line init.rc "init.renderzenith.rc" after "import /init.environ.rc" "import /init.renderzenith.rc\n";

# sepolicy
$bin/sepolicy-inject -s init -t rootfs -c file -p execute_no_trans -P sepolicy;
$bin/sepolicy-inject -s init -t rootfs -c system -p module_load -P sepolicy;
$bin/sepolicy-inject -s init -t system_file -c file -p mounton -P sepolicy;
$bin/sepolicy-inject -s init -t vendor_configs_file -c file -p mounton -P sepolicy;
$bin/sepolicy-inject -s init -t vendor_file -c file -p mounton -P sepolicy;
$bin/sepolicy-inject -s modprobe -t rootfs -c system -p module_load -P sepolicy;
$bin/sepolicy-inject -s msm_irqbalanced -t rootfs -c file -p getattr,read,open -P sepolicy;
$bin/sepolicy-inject -s hal_perf_default -t rootfs -c file -p getattr,read,open -P sepolicy;

# sepolicy_debug
$bin/sepolicy-inject -s init -t rootfs -c file -p execute_no_trans -P sepolicy_debug;
$bin/sepolicy-inject -s init -t rootfs -c system -p module_load -P sepolicy_debug;
$bin/sepolicy-inject -s init -t system_file -c file -p mounton -P sepolicy_debug;
$bin/sepolicy-inject -s init -t vendor_configs_file -c file -p mounton -P sepolicy_debug;
$bin/sepolicy-inject -s init -t vendor_file -c file -p mounton -P sepolicy_debug;
$bin/sepolicy-inject -s modprobe -t rootfs -c system -p module_load -P sepolicy_debug;
$bin/sepolicy-inject -s msm_irqbalanced -t rootfs -c file -p getattr,read,open -P sepolicy_debug;
$bin/sepolicy-inject -s hal_perf_default -t rootfs -c file -p getattr,read,open -P sepolicy_debug;

# Remove recovery service so that TWRP isn't overwritten
remove_section init.rc "service flash_recovery" ""

# Remove suspicious OnePlus services
remove_section init.oem.rc "service OPNetlinkService" "seclabel"
remove_section init.oem.rc "service oemsysd" "seclabel"
remove_section init.oem.rc "service oem_audio_device" "oneshot"
remove_section init.oem.rc "service atrace" "seclabel"
remove_section init.oem.rc "service sniffer_set" "seclabel"
remove_section init.oem.rc "service sniffer_start" "seclabel"
remove_section init.oem.rc "service sniffer_stop" "seclabel"
remove_section init.oem.rc "service tcpdump-service" "seclabel"
remove_section init.oem.debug.rc "service oemlogkit" "socket oemlogkit"
remove_section init.oem.debug.rc "service dumpstate_log" "seclabel"
remove_section init.oem.debug.rc "service oemasserttip" "disabled"

# Remove packet filtering from WCNSS_qcom_cfg.ini
cp -pf /system/vendor/etc/wifi/WCNSS_qcom_cfg.ini $ramdisk/WCNSS_qcom_cfg.ini
remove_line WCNSS_qcom_cfg.ini g_enable_packet_filter_bitmap
echo "gDisablePacketFilter=1" > $ramdisk/temp.ini
cat $ramdisk/WCNSS_qcom_cfg.ini >> $ramdisk/temp.ini
mv $ramdisk/temp.ini $ramdisk/WCNSS_qcom_cfg.ini

# end ramdisk changes

write_boot;

## end install

