Gateway App
   ↓ exposes
/metrics endpoint
   ↓
ServiceMonitor finds service
   ↓
Prometheus scrapes metrics
   ↓
Grafana visualizes metrics

 What is ServiceMonitor?
ServiceMonitor is a CRD created by:

kube-prometheus-stack

It tells Prometheus:

which service to monitor
where metrics endpoint exists
scrape interval

It monitors
Kubernetes Services not pods 