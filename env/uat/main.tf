terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.46.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.29"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "azurerm" {
  features {}
}

# Data source to read existing AKS cluster
data "azurerm_kubernetes_cluster" "existing" {
  name                = "hrsm-uat-aks"
  resource_group_name = "rg-hrsm-uat"
}

provider "kubernetes" {
  host                   = data.azurerm_kubernetes_cluster.existing.kube_config[0].host
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.existing.kube_config[0].client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.existing.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.existing.kube_config[0].cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = data.azurerm_kubernetes_cluster.existing.kube_config[0].host
    client_certificate     = base64decode(data.azurerm_kubernetes_cluster.existing.kube_config[0].client_certificate)
    client_key             = base64decode(data.azurerm_kubernetes_cluster.existing.kube_config[0].client_key)
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.existing.kube_config[0].cluster_ca_certificate)
  }
}