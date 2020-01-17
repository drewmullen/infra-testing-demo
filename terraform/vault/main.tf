data "azurerm_subnet" "main" {
  name                 = var.network["subnet_name"]
  virtual_network_name = var.network["name"]
  resource_group_name  = var.network["resource_group_name"]
}

#-------------------------
# VM Image datasources
#-------------------------

data "azurerm_shared_image_version" "vault" {
  name                = var.vault_image_version
  image_name          = var.vault_image_name
  gallery_name        = var.image_gallery_name
  resource_group_name = var.image_gallery_resource_group
}

#-------------------------
# Azure Monitor Log Analytics Workspace
#-------------------------

resource "random_id" "log_analytics_workspace" {
  byte_length = 4
}

resource "azurerm_log_analytics_workspace" "vault" {
  name                = "${var.vault_cluster_name}-${random_id.log_analytics_workspace.hex}-log-analytics-workspace"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.retention_in_days
}

