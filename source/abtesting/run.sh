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
if oc get pods|egrep '(nodejs010|nodejs40)'|grep Running|grep "1/1"|wc -l|grep 2 >/dev/null; then
	echo "$(date): Applications are up. Displaying applications in project demo-abtesting:"
	oc get pods|egrep '(nodejs010|nodejs40)'|grep Running|grep "1/1"
	echo
	echo "$(date): Displaying AB route:"
	oc get route|grep ab-nodejs
	echo

else
	echo "$(date): Error: Did not find pods. Please run install.sh."
	exit 1
fi

oc scale --replicas=1 dc nodejs40
oc scale --replicas=1 dc nodejs010

oc set route-backends ab-nodejs nodejs40=10 nodejs010=90
ABROUTE=$(oc get route|grep ab-nodejs|awk '{ print $2 }')

echo
echo "$(date): Making 10 http requests to the load balanced AB route. 1 out of 10 requests will go to the pod running NodeJS 4.0."
sleep 1

echo
echo "$(date): Displaying AB route:"
oc get route|grep ab-nodejs
sleep 1

echo
read -p "Press enter to continue demo." GO

echo
for i in {1..10}; do
	curl -s http://$ABROUTE|grep Version
	sleep 1
done

echo
read -p "Press enter to continue demo." GO

echo
echo "$(date): Changing load balancing distribution to send 1 out of 5 requests to the pod running NodeJS 4.0."
oc set route-backends ab-nodejs nodejs40=20 nodejs010=80
sleep 1

echo
echo "$(date): Displaying AB route:"
oc get route|grep ab-nodejs
sleep 1

echo
read -p "Press enter to continue demo." GO

echo
echo "$(date): Making 5 http requests to the load balanced AB route."
for i in {1..5}; do
        curl -s http://$ABROUTE|grep Version
        sleep 1
done

echo
read -p "Press enter to continue demo." GO

echo
echo "$(date): Changing load balancing distribution to send 1 out of 2 requests to the pod running NodeJS 4.0."

oc set route-backends ab-nodejs nodejs40=50 nodejs010=50

echo
echo "$(date): Displaying AB route:"
oc get route|grep ab-nodejs
sleep 1

echo
read -p "Press enter to continue demo." GO

echo
echo "$(date): Making 10 http requests to the load balanced AB route."
for i in {1..10}; do
        curl -s http://$ABROUTE|grep Version
        sleep 1
done

echo
read -p "Press enter to continue demo." GO

echo
echo "$(date): Changing load balancing distribution to send all requests to the pod running NodeJS 4.0."

oc set route-backends ab-nodejs nodejs40=100 nodejs010=0

echo
echo "$(date): Displaying AB route:"
oc get route|grep ab-nodejs
sleep 1

echo "$(date): Scaling pod that runs Nodejs 4.0 to 2 pods."

oc scale --replicas=2 dc nodejs40
sleep 15

echo "$(date): Displaying running pods."
oc get pods|grep Running

echo
echo "$(date): Making 10 http requests to the load balanced AB route."
for i in {1..10}; do
        curl -s http://$ABROUTE|grep Version
        sleep 1
done

echo
echo "$(date): Scaling number of pods running NodeJS 0.10 to 0."

oc scale --replicas=0 dc nodejs010

sleep 5
echo "$(date): Displaying pods."
oc get pods|grep Running

