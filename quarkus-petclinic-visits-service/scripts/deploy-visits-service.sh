#!/bin/bash

echo Deploy visits-service........

cd /projects/quarkus-workshop-labs/quarkus-petclinic-visits-service

mvn clean package -DskipTests

#
# Database
#
oc new-app -e POSTGRESQL_USER=visits \
  -e POSTGRESQL_PASSWORD=mysecretpassword \
  -e POSTGRESQL_DATABASE=visits openshift/postgresql:latest \
  --name=visits-database

#
# Quarkus App
#
oc new-build registry.access.redhat.com/openjdk/openjdk-11-rhel7 --binary --name=visits-service -l app=visits-service
oc start-build visits-service --from-file=target/quarkus-petclinic-visits-service-1.0.0-SNAPSHOT-runner.jar --follow
oc new-app visits-service -e QUARKUS_PROFILE=prod
oc expose service visits-service

# clear
echo "Done! Verify by using steps below:"
echo
echo "Run the curl command to view a list of visits (json):"
echo "$ curl http://$(oc get route visits-service -o=go-template --template='{{ .spec.host }}')/pets/visits?petIds=8"
echo
echo "Open a web browser and visit the URL to view a list of visits (json):"
echo "http://$(oc get route visits-service -o=go-template --template='{{ .spec.host }}')/pets/visits?petIds=8"
echo
echo "Open a web browser and visit Swagger UI"
echo "http://$(oc get route visits-service -o=go-template --template='{{ .spec.host }}')/swagger-ui"
echo
