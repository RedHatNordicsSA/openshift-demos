#!/bin/bash

echo "$(date): Setting up demo environment."

echo "$(date): Creating project: demo-abtesting."
oc new-project demo-abtesting --description "Demo of AB testing using PHP 7.2 and 7.0" --display-name "Demo - AB testing"

oc project demo-abtesting

echo "$(date): Creating an PHP 7.2 application."
oc new-app openshift/php:7.2~https://github.com/mglantz/ocp-php.git --name=php72
oc expose service php72

echo "$(date): Creating an PHP 5.6 application"
oc new-app openshift/php:7.0~https://github.com/mglantz/ocp-php.git --name=php70
oc expose service php70

echo "$(date): Creating an AB route"
oc expose service php72 --name='ab-php' -l name='ab-php'

echo "$(date): Configuring load balancing between the two applications."
oc set route-backends ab-php php72=10 php70=90
oc annotate route/ab-php haproxy.router.openshift.io/balance=static-rr

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
