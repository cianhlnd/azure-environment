locals {
  environments = ["hub", "dev", "prod"]
  region_short = {
    northeurope   = "neu"
    westeurope    = "weu"
    swedencentral = "sdc"
  }
  hub_network = {
    address_space = ["10.1.0.0/16"]
    subnets = {
      HubVMSubnet        = "10.1.1.0/24"
      AzureBastionSubnet = "10.1.2.0/26"
      GatewaySubnet      = "10.1.3.0/27"
    }
  }
  dev_network = {
    address_space = ["10.2.0.0/16"]
    subnets = {
      WebSubnet      = "10.2.1.0/24"
      DBSubnet       = "10.2.2.0/24"
      KeyVaultSubnet = "10.2.3.0/24"
    }
  }
}

resource "azurerm_resource_group" "rg" {
  for_each = toset(local.environments)
  name     = "rg-${var.workload}-${each.key}-${local.region_short[var.location]}"
  location = var.location
  tags     = merge(var.tags, { environment = each.key })
}

module "hub" {
  source              = "./modules/hub"
  subnets             = local.hub_network.subnets
  resource_group_name = azurerm_resource_group.rg["hub"].name
  tags                = merge(var.tags, { environment = "hub" })
  address_space       = local.hub_network.address_space
  location            = var.location
  vnet_name           = "vnet-${var.workload}-hub-${local.region_short[var.location]}"
}

module "dev" {
  source              = "./modules/spoke"
  subnets             = local.dev_network.subnets
  resource_group_name = azurerm_resource_group.rg["dev"].name
  tags                = merge(var.tags, { environment = "dev" })
  address_space       = local.dev_network.address_space
  location            = var.location
  vnet_name           = "vnet-${var.workload}-dev-${local.region_short[var.location]}"
}
