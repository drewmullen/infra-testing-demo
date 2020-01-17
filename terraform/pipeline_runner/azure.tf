provider "azurerm" {
  version         = "<= 1.34.0"
  subscription_id = var.arm_subscription_id
  tenant_id       = var.arm_tenant_id
  client_id       = var.arm_client_id
  client_secret   = var.arm_client_secret
}

provider "azurerm" {
  alias           = "sig_provider"
  version         = "<= 1.34.0"
  subscription_id = var.sig_subscription_id
  tenant_id       = var.arm_tenant_id
  client_id       = var.arm_client_id
  client_secret   = var.arm_client_secret
}

provider "azuread" {
  version = "<= 0.6.0"
}

