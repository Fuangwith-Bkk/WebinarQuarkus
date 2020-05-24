# Prepare for demo
   Request OpenShift 4.4 environment from RHPDS

## Install Serverless
  - Login OpenShift Web Console by admin account (opentlc-mgr)
  - Operators -> OperatorHub -> install "OpenShift Serverless Operator"
    - channel 4.4, automatic update
  - Operators -> OperatorHub -> install 
    - Red Hat OpenShift Service Mesh
    - Kiali Operator
    - Elasticsearch Operator
    - Red Hat OpenShift Jaeger
  - Create new project "Knative-Serving"
  - Goto "Installed Operator" wait until all operators status are "Succeeded"
  - Click on "OpenShift Serverless Operator"
  - click "Create Knative Serving" -> "Create"
  - Goto "Workload" -> "Pods" wait until 9 Pods are running
  
## Install Prometheus and Grafana
  - Login OpenShift Web Console by admin account (opentlc-mgr)
  - Create new project "app-monitor"
  - Operators -> OperatorHub -> install 
    - Prometheus Operator
    - Grafana Operator
  - waiting until both operator pods are running
  ```
  cd ./Init/2.Grafana
  ./1.setupPrometheus.sh
  ``` 
  - wait until prometheus pods are running
  ```
  oc create route edge prometheus --service=prometheus --port=9090 -n app-monitor
  echo "https://$(oc get route prometheus -n app-monitor -o jsonpath='{.spec.host}')"
  ```
  - Check Prometheus dashboard
  ```
  ./2.setupGrafana.sh
  ```
  - Login Grafana dashboard with user: root, pwd: secret
  - Import Init/2.Grafana/freelancer-s2i-grafana.json dashboard
  
  
## Deploy Nexus

    oc login -u user1 https://api.cluster-bkk-8034.bkk-8034.example.opentlc.com:6443
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

Waiting for Nexus pod is in Running status
    
    oc get pods -w -n demo-nexus
    NAME             READY   STATUS      RESTARTS   AGE
    nexus-1-deploy   0/1     Completed   0          6m10s
    nexus-2-deploy   0/1     Completed   0          5m11s
    nexus-2-xs2bl    1/1     Running     0          4m39s
    
    export NEXUS_PASSWORD=$(oc rsh nexus-2-xs2bl cat /nexus-data/admin.password)
    echo $NEXUS_PASSWORD
    oc set deployment-hook dc/nexus --mid --volumes=nexus-volume-1 \
    -- /bin/sh -c "echo nexus.scripts.allowCreation=true >./nexus-data/etc/nexus.properties"

    oc rollout latest dc/nexus
    curl -o setup_nexus3.sh -s https://raw.githubusercontent.com/redhat-gpte-devopsautomation/ocp_advanced_development_resources/master/nexus/setup_nexus3.sh
    chmod +x setup_nexus3.sh
    ./setup_nexus3.sh admin $NEXUS_PASSWORD http://$(oc get route nexus --template='{{ .spec.host }}')
    oc expose dc nexus --port=5000 --name=nexus-registry
    oc create route edge nexus-registry --service=nexus-registry --port=5000
    oc get routes -n demo-nexus
    
  - Go to Nexus webconsole
  - Sign-in with admin/$NEXUS_PASSWORD
  - change password and allow anonymous access
 
## Test demo S2I and cache to Nexus

prepare environment

    oc login -u user1 https://api.cluster-bkk-8034.bkk-8034.example.opentlc.com:6443
    oc new-project demo-s2i
    cd Webinar/Init/2.Postgresql
    ./create_postgresql.sh
    
change freelancer-db's icon by setting following label:

    app.kubernetes.io/name=postgresql

test 1st run and cache to Nexus

    oc new-build \
    registry.access.redhat.com/ubi8/openjdk-11~https://gitlab.com/ocp-demo/freelancer-quarkus.git \
    --name=freelancer-s2i \
    -e MAVEN_MIRROR_URL=http://nexus.demo-nexus.svc.cluster.local:8081/repository/maven-all-public/ \
    -l app=freelancer-s2i
    
    oc new-app freelancer-s2i  --name=freelancer-s2i \
    -l app.kubernetes.io/name=quarkus app=freelancer-s2i

    oc expose svc freelancer-s2i \
    -l app=freelancer-s2i
    
check deployment progress and Nexus (maven-all-public)

    oc delete all --selector app=freelancer-s2i
    

## Test demo Serverless
  - Developer View -> "Add" -> "Container Image"
  - Image name from external registry: quay.io/voravitl/freelancer-native:v1
  - Resources: Knative Service
  - Create
  - http://<url>/
  - http://<url>/freelancers/
  - http://<url>/freelancers/1234567
  - http://<url>/freelancers/234567

# Test demo Prometheus and Grafana
  - Go to Prometheus 
  - Execute "...count...findAll"
  - http://<url>/freelancers/
  - wait and execute again
  - Go to Grafana dashboard
  - review result
