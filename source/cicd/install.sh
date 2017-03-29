#!/bin/bash

DEV=0
TEST=0
PROD=0

# Create projects, apps and routes
for env in dev test prod; do
	oc new-project appx-$env
	oc new-app --name appx --image-stream=php:7.0 --code=https://github.com/mglantz/ocp-jenkins.git -n appx-$env
	oc expose service appx -n appx-$env
done

# Provide access for test and prod projects to pull images from dev
oc policy add-role-to-group system:image-puller system:serviceaccounts:appx-test -n appx-dev
oc policy add-role-to-group system:image-puller system:serviceaccounts:appx-prod -n appx-dev

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
oc get dc appx -n appx-test -o yaml >appx-test-dc.yaml
sed -i -e 's/name: appx:latest/name: appx:TESTready/' appx-test-dc.yaml
sed -i -e '0,/namespace: appx-test/! {0,/namespace: appx-test/ s/namespace: appx-test/namespace: appx-dev/}' appx-test-dc.yaml
oc replace -f appx-test-dc.yaml -n appx-test

oc get dc appx -n appx-prod -o yaml >appx-prod-dc.yaml
sed -i -e 's/name: appx:latest/name: appx:PRODready/' appx-prod-dc.yaml
sed -i -e '0,/namespace: appx-prod/! {0,/namespace: appx-prod/ s/namespace: appx-prod/namespace: appx-dev/}' appx-prod-dc.yaml
oc replace -f appx-prod-dc.yaml -n appx-prod
