#!/bin/bash
# Magnus Glantz, sudo@redhat.com, 2017

DEV=0
TEST=0
PROD=0

for env in dev test prod; do
	oc new-project appx-$env
	oc new-app --name appx --image-stream=php:7.0 --code=https://github.com/mglantz/ocp-jenkins.git -n appx-$env
done

oc policy add-role-to-group system:image-puller system:serviceaccounts:appx-test -n appx-dev
oc policy add-role-to-group system:image-puller system:serviceaccounts:appx-prod -n appx-dev

echo "Waiting for appx-dev container to come up."
while true; do
	if oc get pods -n appx-dev|grep -vi build|grep Running|grep "1/1" >/dev/null; then
		break
	fi
	sleep 1
done

echo -n "Sleeping additional 10 seconds: "
for i in {1..10}; do
	echo -n .
	sleep 1
done

oc tag appx:latest appx:TESTready -n appx-dev
oc tag appx:latest appx:PRODready -n appx-dev

oc policy add-role-to-user edit system:serviceaccount:appx-dev:jenkins -n appx-dev
oc policy add-role-to-user edit system:serviceaccount:appx-dev:jenkins -n appx-test
oc policy add-role-to-user edit system:serviceaccount:appx-dev:jenkins -n appx-prod

oc create -f https://raw.githubusercontent.com/mglantz/ocp-jenkins/master/pipeline.yaml -n appx-dev

