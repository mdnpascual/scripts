#!/bin/bash
printf -- "\\n" >> logfile3.txt 
#Serial number
system_profiler SPHardwareDataType | awk '/Serial/ {print $4}' >> logfile3.txt
printf -- "\\r\n" >> logfile3.txt
#BIOS version
#Model number
sysctl hw.model | awk '{print $2}' >> logfile3.txt
printf -- "\\r\n" >> logfile3.txt
#Processor  
#sysctl -n machdep.cpu | head -n 4 | tail -n 1 >> logfile3.txt
sysctl -n machdep.cpu | grep "Intel(R)" >> logfile3.txt
printf -- "\\r\n" >> logfile3.txt
#RAM
sysctl hw.memsize | awk '{print $2/1024/1024/1024}' | perl -nl -MPOSIX -e 'print ceil($_);' | awk '{print $1" GB"}' >> logfile3.txt
printf -- "\\r\n" >> logfile3.txt
#OS
system_profiler SPSoftwareDataType | grep "System Version" | awk '{ print substr($0, index($0,$3)) }' >> logfile3.txt
printf -- "\\r\n" >> logfile3.txt
#HDD SIZE
#diskutil list | grep disk0$ | awk '{print $3 $4}' | cut -c 2- >> logfile3.txt
system_profiler SPSerialATADataType | head -n 14 | tail -n 1 | awk '{print $2 $3}' >> logfile3.txt
printf -- "\\r\n" >> logfile3.txt
#HDD NAME
system_profiler SPSerialATADataType | head -n 15 | tail -n 1 | awk '{print $2 " " $3}' >> logfile3.txt
printf -- "\\r\n" >> logfile3.txt
#HDD s/n
system_profiler SPSerialATADataType | head -n 17 | tail -n 1 | awk '{print $3}' >> logfile3.txt
printf -- "\\r\n" >> logfile3.txt
#IP

ifconfig | grep inet | awk '{print $1 " " $2}' | grep "inet " | awk '($2!="127.0.0.1") && ($2!~"^192."){print $2}' >> logfile3.txt
printf -- "\\r\n" >> logfile3.txt

#Mac Address
#ifconfig em1 | grep ether | head -n 1 | awk '{print $2}' >> logfile2.txt
#printf -- "\\r\n" >> logfile2.txt
IPS=`ifconfig | grep inet | awk '{print $1 " " $2}' | grep "inet " | awk '($2!="127.0.0.1") && ($2!~"^192."){print $2}'`
IFS=$'\n' read -d '' -r -a arr <<< "$IPS"
for element in "${arr[@]}"
do
	indexer=`ifconfig | grep -n "${element}" | awk '{print $1}' | sed 's/.$//'`
	num=$(($indexer - 2))
	num2=$(($indexer + 2))
	num3=$(($indexer - 2))
	num4=$(($indexer + 2))
	echo `ifconfig | head -n $num | tail -n 1`
	echo `ifconfig | head -n $num2 | tail -n 1`
	echo `ifconfig | head -n $num3 | tail -n 1`
	echo `ifconfig | head -n $num4 | tail -n 1`
	ifconfig | head -n $num | tail -n 1 | awk '($1~"^eth"){print $2}' >> logfile3.txt
	ifconfig | head -n $num2 | tail -n 1 | awk '($1~"^eth"){print $2}' >> logfile3.txt
	ifconfig | head -n $num3 | tail -n 1 | awk '($1~"^eth"){print $2}' >> logfile3.txt
	ifconfig | head -n $num4 | tail -n 1 | awk '($1~"^eth"){print $2}' >> logfile3.txt
done
printf -- "\\r\n" >> logfile3.txt
#host name
uname -n >> logfile3.txt
printf -- "\\r\n" >> logfile3.txt
printf -- "------------------------------------------------------\r\n " >> logfile3.txt
