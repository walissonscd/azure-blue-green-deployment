resource "random_pet" "rg_name" {
}

# Create the resource group
resource "azurerm_resource_group" "rg" {
  name     = "RG-${random_pet.rg_name.id}"
  location = local.location
}

resource "random_pet" "vnet_name" {
}

# Create the virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "VNET-${random_pet.vnet_name.id}"
  location            = local.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = [local.vnet_address_space]
  depends_on = [azurerm_resource_group.rg]
}

# Define the two subnets
module "subnet1" {
  source              = "./modules/subnet"
  name                = "subnet1"
  resource_group_name = azurerm_resource_group.rg.name
  vnet_name           = azurerm_virtual_network.vnet.name
  vnet_id             = azurerm_virtual_network.vnet.id
  subnet_prefixes       = ["10.0.1.0/24"]
  depends_on          = [azurerm_resource_group.rg, azurerm_virtual_network.vnet]
}

module "subnet2" {
  source              = "./modules/subnet"
  name                = "subnet2"
  resource_group_name = azurerm_resource_group.rg.name
  vnet_name           = azurerm_virtual_network.vnet.name
  vnet_id             = azurerm_virtual_network.vnet.id
  subnet_prefixes       = ["10.0.2.0/24"]
  depends_on          = [azurerm_resource_group.rg, azurerm_virtual_network.vnet]
}


module "subnet3" {
  source              = "./modules/subnet"
  name                = "subnet3"
  resource_group_name = azurerm_resource_group.rg.name
  vnet_name           = azurerm_virtual_network.vnet.name
  vnet_id             = azurerm_virtual_network.vnet.id
  subnet_prefixes       = ["10.0.3.0/24"]
  depends_on          = [azurerm_resource_group.rg, azurerm_virtual_network.vnet]
}


resource "random_pet" "blue_green_name" {
}

# Create the Public IP address for the Application Gateway
module "public_ip_1" {
  source               = "./modules/public_ip"
  name                 = "pip-appgw-${random_pet.blue_green_name.id}"
  resource_group_name  = azurerm_resource_group.rg.name
  depends_on           = [azurerm_resource_group.rg]
}

# Create the Application Gateway
module "application_gateway_1" {
  source               = "./modules/app_gw"
  name                 = "appgw-${random_pet.blue_green_name.id}"
  resource_group_name  = azurerm_resource_group.rg.name
  subnet_id            = module.subnet3.subnet_id
  public_ip_id         = module.public_ip_1.public_ip_id
  depends_on           = [azurerm_resource_group.rg, module.subnet3, module.public_ip_1]
}



# Create the managed identities
resource "azurerm_user_assigned_identity" "aks_cluster_identity" {
  name                  = "MI-AKS-${random_pet.blue_green_name.id}"
  location              = local.location
  resource_group_name   = azurerm_resource_group.rg.name
  depends_on            = [azurerm_resource_group.rg]
}

resource "random_pet" "aks_name_1" {
}

# Create the AKS clusters
module "aks_cluster1" {
  source               = "./modules/aks_cluster"
  cluster_name         = "AKS-${random_pet.aks_name_1.id}"
  resource_group_name  = azurerm_resource_group.rg.name
  managed_identity     = azurerm_user_assigned_identity.aks_cluster_identity.id
  gateway_id = module.application_gateway_1.gateway_id
  vnet_subnet_id       = module.subnet1.subnet_id
  depends_on           = [
    azurerm_resource_group.rg,
    azurerm_user_assigned_identity.aks_cluster_identity,
    module.subnet1,
    module.application_gateway_1
  ]
}

resource "random_pet" "aks_name_2" {
}

module "aks_cluster2" {
  source               = "./modules/aks_cluster"
  cluster_name         = "AKS-${random_pet.aks_name_2.id}"
  resource_group_name  = azurerm_resource_group.rg.name
  managed_identity     = azurerm_user_assigned_identity.aks_cluster_identity.id
  gateway_id = module.application_gateway_1.gateway_id
  vnet_subnet_id       = module.subnet2.subnet_id
  depends_on           = [
    azurerm_resource_group.rg,
    azurerm_user_assigned_identity.aks_cluster_identity,
    module.subnet2,
    module.application_gateway_1
  ]
}

resource "azurerm_role_assignment" "agic_appgw_aks_1" {
  scope                = module.application_gateway_1.gateway_id
  role_definition_name = "Contributor"
  principal_id         = module.aks_cluster1.agic_id
}

resource "azurerm_role_assignment" "aks-to-vnet" {
  scope                = azurerm_virtual_network.vnet.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_cluster_identity.principal_id 
}

resource "azurerm_role_assignment" "agic_appgw_aks_2" {
  scope                = module.application_gateway_1.gateway_id
  role_definition_name = "Contributor"
  principal_id         = module.aks_cluster2.agic_id
}

output "public_ip" {
  value = module.public_ip_1.public_ip_address
}
