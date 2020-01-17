provider "azurerm" {
  version         = ">=1.34.0"
  subscription_id = var.arm_subscription_id
  tenant_id       = var.arm_tenant_id
  client_id       = var.arm_client_id
  client_secret   = var.arm_client_secret
}

terraform {
  backend "azurerm" {
  }
}

