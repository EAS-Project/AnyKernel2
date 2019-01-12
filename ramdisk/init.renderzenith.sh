#!/system/bin/sh

# Schedutil config
echo "schedutil" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo "schedutil" > /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor

# SchedTune
echo "1" > /dev/stune/foreground/schedtune.prefer_idle
echo "1" > /dev/stune/top-app/schedtune.prefer_idle
echo "1" > /dev/stune/top-app/schedtune.boost

# cpuset
echo "0-3" > /dev/cpuset/restricted/cpus
