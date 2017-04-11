#!/bin/bash
# Magnus Glantz, sudo@redhat.com, 2017
# Horizontal Pod Autoscaling Demo

# Create tasks-app template, will be used to generate load in the HPA demo
oc create -f https://raw.githubusercontent.com/OpenShiftDemos/openshift-tasks/master/app-template.yaml -n openshift

# New project
oc new-project demo-hpa

# New tasks app
oc new-app --template=openshift-tasks

# Configure autoscaling
oc autoscale dc/tasks --min 1 --max 3 --cpu-percent=60

# Set resource limits
oc create -f https://raw.githubusercontent.com/mglantz/openshift-demos/master/source/hpa/limit.json

# Waiting for tasks pod to deploy, when this is done, we're ready.
while true; do
	if oc get pods -n demo-hpa|grep -vi build|grep Running|grep "1/1" >/dev/null; then
		break
	fi
	sleep 1
done

# Demo instructions
echo "Goto: http://$(oc get routes|grep tasks|awk '{ print $2 }') to generate load and see pod autoscale."
