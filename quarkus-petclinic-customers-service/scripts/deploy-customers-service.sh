#!/bin/bash

USERXX=$1
DELAY=$2

if [ -z "$USERXX" -o "$USERXX" = "userXX" ]
  then
    echo "Usage: Input your username like deploy-inventory.sh user1"
    exit;
fi

echo Your username is $USERXX

echo Deploy  customer-sservice........

cd /projects/quarkus-workshop-labs/quarkus-petclinic-customers-service

oc delete dc,bc,build,svc,route,pod,is --all

mvn clean package -DskipTests

echo "Waiting 30 seconds to finalize deletion of resources..."
sleep 30

#
# Database
#
oc new-app -e POSTGRESQL_USER=customers \
  -e POSTGRESQL_PASSWORD=mysecretpassword \
  -e POSTGRESQL_DATABASE=customers openshift/postgresql:latest \
  --name=customers-database

#
# Quarkus App
#
oc new-build registry.access.redhat.com/openjdk/openjdk-11-rhel7 --binary --name=customers-service -l app=customers-service

if [ ! -z $DELAY ]
  then 
    echo Delay is $DELAY
    sleep $DELAY
fi

oc start-build customers-service --from-file=target/quarkus-petclinic-customers-service-1.0.0-SNAPSHOT-runner.jar --follow
oc new-app customers-service -e QUARKUS_PROFILE=prod
oc expose service customers-service

clear
echo "Done! Verify by accessing in your browser:"
echo
echo "http://$(oc get route customers-service -o=go-template --template='{{ .spec.host }}')"
echo