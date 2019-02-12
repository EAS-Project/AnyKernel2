#!/system/bin/sh 

sleep 35;

# Applying RenderZenith Settings 

# Setup Schedutil Governor
	echo "schedutil" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
	echo 500 > /sys/devices/system/cpu/cpufreq/policy0/schedutil/up_rate_limit_us
	echo 20000 > /sys/devices/system/cpu/cpufreq/policy0/schedutil/down_rate_limit_us
	echo 1 > /sys/devices/system/cpu/cpufreq/policy0/schedutil/iowait_boost_enable
	echo 0 > /sys/devices/system/cpu/cpufreq/policy0/schedutil/pl
	echo 0 > /sys/devices/system/cpu/cpufreq/policy0/schedutil/hispeed_freq

	echo "schedutil" > /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor	
	echo 500 > /sys/devices/system/cpu/cpufreq/policy4/schedutil/up_rate_limit_us
	echo 20000 > /sys/devices/system/cpu/cpufreq/policy4/schedutil/down_rate_limit_us
	echo 1 > /sys/devices/system/cpu/cpufreq/policy4/schedutil/iowait_boost_enable
	echo 0 > /sys/devices/system/cpu/cpufreq/policy4/schedutil/pl
	echo 0 > /sys/devices/system/cpu/cpufreq/policy4/schedutil/hispeed_freq

# Input boost and stune configuration
	echo "0:1056000 1:0 2:0 3:0 4:1056000 5:0 6:0 7:0" > /sys/module/cpu_boost/parameters/input_boost_freq
	echo 500 > /sys/module/cpu_boost/parameters/input_boost_ms
	echo 50 > /sys/module/cpu_boost/parameters/dynamic_stune_boost
	echo 1500 > /sys/module/cpu_boost/parameters/dynamic_stune_boost_ms

# Dynamic Stune Boost during sched_boost
	echo 50 > /dev/stune/top-app/schedtune.sched_boost

# Disable Boost_No_Override
	echo 0 > /dev/stune/foreground/schedtune.sched_boost_no_override
	echo 0 > /dev/stune/top-app/schedtune.sched_boost_no_override

# Set default schedTune value for foreground/top-app
	echo 1 > /dev/stune/foreground/schedtune.prefer_idle
	echo 5 > /dev/stune/top-app/schedtune.boost
	echo 1 > /dev/stune/top-app/schedtune.prefer_idle

# Enable PEWQ
	echo Y > /sys/module/workqueue/parameters/power_efficient

# Disable Touchboost
	echo 0 > /sys/module/msm_performance/parameters/touchboost

# Disable CAF task placement for Big Cores
	echo 0 > /proc/sys/kernel/sched_walt_rotate_big_tasks

# Setup EAS cpusets values for better load balancing
	echo 0-7 > /dev/cpuset/top-app/cpus
	# Since we are not using core rotator, lets load balance
	echo 0-3,6-7 > /dev/cpuset/foreground/cpus
	echo 0-1 > /dev/cpuset/background/cpus
	echo 0-3  > /dev/cpuset/system-background/cpus

# For better screen off idle
	echo 0-3 > /dev/cpuset/restricted/cpus

# Adjust Read Ahead
	echo 128 > /sys/block/sda/queue/read_ahead_kb
	echo 128 > /sys/block/dm-0/queue/read_ahead_kb
	
# Tune Core_CTL for proper task placement
	echo "0 0 0 0" > /sys/devices/system/cpu/cpu0/core_ctl/busy_down_thres
	echo "0 0 0 0" > /sys/devices/system/cpu/cpu0/core_ctl/busy_up_thres
	echo 1 > /sys/devices/system/cpu/cpu0/core_ctl/min_cpus
	echo 4294967295 > /sys/devices/system/cpu/cpu0/core_ctl/task_thres

	echo "0 0 0 0" > /sys/devices/system/cpu/cpu4/core_ctl/busy_down_thres
	echo "0 0 0 0" > /sys/devices/system/cpu/cpu4/core_ctl/busy_up_thres
	echo 1 > /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
	echo 4294967295 > /sys/devices/system/cpu/cpu4/core_ctl/task_thres
