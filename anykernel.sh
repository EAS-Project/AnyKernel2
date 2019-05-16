# AnyKernel2 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() { '
kernel.string=RenderZenith by RenderBroken and Joshuous!
do.devicecheck=1
do.modules=0
do.cleanup=1
do.cleanuponabort=0
device.name1=OnePlus6
device.name2=OnePlus6T
'; } # end properties

# shell variables
block=/dev/block/bootdevice/by-name/boot;
is_slot_device=1;
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

cp -rf /tmp/anykernel/patch/init.renderzenith.sh /vendor/etc/init/hw/;
set_perm 0 0 0644 /vendor/etc/init/hw/init.renderzenith.sh;

# Make a backup of init.target.rc
restore_file /vendor/etc/init/hw/init.target.rc;
backup_file /vendor/etc/init/hw/init.target.rc;

# Do work #2
replace_string /vendor/etc/init/hw/init.target.rc "write /dev/stune/top-app/schedtune.colocate 0" "write /dev/stune/top-app/schedtune.colocate 1" "write /dev/stune/top-app/schedtune.colocate 0";

# Add performance tweaks
append_file /vendor/etc/init/hw/init.target.rc "R4ND0MSTR1NG" init.target.rc;

# Make a backup of msm_irqbalance.conf
backup_file /vendor/etc/msm_irqbalance.conf;

cp -rf /tmp/anykernel/patch/msm_irqbalance.conf /vendor/etc/msm_irqbalance.conf;
set_perm 0 0 0644 /vendor/etc/msm_irqbalance.conf;

## AnyKernel install
dump_boot;

# Clean up other kernels' ramdisk overlay files
rm -rf $ramdisk/overlay;

# Add skip_override parameter to cmdline so user doesn't have to reflash Magisk
if [ -d $ramdisk/.backup ]; then
  ui_print " "; ui_print "Magisk detected! Patching cmdline so reflashing Magisk is not necessary...";
  patch_cmdline "skip_override" "skip_override";
else
  patch_cmdline "skip_override" "";
fi;  

# Install the boot image
write_boot;
