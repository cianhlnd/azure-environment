output "vnet_id" {
  value       = azurerm_virtual_network.vnet.id
  description = "ID of the spoke vnet"
}

output "vnet_name" {
  value       = azurerm_virtual_network.vnet.name
  description = "Name of the spoke vnet"
}

output "subnet_ids" {
  description = "Subnet IDs for each subnet created in main.tf"
  value       = { for name, subnets in azurerm_subnet.subnets : name => subnets.id }
}
