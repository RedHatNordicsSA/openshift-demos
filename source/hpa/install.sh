#!/bin/bash
# Magnus Glantz, sudo@redhat.com, 2017
# Horizontal Pod Autoscaling Demo

# Create tasks-app template, will be used to generate load in the HPA demo
if oc get templates -n openshift|grep tasks>/dev/null; then
	echo "Found tasks template. Will not attempt to create."
else
	echo "Creating tasks template"
	oc create -f https://raw.githubusercontent.com/OpenShiftDemos/openshift-tasks/master/app-template.yaml -n openshift
fi

# New project
echo "$(date) Creating demo project: demo-hpa"
oc new-project demo-hpa

# New tasks app
echo "$(date) Creating tasks app"
oc new-app --template=openshift-tasks

# Configure autoscaling
echo "$(date) Configuring autoscaling to 3 pods if CPU util is =>60%"
oc autoscale dc/tasks --min 1 --max 3 --cpu-percent=60

# Set resource limits
echo "$(date) Creating resource limitation of 1 CPU core for tasks app"
oc create -f https://raw.githubusercontent.com/mglantz/openshift-demos/master/source/hpa/limit.json

# Waiting for tasks pod to deploy, when this is done, we're ready.
echo -n "$(date) Waiting for tasks app to deploy (this may take awhile): "
while true; do
	if oc get pods -n demo-hpa|grep -vi build|grep Running|grep "1/1" >/dev/null; then
		break
	else
		echo -n "."
	fi
	sleep 1
done
echo

echo -n "$(date): Waiting for the tasks app to become responsive (this may take awhile): "
TASKS_URL="http://$(oc get routes|grep tasks|awk '{ print $2 }')"
while true; do
	if wget $TASKS_URL -S 2>&1|grep "200 OK" >/dev/null; then
		echo "Connection established to tasks app"
		break
	else
		echo -n "."
	fi
	sleep 1
done
echo

# Demo instructions
echo "$(date) To start demo, goto: $TASKS_URL to generate load and see pod autoscale."
