oc login -u opentlc-mgr
oc project app-monitor
oc apply -f metrics_service_account.yaml -n app-monitor
oc apply -f metrics_service_monitor.yaml -n app-monitor
oc apply -f metrics_prometheus.yaml -n app-monitor
oc get pods -w -n app-monitor
