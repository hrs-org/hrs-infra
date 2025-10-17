variable "project" {
  description = "Project name"
  type        = string
  default     = "hrsm"
}

variable "environment" {
  description = "Environment (uat, prod, etc.)"
  type        = string
  default     = "uat"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "Southeast Asia"
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = { env = "uat" }
}

variable "aks_name" {
  description = "AKS cluster name"
  type        = string
  default     = "hrsm-uat-aks"
}

variable "acr_name" {
  description = "Azure Container Registry name (must be globally unique)"
  type        = string
  default     = "hrsmuatacr001"
}

variable "kubernetes_version" {
  description = "AKS Kubernetes version (optional; blank to use default)"
  type        = string
  default     = ""
}

variable "node_count" {
  description = "User node pool count"
  type        = number
  default     = 1
}

variable "node_vm_size" {
  description = "VM size for user node pool"
  type        = string
  default     = "Standard_B2s"
}

variable "dns_prefix" {
  description = "DNS prefix for AKS"
  type        = string
  default     = "hrsm-uat"
}

variable "metrics_server_chart_version" {
  description = "metrics-server chart version"
  type        = string
  default     = "3.12.1"
}

variable "ingress_nginx_chart_version" {
  description = "ingress-nginx chart version"
  type        = string
  default     = "4.11.2"
}
