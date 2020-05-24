
export NEXUS_PASSWORD=$(oc rsh $1 cat /nexus-data/admin.password)
echo "NEXUS_PASSWORD = ${NEXUS_PASSWORD}"


oc set deployment-hook dc/nexus --mid --volumes=nexus-volume-1 \
-- /bin/sh -c "echo nexus.scripts.allowCreation=true >./nexus-data/etc/nexus.properties"

oc rollout latest dc/nexus
oc get pods -w

curl -o setup_nexus3.sh -s https://raw.githubusercontent.com/redhat-gpte-devopsautomation/ocp_advanced_development_resources/master/nexus/setup_nexus3.sh
chmod +x setup_nexus3.sh
./setup_nexus3.sh admin $NEXUS_PASSWORD http://$(oc get route nexus --template='{{ .spec.host }}')

oc expose dc nexus --port=5000 --name=nexus-registry
oc create route edge nexus-registry --service=nexus-registry --port=5000

oc get routes -n demo-nexus
echo "NEXUS_PASSWORD = ${NEXUS_PASSWORD}"
