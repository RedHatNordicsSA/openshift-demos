#!/bin/bash

echo "$(date): Setting up demo environment."

echo "$(date): Creating project: demo-abtesting."
oc new-project demo-abtesting --description "Demo of AB testing using NodeJS 4.0 and 0.10" --display-name "Demo - AB testing"

oc project demo-abtesting

echo "$(date): Creating an NodeJS 4.0 application."
oc new-app openshift/nodejs:4~https://github.com/mglantz/nodejs-ex.git --name=nodejs40
oc expose service nodejs40

echo "$(date): Creating an NodeJS 0.10 application"
oc new-app openshift/nodejs:0.10~https://github.com/mglantz/nodejs-ex.git --name=nodejs010
oc expose service nodejs010

echo "$(date): Creating an AB route"
oc expose service nodejs40 --name='ab-nodejs' -l name='ab-nodejs'

echo "$(date): Configuring load balancing between the two applications."
oc set route-backends ab-nodejs nodejs40=10 nodejs010=90
oc annotate route/ab-nodejs haproxy.router.openshift.io/balance=static-rr

echo "$(date): Waiting for the nodejs applications to build and deploy. This may take a bit: "
while true; do
	if oc get builds|egrep '(nodejs40|nodejs010)'|grep Running|wc -l|grep 0 >/dev/null; then
		if oc get pods|egrep '(nodejs40|nodejs010)'|grep Running|grep "1/1"|wc -l|grep 2 >/dev/null; then
			echo "$(date): Applications will now be up in a couple of seconds."
			break
		fi
	fi
	sleep 1
done
