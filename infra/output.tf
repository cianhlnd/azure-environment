output "resource_group_names" {
  description = "Resource group names, by environment"
  value       = { for env, rg in azurerm_resource_group.rg : env => rg.name }
}