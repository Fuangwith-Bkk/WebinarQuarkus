oc login -u opentlc-mgr
oc project app-monitor
oc apply -f metrics_grafana_datasource.yaml -n app-monitor
oc apply -f metrics_grafana.yaml -n app-monitor
oc apply -f metrics_grafana_dashboard.yaml -n app-monitor
oc get pods -w -n app-monitor

echo "https://$(oc get route grafana-route -n app-monitor -o jsonpath='{.spec.host}')"
