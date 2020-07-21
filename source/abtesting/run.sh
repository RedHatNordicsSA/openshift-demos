#! /usr/bin/env bash

set -e

source commons.sh

log "Verifying project: $NS."
if oc project $NS; then
	log "Found project $NS."
else
	log "Error: Did not find project. Please run install.sh."
	exit 1
fi

ABROUTE=$(oc get route/ab-php -n $NS --template  '{{"http://"}}{{.spec.host }}' )

log "Dislaying AB route ${ABROUTE}"

RUNNING_PODS=$(oc get pods -n $NS --no-headers | grep -e "php7[23].*1/1.*Running")
echo "${RUNNING_PODS}"

if grep -q 2 <<< "${RUNNING_PODS}"; then
	log "Applications are up. Displaying applications in project $NS:"

	log "${RUNNING_PODS}"
	log "Displaying AB route:"
	oc get route/ab-php
	echo

else
	log "Error: Did not find pods. Please run install.sh."
	exit 1
fi

oc scale --replicas=1 dc php73
oc scale --replicas=1 dc php72

oc set route-backends ab-php php73=10 php72=90


echo
log "Making 100 http requests to the load balanced AB route. 10 out of 100 requests will go to the pod running PHP 7.3."
sleep 1

echo
log "Displaying AB route:"
oc get route/ab-php
sleep 1

echo
read -p "Press enter to continue demo." GO

echo
loaded=0
log "Sending 100 connections to $ABROUTE"
for i in {1..100}; do
	if curl -s $ABROUTE|grep "Version: 7.3" >/dev/null; then
		log "Info: Connection hit pod running PHP version 7.3."
		loaded=$(echo $loaded + 1|bc)
	fi
done
log "Total number of hits to PHP version 7.3 per 100 connections was: $loaded"


echo
read -p "Press enter to continue demo." GO

echo
log "Changing load balancing distribution to send 20 out of 100 requests to the pod running PHP 7.3."
oc set route-backends ab-php php73=20 php72=80
sleep 1

echo
log "Displaying AB route:"
oc get route/ab-php
sleep 1

echo
read -p "Press enter to continue demo." GO

echo
loaded=0
log "Sending 100 connections to $ABROUTE"
for i in {1..100}; do
	if curl -s $ABROUTE|grep "Version: 7.3" >/dev/null; then
		log "Info: Connection hit pod running PHP version 7.3."
		loaded=$(echo $loaded + 1|bc)
	fi
done
log "Total number of hits to PHP version 7.3 per 100 connections was: $loaded"

echo
read -p "Press enter to continue demo." GO

echo
log "Changing load balancing distribution to send 50 out of 100 requests to the pod running PHP 7.3."

oc set route-backends ab-php php73=50 php72=50

echo
log "Displaying AB route:"
oc get route/ab-php
sleep 1

echo
read -p "Press enter to continue demo." GO

echo
loaded=0
log "Sending 100 connections to $ABROUTE"
for i in {1..100}; do
	if curl -s $ABROUTE|grep "Version: 7.3" >/dev/null; then
		log "Info: Connection hit pod running PHP version 7.3."
		loaded=$(echo $loaded + 1|bc)
	fi
done
log "Total number of hits to PHP version 7.3 per 100 connections was: $loaded"


echo
read -p "Press enter to continue demo." GO

echo
log "Changing load balancing distribution to send all requests to the pod running PHP 7.3."

oc set route-backends ab-php php73=100 php72=0

echo
log "Displaying AB route:"
oc get route/ab-php
sleep 1

log "Scaling pod that runs PHP 7.3 to 2 pods."

oc scale --replicas=2 dc php73
sleep 10

log "Displaying running pods."
oc get pods|grep Running

echo
loaded=0
log "Sending 100 connections to $ABROUTE"
for i in {1..100}; do
	if curl -s $ABROUTE|grep "Version: 7.3" >/dev/null; then
		log "Info: Connection hit pod running PHP version 7.3."
		loaded=$(echo $loaded + 1|bc)
	fi
done
log "Total number of hits to PHP version 7.3 per 100 connections was: $loaded"

echo
log "Scaling number of pods running PHP 7.2 to 0."

oc scale --replicas=0 dc php72

sleep 5
log "Displaying pods."
oc get pods|grep Running
