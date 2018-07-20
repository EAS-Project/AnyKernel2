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
find $ramdisk -type f -exec chmod 644 {} \;
chown -R root:root $ramdisk/*;


## AnyKernel install
dump_boot;

# begin ramdisk changes
rm $ramdisk/init.oem.early_boot.sh
rm $ramdisk/init.oem.engineermode.sh

# init.rc
remove_line init.rc "import /init.renderzenith.rc"
insert_line init.rc "/renderzenith/init.renderzenith.rc" after "import /init.environ.rc" "import /renderzenith/init.renderzenith.rc\n";

# Remove deprecated files
rm $ramdisk/WCNSS_qcom_cfg.ini
rm $ramdisk/perfboostsconfig.xml
rm $ramdisk/msm_irqbalance.conf
rm $ramdisk/init.renderzenith.rc
rm -r $ramdisk/modules

# sepolicy
$bin/magiskpolicy --load sepolicy --save sepolicy \
    "allow init rootfs file execute_no_trans" \
    "allow { init modprobe } rootfs system module_load" \
    "allow init { system_file vendor_file vendor_configs_file } file mounton" \
    "allow { msm_irqbalanced hal_perf_default } rootfs file { getattr read open } " \
    ;

# sepolicy_debug
$bin/magiskpolicy --load sepolicy_debug --save sepolicy_debug \
    "allow init rootfs file execute_no_trans" \
    "allow { init modprobe } rootfs system module_load" \
    "allow init { system_file vendor_file vendor_configs_file } file mounton" \
    "allow { msm_irqbalanced hal_perf_default } rootfs file { getattr read open } " \
    ;

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
cp -pf /system/vendor/etc/wifi/WCNSS_qcom_cfg.ini $ramdisk/renderzenith/WCNSS_qcom_cfg.ini
cp -pf /vendor/etc/wifi/WCNSS_qcom_cfg.ini $ramdisk/renderzenith/WCNSS_qcom_cfg.ini
remove_line $ramdisk/renderzenith/WCNSS_qcom_cfg.ini g_enable_packet_filter_bitmap
echo "gDisablePacketFilter=1" > $ramdisk/renderzenith/temp.ini
cat $ramdisk/renderzenith/WCNSS_qcom_cfg.ini >> $ramdisk/renderzenith/temp.ini
mv $ramdisk/renderzenith/temp.ini $ramdisk/renderzenith/WCNSS_qcom_cfg.ini

# Remove 
replace_line $ramdisk/renderzenith/WCNSS_qcom_cfg.ini "gHwFilterMode" "gHwFilterMode=0"

# Kill init's search for Treble split sepolicy if Magisk is not present
# This will force init to load the monolithic sepolicy at /
if [ ! -d .backup ]; then
    sed -i 's;selinux/plat_sepolicy.cil;selinux/plat_sepolicy.xxx;g' init;
fi;

# end ramdisk changes

write_boot;

## end install

