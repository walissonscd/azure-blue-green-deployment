resource "azurerm_public_ip" "public_ip" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = local.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

output "public_ip_id" {
  value = azurerm_public_ip.public_ip.id
}

output "public_ip_address" {

  value = azurerm_public_ip.public_ip.ip_address
  
}
