#!/bin/bash

DEV=0
TEST=0
PROD=0

# Create projects, apps and routes
for env in dev test prod; do
	oc new-project appx-$env
done

oc new-app --name appx --image-stream=php:7.0 --code=https://github.com/mglantz/ocp-jenkins.git -n appx-dev
oc expose service appx -n appx-dev

# Provide access for test and prod projects to pull images from dev
oc policy add-role-to-group system:image-puller system:serviceaccounts:appx-test:default -n appx-dev
oc policy add-role-to-group system:image-puller system:serviceaccounts:appx-prod:default -n appx-dev

# Wait for app in dev to come up, so we can tag it
echo "Waiting for appx-dev container to come up."
while true; do
	if oc get pods -n appx-dev|grep -vi build|grep Running|grep "1/1" >/dev/null; then
		break
	fi
	sleep 1
done

echo -n "Sleeping additional 10 seconds: "
for i in {1..15}; do
	echo -n .
	sleep 1
done

# Tag images
oc tag appx:latest appx:TESTready -n appx-dev
oc tag appx:latest appx:PRODready -n appx-dev

# Add access for Jenkins pod which will be created soon to dev, test and prod projects
oc policy add-role-to-user edit system:serviceaccount:appx-dev:jenkins -n appx-dev
oc policy add-role-to-user edit system:serviceaccount:appx-dev:jenkins -n appx-test
oc policy add-role-to-user edit system:serviceaccount:appx-dev:jenkins -n appx-prod

# Create Jenkins and pipeline
# It points at the Jenkinsfile in https://github.com/mglantz/ocp-jenkins.git
oc create -f https://raw.githubusercontent.com/mglantz/ocp-jenkins/master/pipeline.yaml -n appx-dev

# Change deployment config to point at image build in dev
oc new-app --name appx --image-stream=appx-dev/appx:TESTready -n appx-test
oc expose service appx -n appx-test

oc new-app --name appx --image-stream=appx-dev/appx:PRODready -n appx-prod
oc expose service appx -n appx-prod
