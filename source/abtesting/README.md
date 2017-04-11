# AB testing demo

## Description
This is a demo which displays how to do AB testing with OpenShift. The demo shows how to move a simple PHP application
from one version of the PHP framework (5.6) to a newer version (7.0), step-by-step by tuning amount of traffic going to
the new service. In the end, the old service is decomissioned after a smooth transition.

## Instructions
On your master server, as root, run:
1. git clone https://github.com/mglantz/openshift-demos
2. cd openshift-demos/abtesting
3. sh ./install.sh
4. sh ./run.sh
