oc login -u user1
oc new-project demo-nexus --display-name "Nexus for demo"
oc new-app sonatype/nexus3:3.21.2 --name=nexus
oc expose svc nexus
oc rollout pause dc nexus
oc patch dc nexus --patch='{ "spec": { "strategy": { "type": "Recreate" }}}'
oc set resources dc nexus --limits=memory=2Gi,cpu=2 --requests=memory=1Gi,cpu=500m
oc set volume dc/nexus --add --overwrite --name=nexus-volume-1 --mount-path=/nexus-data/ --type persistentVolumeClaim --claim-name=nexus-pvc --claim-size=10Gi
oc set probe dc/nexus --liveness --failure-threshold 3 --initial-delay-seconds 60 -- echo ok
oc set probe dc/nexus --readiness --failure-threshold 3 --initial-delay-seconds 60 --get-url=http://:8081/
oc rollout resume dc nexus
oc get pods -w -n demo-nexus
