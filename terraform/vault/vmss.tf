resource "azurerm_virtual_machine_scale_set" "vault" {
  count               = var.create_load_balancer ? 1 : 0
  name                = var.vault_cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  upgrade_policy_mode = "Manual"
  overprovision       = var.overprovision

  sku {
    name     = var.vault_instance_size
    tier     = var.instance_tier
    capacity = var.vault_cluster_size
  }

  os_profile {
    computer_name_prefix = "vault-${var.environment}-${random_id.vault_hostname_prefix.hex}"
    admin_username       = var.vault_admin_user_name

    #This password is unimportant as it is disabled below in the os_profile_linux_config
    admin_password = "HJHDrT}`KxxkXn{/de56GU~@bxTYfr9=SJT<d+("
    custom_data    = data.template_file.vault_server_user_data.rendered
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${var.vault_admin_user_name}/.ssh/authorized_keys"
      key_data = var.vault_admin_ssh_key
    }
  }

  network_profile {
    name    = "VaultNetworkProfile"
    primary = true

    ip_configuration {
      name                                   = "VaultIPConfiguration"
      subnet_id                              = data.azurerm_subnet.main.id
      load_balancer_backend_address_pool_ids = azurerm_lb_backend_address_pool.azlb.*.id
      load_balancer_inbound_nat_rules_ids    = azurerm_lb_nat_pool.azlb.*.id
      primary                                = true
    }
  }

  identity {
    type         = "SystemAssigned"
    identity_ids = []
  }

  storage_profile_image_reference {
    id = data.azurerm_shared_image_version.vault.id
  }

  storage_profile_os_disk {
    name              = ""
    caching           = "ReadWrite"
    create_option     = "FromImage"
    os_type           = "Linux"
    managed_disk_type = "Standard_LRS"
  }

  tags = {
    scaleSetName = var.vault_cluster_name
  }
}


resource "random_id" "vault_hostname_prefix" {
  byte_length = 4
}

data "template_file" "vault_server_user_data" {
  template = file("${path.module}/templates/vault-user-data.tpl")

  vars = {
    tenant_id       = var.arm_tenant_id
    subscription_id = var.arm_subscription_id
    client_id       = var.arm_client_id
    client_secret   = var.arm_client_secret
    # If `keyvault_name` is empty, create one. Otherwise, use the existing value
    internal_domain           = var.internal_domain
    workspace_id              = azurerm_log_analytics_workspace.vault.workspace_id
    primary_shared_key        = azurerm_log_analytics_workspace.vault.primary_shared_key
    resource_group_name       = var.resource_group_name
    vault_cluster_name        = var.vault_cluster_name
    user_data_storage_account = var.storage_account_name
  }
}