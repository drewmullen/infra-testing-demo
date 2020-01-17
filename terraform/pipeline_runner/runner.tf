data "azurerm_subnet" "main" {
  name                 = var.network["subnet_name"]
  virtual_network_name = var.network["name"]
  resource_group_name  = var.network["resource_group_name"]
}

resource "azurerm_network_interface" "runner" {
  name     = "${var.runner_prefix}-nic"
  location = var.location

  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "${var.runner_prefix}-ip-config"
    subnet_id                     = data.azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
  }
}

data "azurerm_shared_image_version" "runner" {
  provider            = azurerm.sig_provider
  name                = var.runner_image_version
  image_name          = var.runner_image_name
  gallery_name        = var.image_gallery_name
  resource_group_name = var.image_gallery_resource_group
}

resource "azurerm_virtual_machine" "runner" {
  name                  = "${var.runner_prefix}-vm"
  location              = var.location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.runner.id]
  vm_size               = var.runner_instance_size

  delete_os_disk_on_termination = true

  delete_data_disks_on_termination = true

  identity {
    type = "SystemAssigned"
  }

  storage_image_reference {
    id = data.azurerm_shared_image_version.runner.id
  }

  storage_os_disk {
    name              = "${var.runner_prefix}-os-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    os_type           = "Linux"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = var.runner_prefix
    admin_username = var.runner_admin_user_name

    #This password is unimportant as it is disabled below in the os_profile_linux_config
    admin_password = "HJHDrT}`KxxkXn{/de56U~@bxTYfr9=SJT<d+("
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${var.runner_admin_user_name}/.ssh/authorized_keys"
      key_data = var.vault_admin_ssh_key
    }
  }
}

