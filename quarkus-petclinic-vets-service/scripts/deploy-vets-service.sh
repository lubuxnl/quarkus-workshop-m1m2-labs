#!/bin/bash

echo Deploy vets-service........

cd /projects/quarkus-workshop-labs/quarkus-petclinic-vets-service

mvn clean package -DskipTests

#
# Database
#
oc new-app -e POSTGRESQL_USER=vets \
  -e POSTGRESQL_PASSWORD=mysecretpassword \
  -e POSTGRESQL_DATABASE=vets openshift/postgresql:latest \
  --name=vets-database

#
# Quarkus App
#
oc new-build registry.access.redhat.com/openjdk/openjdk-11-rhel7 --binary --name=vets-service -l app=vets-service

if [ ! -z $DELAY ]
  then 
    echo Delay is $DELAY
    sleep $DELAY
fi

oc start-build vets-service --from-file=target/quarkus-petclinic-vets-service-1.0.0-SNAPSHOT-runner.jar --follow
oc new-app vets-service -e QUARKUS_PROFILE=prod
oc expose service vets-service

clear
echo "Done! Verify by using steps below:"
echo
echo "Run the curl command to view a list of vets (json):"
echo "$ curl http://$(oc get route vets-service -o=go-template --template='{{ .spec.host }}')/vets"
echo
echo "Open a web browser and visit the URL to view a list of vets (json):"
echo "http://$(oc get route vets-service -o=go-template --template='{{ .spec.host }}')/vets"
echo
echo "Open a web browser and visit Swagger UI"
echo "http://$(oc get route vets-service -o=go-template --template='{{ .spec.host }}')/swagger-ui"
echo
