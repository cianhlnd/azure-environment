locals {
  environments = ["hub", "dev", "prod"]
  region_short = {
    northeurope   = "neu"
    westeurope    = "weu"
    swedencentral = "sdc"
  }
}

resource "azurerm_resource_group" "rg" {
  for_each = toset(local.environments)
  name     = "rg-${var.workload}-${each.key}-${local.region_short[var.location]}"
  location = var.location
  tags     = merge(var.tags, { environment = each.key })
}
