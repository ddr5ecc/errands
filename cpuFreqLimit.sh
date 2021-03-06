#!/bin/sh

# 202107311500 PST
# 程式目的：限制cpu的最高速度，請使用root執行
# Objective: Limit the cpu freq. Need root privilege. 

# 執行緒數
# CPU thread numbers
thread=12

# 最高時脈限制，請參考下列檔案以確定可使用的數值
# frequency limit, please check /sys/devices/system/cpu/cpufreq/policy0/scaling_available_frequencies for available frequency
cpuLimit=3600000

# root 權限是必須的
# root privilege is necessary
if [ `whoami` != root ]; then
    echo Please run this script as root or use sudo
    exit
fi

# 確定系統有此功能
# make sure the system is compatible
i=1
keyFile=/sys/devices/system/cpu/cpufreq/policy`expr $i - 1`/scaling_max_freq
if [ ! -f $keyFile ] 
then
	echo /sys/devices/system/cpu/cpufreq/policy0/scaling_max_freq is missing, this script would not work! 
	exit
fi


while [ $i -le $thread ]
do
	echo $cpuLimit | tee /sys/devices/system/cpu/cpufreq/policy`expr $i - 1`/scaling_max_freq
	i=`expr $i + 1`
done


