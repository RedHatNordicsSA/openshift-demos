#!/bin/bash
# Magnus Glantz, sudo@redhat.com, 2017
# Horizontal Pod Autoscaling Demo

oc new-project demo-hpa
oc new-app --template=openshift-tasks
oc autoscale dc/tasks --min 1 --max 3 --cpu-percent=60
oc create -f https://raw.githubusercontent.com/mglantz/openshift-demos/master/source/hpa/limits.json
oc rollout latest dc/tasks
