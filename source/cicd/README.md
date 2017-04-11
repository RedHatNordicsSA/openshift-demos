# CI/CD demo

## Description
This is a simple demo which displays how you can do CI/CD on OpenShift with Jenkins Pipeline integration.
The demo deploys three projects (appx-dev, -test, -prod). In the -dev project, the Jenkins pipeline is created.
Allow for the Jenkins pods to become available before running the pipeline.

## Instructions
On your master server, as root, run:
1. git clone https://github.com/mglantz/openshift-demos
2. cd openshift-demos/abtesting
3. sh ./install.sh
4. Go to appx-dev project, wait for Jenkins pods to come online
5. Go to Builds > Pipelines and star the pipeline.
6. Display how a build is started in the appx-dev project and how the same image is then deployed in appx-test for testing.
7. Manually approve promotion to the appx-prod project.
8. Watch deployment into production.
