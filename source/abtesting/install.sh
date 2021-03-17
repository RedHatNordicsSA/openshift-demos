#!/bin/bash

echo "$(date): Setting up demo environment."

echo "$(date): Creating project: demo-abtesting."
oc new-project demo-abtesting --description "Demo of AB testing using PHP 7.3 and 7.2" --display-name "Demo - AB testing"

oc project demo-abtesting

echo "$(date): Creating an PHP 7.2 application."
oc new-app openshift/php:7.3-ubi8~https://github.com/mglantz/ocp-php.git --name=php73 -n demo-abtesting
oc expose service php73 -n demo-abtesting

echo "$(date): Creating an PHP 7.3 application"
oc new-app openshift/php:7.4-ubi8~https://github.com/mglantz/ocp-php.git --name=php74 -n demo-abtesting
oc expose service php74 -n demo-abtesting

echo "$(date): Creating an AB route"
oc expose service php73 --name='ab-php' -l name='ab-php' -n demo-abtesting

echo "$(date): Configuring load balancing between the two applications."
oc set route-backends ab-php php74=10 php73=90 -n demo-abtesting
oc annotate route/ab-php haproxy.router.openshift.io/balance=static-rr -n demo-abtesting

echo "$(date): Waiting for the php applications to build and deploy. This may take a bit: "
while true; do
	if oc get builds -n demo-abtesting|egrep '(php74|php73)'|grep Running|wc -l|grep 0 >/dev/null; then
		if oc get pods -n demo-abtesting|egrep '(php74|php73)'|grep Running|grep "1/1"|wc -l|grep 2 >/dev/null; then
			echo "$(date): Applications will now be up in a couple of seconds."
			break
		fi
	fi
	sleep 1
done
