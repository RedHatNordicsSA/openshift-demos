# OpenShift demos
Here follows instructions of how to setup the demos on OpenShift Container Platform.
Please note that these demos have been developed and tested on the latest version of OpenShift, which atm is 3.4.

## Scripts
All demos has one or two of the following scripts, written in bash shell.
* install.sh - This script will install the demo in your environment, preparing everything needed to get the demo running.
* run.sh - This script (if it exists for a demo) will run a demo in a semi-automated fashion.

## Howto prepare for a demo
To run install a demo in your OpenShift environment, on your OpenShift master server, as root, run:
1. git clone https://github.com/mglantz/openshift-demos
2. cd openshift-demos/source/name-of-demo-to-run
3. sh ./install.sh

## Howto run a demo
Follow the instructions printed out by the install.sh script or (if it exists) run the 'run.sh' script as follows:
1. git clone https://github.com/mglantz/openshift-demos
2. cd openshift-demos/source/name-of-demo-to-run
3. sh ./run.sh

## Contributing your own demos
It would be awesome if you can contribute your own demonstrations :-)

* All demos have to be working on the latest version of OpenShift
* Demos must take into account that ovs-multitenant (separation of project communication) may be running.
* Demos should be self explainatory or include a README.md file in it's source directory.
* Installation of demos must be fully automated, it's OK if running a demo is a manual or semi-manual task.
