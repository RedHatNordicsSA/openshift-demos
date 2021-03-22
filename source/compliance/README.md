# Demo of OpenShift Compliance Scanning
A free feature on OpenShift Container Platform. Turn complicated work into almost immediate and
continued compliance. Uses OpenSCAP.

In this demo we apply military grade hardening (e8) to OpenShift Container Platform.

# Installing demo
Go to the webconsole of your cluster and click install on the Compliance Operator.
No specific settings, just click install.

# Running demo.
DO NOT run on production clusters, this will harden your cluster to the point where apps may break.

Login to cluster with oc command and run below command to run demo:
```
sh ./run.sh
```

# Learn more

Have a look here: https://github.com/openshift/compliance-operator/blob/master/doc/tutorials/workshop/content/exercises/03-creating-your-first-scan.md
