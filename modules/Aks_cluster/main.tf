resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = var.cluster_name
  location            = local.location
  resource_group_name = var.resource_group_name

  default_node_pool {
    name            = "default"
    node_count      = 1
    vm_size         = "Standard_DS2_v2"
    os_disk_size_gb = 30
    vnet_subnet_id  = var.vnet_subnet_id
  }

  identity {
    type = "UserAssigned"
    identity_ids = [var.managed_identity]
  }

  dns_prefix = var.cluster_name

   ingress_application_gateway {
      gateway_id = var.gateway_id
    }

  network_profile {
    network_plugin = "azure"
    service_cidr   = "10.10.0.0/16"  # Customize the service CIDR here
    dns_service_ip = "10.10.0.10"    # Customize the DNS service IP here
  }

}

output "aks_id" {
  value = azurerm_kubernetes_cluster.aks_cluster.id
}

output "node_pool_rg" {
  value = azurerm_kubernetes_cluster.aks_cluster.node_resource_group
}

# Managed Identities created for Addons

output "kubelet_id" {
  value = azurerm_kubernetes_cluster.aks_cluster.kubelet_identity[0].object_id
}

output "agic_id" {
  value = azurerm_kubernetes_cluster.aks_cluster.ingress_application_gateway[0].ingress_application_gateway_identity[0].object_id
}

 output "host" {
   value = azurerm_kubernetes_cluster.aks_cluster.kube_config.0.host
   sensitive = true
 }

 output "kubernetes_cluster_name" {
  value = azurerm_kubernetes_cluster.aks_cluster.name
  sensitive = true
}

 output "client_key" {
   value = azurerm_kubernetes_cluster.aks_cluster.kube_config.0.client_key
   sensitive = true
}

 output "client_certificate" {
   value = azurerm_kubernetes_cluster.aks_cluster.kube_config.0.client_certificate
   sensitive = true
}


output "cluster_username" {
  value = azurerm_kubernetes_cluster.aks_cluster.kube_config.0.username
  sensitive = true
}

output "cluster_password" {
  value = azurerm_kubernetes_cluster.aks_cluster.kube_config.0.password
  sensitive = true
}


output "cluster_ca_certificate" {
  value = azurerm_kubernetes_cluster.aks_cluster.kube_config.0.cluster_ca_certificate
  sensitive = true
}

output "kube_config" {
  value = [
    {
      host                   = azurerm_kubernetes_cluster.aks_cluster.kube_config.0.host
      client_certificate     = base64decode(azurerm_kubernetes_cluster.aks_cluster.kube_config.0.client_certificate)
      client_key             = base64decode(azurerm_kubernetes_cluster.aks_cluster.kube_config.0.client_key)
      cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks_cluster.kube_config.0.cluster_ca_certificate)
    }
  ]
}




