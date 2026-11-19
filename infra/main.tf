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
  prod_network = {
    address_space = ["10.3.0.0/16"]
    subnets = {
      WebSubnet      = "10.3.1.0/24"
      DBSubnet       = "10.3.2.0/24"
      KeyVaultSubnet = "10.3.3.0/24"
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

module "prod" {
  source              = "./modules/spoke"
  subnets             = local.prod_network.subnets
  resource_group_name = azurerm_resource_group.rg["prod"].name
  tags                = merge(var.tags, { environment = "prod" })
  address_space       = local.prod_network.address_space
  location            = var.location
  vnet_name           = "vnet-${var.workload}-prod-${local.region_short[var.location]}"
}

resource "azurerm_virtual_network_peering" "hub_to_dev" {
  name                      = "peer-hub-to-dev"
  resource_group_name       = azurerm_resource_group.rg["hub"].name
  virtual_network_name      = module.hub.vnet_name
  remote_virtual_network_id = module.dev.vnet_id
}

resource "azurerm_virtual_network_peering" "dev_to_hub" {
  name                      = "peer-dev-to-hub"
  resource_group_name       = azurerm_resource_group.rg["dev"].name
  virtual_network_name      = module.dev.vnet_name
  remote_virtual_network_id = module.hub.vnet_id
}

resource "azurerm_virtual_network_peering" "hub_to_prod" {
  name                      = "peer-hub-to-prod"
  resource_group_name       = azurerm_resource_group.rg["hub"].name
  virtual_network_name      = module.hub.vnet_name
  remote_virtual_network_id = module.prod.vnet_id
}

resource "azurerm_virtual_network_peering" "prod_to_hub" {
  name                      = "peer-prod-to-hub"
  resource_group_name       = azurerm_resource_group.rg["prod"].name
  virtual_network_name      = module.prod.vnet_name
  remote_virtual_network_id = module.hub.vnet_id
}
