#!/bin/bash

echo Deploy  customer-sservice........

cd /projects/quarkus-workshop-labs/quarkus-petclinic-customers-service

oc delete deployments,dc,bc,build,svc,route,pod,is --all

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
echo "Done! Verify by using steps below:"
echo
echo "curl command:"
echo "$ http://$(oc get route customers-service -o=go-template --template='{{ .spec.host }}')/owners"
echo
echo "Open a web browser and visit:"
echo "http://$(oc get route customers-service -o=go-template --template='{{ .spec.host }}')/owners"
echo
echo "Open a web browser and visit Swagger UI"
echo "http://$(oc get route customers-service -o=go-template --template='{{ .spec.host }}')/swagger-ui"
echo
