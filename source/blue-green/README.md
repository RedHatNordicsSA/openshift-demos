# blue-green demo

## Description
This is a full ci/cd demo featuring a Java EE app with database and a blue-green deployment using templates. Based on Siamak's https://github.com/OpenShiftDemos/openshift-cd-demo and Bernard's https://github.com/gpe-mw-training/appdev-foundations-kitchensink.
The demo deploys three projects (cicd, test & prod). In the cicd project, the CD tooling is deployed. The code and container is built in the test project. In the prod project the application is deployed to either blue or green instances, whichever is not currently receiving production traffic.
The script is waiting for Jenkins to come online, this sometimes times out as there are a lot of images to pull. In that case just remove the cicd project and rerun setup.sh, it will work better the second time when the images are in the registry.

## Instructions
Log in to OpenShift, then run:
1. git clone https://github.com/mglantz/openshift-demos
2. cd openshift-demos/blue-green
3. sh ./install.sh
4. enjoy
