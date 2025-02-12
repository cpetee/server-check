##feb 12th 2025

#!/bin/bash

## check services depending on OS version
## checks for centOS 6 or 7 and then runs commands to check
## multiple services

osVer=$(cat /etc/redhat-release)

if  [[ "$osVer" == *"6"* ]]; then
        echo -e "os = cos6"
        ## system check
        #centOS 6

## run centOS 6 checks:

#centOS 6
## https://waypoint.liquidweb.com:8443/display/SUP/Server+Moves+-+Preparation+Runbook

#haproxy:

haInstalled=$(ls -la /etc/ | grep haproxy)

#is haproxy installed
if [ -z "$haInstalled" ]; then
        echo "haproxy is not installed"
  else
echo;

haActive=$(service haproxy status | grep -i running)

haEnabled=$(chkconfig --list | awk '/haproxy.*:on/' | grep on)

# check is haproxy is active/running
if [[ "$haActive" == *"running"* ]]; then
        echo "haproxy is $haActive"
  else
        echo "haproxy is not running"
fi

echo;
#check if Haproxy is Enabled
if [[ "$haEnabled" == *"on"* ]]; then
        echo "haproxy is $haEnabled"
  else
        echo "haproxy is not on boot"
fi

echo;
# check haproxy config version
haVersion=$(cat /etc/haproxy/config.version)

if [ "$haVersion" != "4" ] || [ -z "$haVersion" ]; then
        echo "haproxy is not up to date see:"
        echo "https://waypoint.liquidweb.com:8443/display/SUP/ESG+Ansible+-+HAProxy#ESGAnsibleHAProxy-FromVersion$haVersion"
  else
        echo "haproxy is $haVersion and up to date"
fi
fi

echo;


## check varnish
## will need to grab the varnish SERVICE_NAME

echo;

echo "Is Varnish instances running"

## script to detect varnish instances:
## wrot by Ken Howell

{
# First get a list of valid possible varnish configs;
configfiles="$(grep -lr 'VARNISH_LISTEN_ADDRESS' /etc/sysconfig/)"
# Next iterate that list to identify any name configs
echo -e "$configfiles" |
while read line; do
        # Initialize variables
        varnishName="varnish"
        varnishStatus="Stopped"
        varnishResult="$(grep '\-n ' $line | sed 's/\\//g' | grep '\-n')"
        # If a name is defined in the varnish config, set the varnishName variable to use the defined name
        if [ ! -z "$varnishResult" ]; then
                varnishName="varnish_$(grep '\-n ' $line | awk -F'-n ' '{print $2}' | awk '{print $1}')"
        fi
        # Check to see if the varnish pid exists
        procResult=$(ps aux | grep "$varnishName.pid" | grep -v 'grep')
        if [ ! -z "$procResult" ]; then
                varnishPid="$(echo $procResult | awk '{print $2}')"
                varnishStatus="Running"
                # Alternative method to return status using systemd, uncomment below line to use
                # varnishStatus=$(/sbin/service $varnishName status)
        fi
        # Return the results
        echo -e "Name: $varnishName\nStatus: $varnishStatus\nPID: $varnishPid\n"
done
}

## sample output:
#Name: varnish_dev
#Status: Stopped
#PID:
#
#Name: varnish
#Status: Running
#PID: 3240
#
#Name: varnish_prod
#Status: Running
#PID: 3380

echo;

echo "Is varnish set to load on boot"

chkconfig --list | awk '/varnish*.*:on/'

echo;

## check elasticsearch

echo "Is Elasticsearch running"

service elasticsearch status

echo;

echo "Is Elasticsearch set to load on boot"

chkconfig --list | awk '/elasticsearch.*:on/'

echo;

## check rabbitmq

echo "Is RabbitMQ running"

service rabbitmq-server status | head -n2

echo;

echo "Is RabbitMQ set to load on boot"

chkconfig --list | awk '/rabbitmq-server.*:on/'

echo;

## check redis:

echo "Is Redis instances running"

service redis-multi status

echo;

echo "Is Redis (multi) set to load on boot"

chkconfig --list | grep redis-multi

echo;

## check php-fpm services:

for p in $( ls -la /etc/rc.d/init.d/ | grep php-fpm | awk '{print $NF }' | sed 's,\*,,g') ; do echo $p; service $p status; echo; done

echo;

#Network speed check - suggested by Ken H due to ports on new switch might not have been config'd to the 10G in previous one was set to it

echo "Network port speeds"

for net in $(ifconfig  | grep -E "Ethernet |BROADCAST," | awk '{print $1}' | sed -n '1p;$p') ; do echo $net; ethtool $net | grep -i speed; echo; done

echo;echo


  else

## run centOS 7 checks

##centOS 7
echo -e "os = cos7"

#haproxy:

haInstalled=$(ls -la /etc/ | grep haproxy)

#is haproxy installed
if [ -z "$haInstalled" ]; then
        echo "haproxy is not installed"
  else
echo;

haRunning=$(systemctl status haproxy.service | grep Active)

haActive=$(systemctl is-active haproxy)

haEnabled=$(systemctl is-enabled haproxy)

# check is haproxy is running
if [[ "$haActive" == *"running"* ]]; then
        echo "haproxy is Running"
  else
        echo "haproxy is not Running"
fi


# check is haproxy is active
if [[ "$haActive" == "active" ]]; then
        echo "haproxy is $haActive"
  else
        echo "haproxy is not Active"
fi

echo;
#check if Haproxy is Enabled
if [[ "$haEnabled" == "enabled" ]]; then
        echo "haproxy is $haEnabled"
  else
        echo "haproxy is not Enabled"
fi

echo;
# check haproxy config version
haVersion=$(cat /etc/haproxy/config.version)

if [ "$haVersion" != "4" ] || [ -z "$haVersion" ]; then
        echo "haproxy is not up to date see:"
        echo "https://waypoint.liquidweb.com:8443/display/SUP/ESG+Ansible+-+HAProxy#ESGAnsibleHAProxy-FromVersion$haVersion"
  else
        echo "haproxy is $haVersion and up to date"
fi
fi

echo;


## check varnish:

echo "##Unit varnish could not be found.  <<-- not installed and can be ignored"

echo;

{

# First get a list of valid possible varnish configs;
configfiles="$(grep -lr 'VARNISH_LISTEN_ADDRESS' /etc/varnish/)"
# Next iterate that list to identify any name configs
echo -e "$configfiles" |
while read line; do
        # Initialize variables
        varnishName="varnish"
        varnishStatus="Stopped"
        varnishResult="$(grep '\-n ' $line | sed 's/\\//g' | grep '\-n' | sed 's,",,g')"
        # If a name is defined in the varnish config, set the varnishName variable to use the defined name
        if [ ! -z "$varnishResult" ]; then
                varnishName="varnish_$(grep '\-n ' $line | awk -F'-n ' '{print $2}' | sed 's,",,g' | awk '{print $1}')"
                varnishProc="$(grep '\-n ' $line | awk -F'-n ' '{print $2}' | sed 's,",,g' | awk '{print $1}')"
        fi
        # Check to see if the varnish pid exists
        procResult=$(ps aux | grep "/var/run/varnish-$varnishProc.pid" | grep -v 'grep')
        if [ ! -z "$procResult" ]; then
                varnishPid="$(echo $procResult | awk '{print $2}')"
                varnishStatus="Running"
                varnishOnBoot=$(systemctl is-enabled ${varnishName}.service)
                # Alternative method to return status using systemd, uncomment below line to use
                # varnishStatus=$(/sbin/service $varnishName status)
        fi
        # Return the results
        echo -e "Name: $varnishName\nStatus: $varnishStatus\nPID: $varnishPid\nOnBoot: $varnishOnBoot\n"
done

}

## sample output:
#Name: varnish_dev
#Status: Stopped
#PID:
#
#Name: varnish
#Status: Running
#PID: 3240
#
#Name: varnish_prod
#Status: Running
#PID: 3380

echo;


## elasticsearch

echo "##Unit elasticsearch.service could not be found.  <<-- not installed and can be ignored"

echo;

echo "Is Elasticsearch running"
systemctl is-active elasticsearch

systemctl status elasticsearch.service  | grep Active

echo;

echo "Is Elasticsearch set to load on boot"
systemctl is-enabled elasticsearch


echo;
#check version and compare against ansible group_var file
rpm -qa | awk '/elasticsearch/'

echo;

##rabbitMQ

echo "##Unit rabbitmq-server.service could not be found.  <<-- not installed and can be ignored"

echo;

echo "Is RabbitMQ running"
systemctl is-active rabbitmq-server
systemctl status rabbitmq-server | grep Active

##Unit rabbitmq-server.service could not be found.  <<-- not installed

echo;

echo "Is RabbitMQ set to load on boot"
systemctl is-enabled rabbitmq-server

echo;


## redis:

echo "Is Redis setup and running"

nkredis info

echo;

for service in $(ls -la /usr/lib/systemd/system/ | grep redis | awk '{print $NF}') ; do echo $service; systemctl status $service | grep Active; echo; done

echo;



#NFS mount:

echo "can be checked from ansible with:"
echo "ansible -b -a 'df -h | grep chroot' Prefix_prod"

echo;

echo "Is NFS mounted for /chroot to FS1"

echo;

host=$(hostname)
if [[ "$host" == "gpc"* ]] || [[ "$host" == "mce"* ]]; then
        echo $host
        df -h | grep chroot
  else
        echo 'not a cluster'
fi



echo;

### php

echo "check if php-fpm services are running"

systemctl status php* | grep -E 'Loaded|Active'

echo;

#Network speed check

echo "check network speeds"

for net in $(ifconfig  | grep -E "Ethernet |BROADCAST," | awk '{print $1}' | sed -n '1p;$p') ; do echo $net; ethtool $net | grep -i speed; echo; done

fi
