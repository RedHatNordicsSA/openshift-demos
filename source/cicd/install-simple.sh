#!/bin/bash

DEV=0
TEST=0
PROD=0
THEPROJECT=$1

# Create projects, apps and routes
for env in dev test prod; do
	oc new-app --name appx-$env --image-stream=php:7.0 --code=https://github.com/mglantz/ocp-jenkins.git -n $THEPROJECT
	oc expose service appx-$env -n $THEPROJECT
done

# Provide access for test and prod projects to pull images from dev
oc policy add-role-to-group system:image-puller system:serviceaccounts:appx-test -n $THEPROJECT
oc policy add-role-to-group system:image-puller system:serviceaccounts:appx-prod -n $THEPROJECT

# Wait for app in dev to come up, so we can tag it
echo "Waiting for appx-dev container to come up."
while true; do
	if oc get pods -n $THEPROJECT|grep -vi build|grep Running|grep "1/1" >/dev/null; then
		break
	fi
	sleep 1
done

echo -n "Sleeping additional 15 seconds: "
for i in {1..15}; do
	echo -n .
	sleep 1
done

# Tag images
oc tag appx-dev:latest appx-test:TESTready -n $THEPROJECT
oc tag appx-dev:latest appx-prod:PRODready -n $THEPROJECT

# Add access for Jenkins pod which will be created soon to dev, test and prod projects
oc policy add-role-to-user edit system:serviceaccount:$THEPROJECT:jenkins -n $THEPROJECT

# Create Jenkins and pipeline
# It points at the Jenkinsfile in https://github.com/mglantz/ocp-jenkins.git
oc create -f https://raw.githubusercontent.com/mglantz/ocp-jenkins/master/pipeline.yaml -n $THEPROJECT

# Change deployment config to point at image build in dev
oc get dc appx-dev -n $THEPROJECT -o yaml >appx-test-dc.yaml
sed -i -e 's/name: appx-test:latest/name: appx:TESTready/' appx-test-dc.yaml
oc replace -f appx-test-dc.yaml -n $THEPROJECT

oc get dc appx-dev -n $THEPROJECT -o yaml >appx-prod-dc.yaml
sed -i -e 's/name: appx-prod:latest/name: appx:PRODready/' appx-prod-dc.yaml
oc replace -f appx-prod-dc.yaml -n appx-prod
