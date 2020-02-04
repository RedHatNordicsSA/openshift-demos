#!/bin/bash

echo "$(date): Setting up demo environment."

echo "$(date): Creating project: demo-greenblue."
oc new-project demo-greenblue --description "Demo of green-blue testing using PHP 7.2 and 7.0" --display-name "Demo - Green-Blue testing"

oc project demo-greenblue

echo "$(date): Creating an PHP 7.2 application."
oc new-app openshift/php:7.2~https://github.com/mglantz/ocp-php.git --name=php72
oc expose service php72

echo "$(date): Creating an PHP 7.0 application"
oc new-app openshift/php:7.0~https://github.com/mglantz/ocp-php.git --name=php70
oc expose service php70

echo "$(date): Creating a route and pointing it at php 7.0 app"
oc expose service php70 --name='greenblue-php' -l name='greenblue-php'

echo "$(date): Waiting for the php applications to build and deploy. This may take a bit: "
while true; do
	if oc get builds|egrep '(php70|php72)'|grep Running|wc -l|grep 0 >/dev/null; then
		if oc get pods|egrep '(php70|php72)'|grep Running|grep "1/1"|wc -l|grep 2 >/dev/null; then
			echo "$(date): Applications will now be up in a couple of seconds."
			break
		fi
	fi
	sleep 1
done
