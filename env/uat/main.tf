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
  subscription_id = "5c9469e7-791b-4904-b189-abd1ac5ef787"
}

resource "azurerm_resource_group" "main" {
  name     = "rg-${var.project}-${var.environment}"
  location = var.location
  tags     = var.common_tags
}

resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Basic"
  admin_enabled       = false
  tags                = var.common_tags
}

resource "random_string" "dns" {
  length  = 4
  upper   = false
  special = false
  numeric = true
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "${var.dns_prefix}-${random_string.dns.result}"

  kubernetes_version = var.kubernetes_version != "" ? var.kubernetes_version : null

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name            = "systemnp"
    node_count      = 1
    vm_size         = "Standard_B2s"
    os_disk_size_gb = 64
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
    dns_service_ip    = "10.2.0.10"
    service_cidr      = "10.2.0.0/24"
  }

  role_based_access_control_enabled = true

  tags = var.common_tags
}

resource "azurerm_kubernetes_cluster_node_pool" "usernp" {
  name                  = "usernp"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = var.node_vm_size
  node_count            = var.node_count
  max_pods              = 110
  mode                  = "User"
}

resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}

provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.aks.kube_config[0].host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = azurerm_kubernetes_cluster.aks.kube_config[0].host
    client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].cluster_ca_certificate)
  }
}

resource "kubernetes_namespace" "infra" {
  metadata { name = "infra" }
}

resource "kubernetes_namespace" "gateway" {
  metadata { name = "gateway" }
}

resource "kubernetes_namespace" "users" {
  metadata { name = "users" }
}

resource "kubernetes_namespace" "orders" {
  metadata { name = "orders" }
}

resource "kubernetes_namespace" "store" {
  metadata { name = "store" }
}

resource "kubernetes_namespace" "payments" {
  metadata { name = "payments" }
}

resource "kubernetes_namespace" "maintenance" {
  metadata { name = "maintenance" }
}

# metrics-server is pre-installed in AKS by default, no need to install via Helm

resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = kubernetes_namespace.infra.metadata[0].name
  version    = var.ingress_nginx_chart_version

  values = [
    yamlencode({
      controller = {
        replicaCount = 1
        service = {
          type = "LoadBalancer"
        }
      }
    })
  ]

  depends_on = [
    azurerm_kubernetes_cluster.aks,
    azurerm_kubernetes_cluster_node_pool.usernp,
    kubernetes_namespace.infra
  ]
}

output "resource_group" {
  value = azurerm_resource_group.main.name
}

output "aks_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}
