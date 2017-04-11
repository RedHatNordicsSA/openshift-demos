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

# Redeploy tasks app accordingly
oc rollout latest dc/tasks
