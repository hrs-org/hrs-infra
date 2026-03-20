project     = "hrsm"
environment = "uat"
location    = "Central India"
common_tags = {
  env = "uat"
}
aks_name           = "hrsm-uat-aks"
dns_prefix         = "hrsm-uat"
kubernetes_version = ""
node_count   = 2
system_node_vm_size = "Standard_B2as_v2"
node_vm_size = "Standard_B4as_v2"
node_max_pods = 60
acr_name = "hrsmuatacr001" # Must be globally unique, lowercase, alphanumeric only

# Helm Chart Versions
metrics_server_chart_version = "3.12.1"
ingress_nginx_chart_version  = "4.11.2"
