#!/bin/bash

echo "$(date): Verifying project: demo-greenblue."
if oc get project demo-greenblue|grep Active >/dev/null 2>&1; then
	echo "Found project demo-greenblue."
else
	echo "Error: Did not find project. Please run install.sh."
	exit 1
fi
sleep 1

oc project demo-greenblue

echo
if oc get pods|egrep '(php70|php72)'|grep Running|grep "1/1"|wc -l|grep 2 >/dev/null; then
	echo "$(date): Applications are up. Displaying applications in project demo-greenblue:"
	oc get pods|egrep '(php72|php72)'|grep Running|grep "1/1"
	echo
	echo "$(date): Displaying AB route:"
	oc get route|grep greenblue-php
        GREENBLUEROUTE=$(oc get route greenblue-php|grep greenblue-php|awk '{ print $2 }')
	echo

else
	echo "$(date): Error: Did not find pods. Please run install.sh."
	exit 1
fi

# Reset environment
oc scale --replicas=1 dc php72
oc scale --replicas=1 dc php70
oc patch route/greenblue-php -p '{"spec":{"to":{"name":"php70"}}}'

echo
echo "$(date): Making 5 http requests to the green-blue route. Requests will go to the pod running PHP 7.0."
sleep 1

echo
echo "$(date): Displaying AB route:"
oc get route|grep greenblue-php
sleep 1

echo
read -p "Press enter to continue demo." GO

echo
echo "Sending 5 connections to http://$GREENBLUEROUTE"
for i in {1..5}; do
	curl -s http://$GREENBLUEROUTE|grep "Version:"
done


echo
read -p "Press enter to continue demo." GO

echo
echo "$(date): Changing load balancing and sending traffic to the pod running PHP 7.2."
oc patch route/greenblue-php -p '{"spec":{"to":{"name":"php72"}}}'

sleep 1

echo
echo "$(date): Displaying AB route:"
oc get route|grep greenblue-php
sleep 1

echo
read -p "Press enter to continue demo." GO

echo
echo "Sending 5 connections to http://$GREENBLUEROUTE"
for i in {1..5}; do
        curl -s http://$GREENBLUEROUTE|grep "Version:"
done

echo
read -p "Press enter to continue demo." GO

echo
echo "$(date): Changing load balancing back to pod running PHP 7.0."
oc patch route/greenblue-php -p '{"spec":{"to":{"name":"php70"}}}'

echo
echo "$(date): Displaying AB route:"
oc get route|grep greenblue-php
sleep 1

echo
read -p "Press enter to continue demo." GO

echo
echo "Sending 5 connections to http://$GREENBLUEROUTE"
for i in {1..5}; do
        curl -s http://$GREENBLUEROUTE|grep "Version:"
done


