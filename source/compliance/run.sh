#!/bin/bash
# Magnus Glantz, sudo@redhat.com, 2021
# Demo of OpenShift Compliance Operator, to get e8 compliance.

echo "Install the OpenShift Compliance Operator via Operator Hub before continuing."
read -p "Continue?" yes

echo
echo "Selecting compliance profile (e8)"
oc create -f periodic-e8.yaml

echo
echo "Putting in place ScanSetting"
oc create -f periodic-setting.yaml

echo
echo "Showing high level compliance status per compliance profile"
read -p "Continue?" yes
oc get compliancesuite -nopenshift-compliance

echo
echo "Show compliance status per scan target."
read -p "Continue?" yes
oc get compliancescan -nopenshift-compliance

echo
echo "Fetch compliance results for masters."
read -p "Continue?"
oc get compliancecheckresults -nopenshift-compliance -lcompliance.openshift.io/scan-name=rhcos4-e8-master

echo
echo "Fetch compliance results for workers."
read -p "Continue?"
oc get compliancecheckresults -nopenshift-compliance -lcompliance.openshift.io/scan-name=rhcos4-e8-worker

echo
echo "Fetch compliance results for OCP4."
read -p "Continue?"
oc get compliancecheckresults -nopenshift-compliance -lcompliance.openshift.io/scan-name=ocp4-e8

echo
echo "Fetcing remidiation results."
read -p "Continue?"
oc get complianceremediations -l compliance.openshift.io/suite=periodic-e8

echo
echo "Pausing machineconfigpools for workers."
read -p "Continue? " yes
oc patch machineconfigpools worker -p '{"spec":{"paused":true}}' --type=merge

echo
echo "Setting autoApplyRemdiations."
read -p "Continue? " yes
oc patch scansettings periodic-setting -p '{"autoApplyRemediations":true}' --type=merge

echo
echo "Fetching remediation results."
read -p "Continue?"
oc get complianceremediations -l compliance.openshift.io/suite=periodic-e8
