#!/bin/sh
oc login -u user1
oc new-project demo-s2i

echo "Create PostgreSQL for Freelancer Service"
oc process  -f postgresql-ephemeral.yml \
-p DATABASE_SERVICE_NAME=freelancer-db \
-p POSTGRESQL_USER=dbuser \
-p POSTGRESQL_PASSWORD=password \
-p POSTGRESQL_DATABASE=sampledb | oc create  -f -
echo "Wait for pod to start ..."
oc rollout status dc freelancer-db
oc get pods --field-selector status.phase=Running
POSTGRES_POD=$(oc get pods -l name=freelancer-db --template='{{(index .items 0).metadata.name}}')
echo "Freelancer Database Pod: $POSTGRES_POD"
oc rsync sql $POSTGRES_POD:/tmp
oc exec $POSTGRES_POD -- bash -c 'psql -U dbuser -d sampledb -a -f /tmp/sql/schema.sql'
echo "Database schema created"
oc exec $POSTGRES_POD -- bash -c 'psql -U dbuser -d sampledb -a -f /tmp/sql/data.sql'
echo "Sample Data Inserted"
oc exec $POSTGRES_POD -- bash -c 'rm -rf /tmp/sql'
echo "Cleanup SQL scripts"
