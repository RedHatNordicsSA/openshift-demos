# HPA (Horizontal Pod Autoscaling) demo

## Description
This is a demo which displays how HPA works on OpenShift. It deploys a simple java app which can generate load to trigger
autoscaling and before that sets everything up for this to work.

## Instructions
On your master server, as root, run:
1. git clone https://github.com/mglantz/openshift-demos
2. cd openshift-demos/hpa
3. sh ./install.sh
4. Go to tasks app and generate load
5. Watch autoscaling working.
