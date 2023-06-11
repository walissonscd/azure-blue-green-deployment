terraform {
  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "=0.1.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
    }
    random = {
    }
  }
}

provider "azapi" {
  default_location = "eastus"
  default_tags = {
    team = "Azure deployments"
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_kubernetes_cluster" "blue" {
  depends_on          = [module.aks_cluster1] # refresh cluster state before reading
  name                = module.aks_cluster1.kubernetes_cluster_name
  resource_group_name = azurerm_resource_group.rg.name
}


provider "kubernetes" {
    alias = "blue"
  host                   = data.azurerm_kubernetes_cluster.blue.kube_config.0.host
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.blue.kube_config.0.client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.blue.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.blue.kube_config.0.cluster_ca_certificate)
}

data "azurerm_kubernetes_cluster" "green" {
  depends_on          = [module.aks_cluster2] # refresh cluster state before reading
  name                = module.aks_cluster2.kubernetes_cluster_name
  resource_group_name = azurerm_resource_group.rg.name
}


provider "kubernetes" {
    alias = "green"
  host                   = data.azurerm_kubernetes_cluster.green.kube_config.0.host
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.green.kube_config.0.client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.green.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.green.kube_config.0.cluster_ca_certificate)
}
