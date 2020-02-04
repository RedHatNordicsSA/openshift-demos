#!/bin/bash

echo "$(date): Verifying project: demo-abtesting."
if oc get project demo-abtesting|grep Active >/dev/null 2>&1; then
	echo "Found project demo-abtesting."
else
	echo "Error: Did not find project. Please run install.sh."
	exit 1
fi
sleep 1

oc project demo-abtesting

echo
if oc get pods|egrep '(php70|php72)'|grep Running|grep "1/1"|wc -l|grep 2 >/dev/null; then
	echo "$(date): Applications are up. Displaying applications in project demo-abtesting:"
	oc get pods|egrep '(php72|php72)'|grep Running|grep "1/1"
	echo
	echo "$(date): Displaying AB route:"
	oc get route|grep ab-php
	echo

else
	echo "$(date): Error: Did not find pods. Please run install.sh."
	exit 1
fi

oc scale --replicas=1 dc php72
oc scale --replicas=1 dc php70

oc set route-backends ab-php php72=10 php70=90
ABROUTE=$(oc get route|grep ab-php|awk '{ print $2 }')

echo
echo "$(date): Making 100 http requests to the load balanced AB route. 10 out of 100 requests will go to the pod running PHP 7.2."
sleep 1

echo
echo "$(date): Displaying AB route:"
oc get route|grep ab-php
sleep 1

echo
read -p "Press enter to continue demo." GO

echo
loaded=0
echo "Sending 100 connections to http://$ABROUTE"
for i in {1..100}; do
	if curl -s http://$ABROUTE|grep "Version: 7.2" >/dev/null; then
		echo "Info: Connection hit pod running PHP version 7.2."
		loaded=$(echo $loaded + 1|bc)
	fi
done
echo "Total number of hits to PHP version 7.2 per 100 connections was: $loaded"


echo
read -p "Press enter to continue demo." GO

echo
echo "$(date): Changing load balancing distribution to send 20 out of 100 requests to the pod running PHP 7.2."
oc set route-backends ab-php php72=20 php70=80
sleep 1

echo
echo "$(date): Displaying AB route:"
oc get route|grep ab-php
sleep 1

echo
read -p "Press enter to continue demo." GO

echo
loaded=0
echo "Sending 100 connections to http://$ABROUTE"
for i in {1..100}; do
        if curl -s http://$ABROUTE|grep "Version: 7.2" >/dev/null; then
                echo "Info: Connection hit pod running PHP version 7.2."
                loaded=$(echo $loaded + 1|bc)
        fi
done
echo "Total number of hits to PHP version 7.2 per 100 connections was: $loaded"

echo
read -p "Press enter to continue demo." GO

echo
echo "$(date): Changing load balancing distribution to send 50 out of 100 requests to the pod running PHP 7.2."

oc set route-backends ab-php php72=50 php70=50

echo
echo "$(date): Displaying AB route:"
oc get route|grep ab-php
sleep 1

echo
read -p "Press enter to continue demo." GO

echo
loaded=0
echo "Sending 100 connections to http://$ABROUTE"
for i in {1..100}; do
        if curl -s http://$ABROUTE|grep "Version: 7.2" >/dev/null; then
                echo "Info: Connection hit pod running PHP version 7.2."
                loaded=$(echo $loaded + 1|bc)
        fi
done
echo "Total number of hits to PHP version 7.2 per 100 connections was: $loaded"


echo
read -p "Press enter to continue demo." GO

echo
echo "$(date): Changing load balancing distribution to send all requests to the pod running PHP 7.2."

oc set route-backends ab-php php72=100 php70=0

echo
echo "$(date): Displaying AB route:"
oc get route|grep ab-php
sleep 1

echo "$(date): Scaling pod that runs PHP 7.2 to 2 pods."

oc scale --replicas=2 dc php72
sleep 10

echo "$(date): Displaying running pods."
oc get pods|grep Running

echo
loaded=0
echo "Sending 100 connections to http://$ABROUTE"
for i in {1..100}; do
        if curl -s http://$ABROUTE|grep "Version: 7.2" >/dev/null; then
                echo "Info: Connection hit pod running PHP version 7.2."
                loaded=$(echo $loaded + 1|bc)
        fi
done
echo "Total number of hits to PHP version 7.2 per 100 connections was: $loaded"

echo
echo "$(date): Scaling number of pods running PHP 7.0 to 0."

oc scale --replicas=0 dc php70

sleep 5
echo "$(date): Displaying pods."
oc get pods|grep Running

