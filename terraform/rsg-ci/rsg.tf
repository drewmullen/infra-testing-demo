resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

provider "azurerm" {
  version         = ">=1.30.0"
  subscription_id = var.arm_subscription_id
  tenant_id       = var.arm_tenant_id
  client_id       = var.arm_client_id
  client_secret   = var.arm_client_secret
}

