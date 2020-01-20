variable "location" {
  description = "Azure location"
  default     = "eastus"
}

variable "arm_subscription_id" {
  description = "Azure subscription ID"
}

variable "arm_tenant_id" {
  description = "Azure subscription tenant ID"
}

variable "arm_client_id" {
  description = "Azure application ID"
}

variable "arm_client_secret" {
  description = "Azure application secret"
}

variable "resource_group_name" {
  description = "Azure Resource Group name"
}

variable "network" {
  description = "Map of network properties. Should include 'name', 'cidr' and 'subnet'."
  type        = map(string)

  default = {
    name   = "vault-network"
    cidr   = "10.0.0.0/16"
    subnet = "10.0.2.0/24"
  }
}

variable "dev_admin_user_name" {
  description = "admin user for nat box"
  default     = "devadmin"
}

variable "app_name" {
  description = "Name of the app applied as a prefix"
  default     = "vault"
}

variable "nsg_rules" {
  description = "Protocols to be used for lb rules. lb rule names must match a probe name [frontend_port, protocol, backend_port]"
  type        = map(number)

  default = {
    api         = 8200
    replication = 8201
  }
}

variable "allowed_ssh_cidr_blocks" {
  description = "A list of CIDR-formatted IP address ranges from which the Azure Instances will allow SSH connections"
  type        = list(string)
  default     = ["*"]
}

variable "sig_name" {
  description = "Name of the Shared Image Gallery for your personal sub"
  default     = "infra_testing_demo"
}

