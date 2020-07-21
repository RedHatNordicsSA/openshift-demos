#!/bin/bash

set -e

source commons.sh

log "Setting up demo environment."

log "Creating project: $NS."

oc project $NS

if [ "$?" -ne 0];
then
    # Create project
    oc new-project $NS --description "Demo of AB testing using PHP 7.3 and 7.2" --display-name "Demo - AB testing"
fi


log "Creating an PHP 7.2 application."
oc new-app openshift/php:7.2~https://github.com/mglantz/ocp-php.git --name=php72 -n $NS
oc expose service php72 -n $NS

log "Creating an PHP 7.3 application"
oc new-app openshift/php:7.3~https://github.com/mglantz/ocp-php.git --name=php73 -n $NS
oc expose service php73 -n $NS

log "Creating an AB route"
oc expose service php72 --name='ab-php' -l name='ab-php' -n $NS

log "Configuring load balancing between the two applications."
oc set route-backends ab-php php73=10 php72=90 -n $NS
oc annotate route/ab-php haproxy.router.openshift.io/balance=static-rr -n $NS

log "Waiting for the php applications to build and deploy. This may take a bit: "
# oc get builds -n $NS|egrep '(php73|php72)'|grep Running|wc -l|grep 0 >/dev/null
# oc get pods -n $NS|egrep '(php73|php72)'|grep Running|grep "1/1"|wc -l|grep 2 >/dev/null
while true; do
	if oc get builds -n $NS|grep -e 'php7[23].*Running' -c |grep -q 0; then
		if oc get pods -n $NS|grep -e 'php7[23].*1/1.*Running' -c|grep -q 2; then
			log "Applications will now be up in a couple of seconds."
			break
		fi
	fi
	sleep 1
done
