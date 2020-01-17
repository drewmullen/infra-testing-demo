resource "azurerm_shared_image_gallery" "main" {
  name                = var.sig_name
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
}

resource "azurerm_shared_image" "vault" {
  name                = "vault"
  gallery_name        = var.sig_name
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  os_type             = "Linux"
  depends_on          = [azurerm_shared_image_gallery.main]

  identifier {
    publisher = "nwi"
    offer     = "demo"
    sku       = "vault"
  }
}

resource "azurerm_shared_image" "runner" {
  name                = "runner"
  gallery_name        = var.sig_name
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  os_type             = "Linux"
  depends_on          = [azurerm_shared_image_gallery.main]

  identifier {
    publisher = "nwi"
    offer     = "demo"
    sku       = "runner"
  }
}
