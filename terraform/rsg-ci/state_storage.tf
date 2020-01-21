resource "azurerm_storage_account" "main" {
  name                     = var.tfstate_storage_account_name
  location                 = var.location
  resource_group_name      = var.resource_group_name
  account_tier             = "Standard"
  account_replication_type = "GRS"

  depends_on = [azurerm_resource_group.main]
}

resource "azurerm_storage_container" "main" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}

