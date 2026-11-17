terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate"
    storage_account_name = "tfstate7920"
    container_name       = "tfstate-azure-env"
    key                  = "azure-env.tfstate"
    use_azuread_auth     = true
    use_oidc             = true
  }
}
