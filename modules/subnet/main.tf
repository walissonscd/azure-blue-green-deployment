resource "azurerm_subnet" "subnet" {
  name                 = var.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = var.subnet_prefixes  # Customize the subnet address space here
}

output "subnet_id" {
  value = azurerm_subnet.subnet.id
}
