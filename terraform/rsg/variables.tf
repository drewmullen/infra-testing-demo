variable "location" {
  description = "Azure location"
  default     = "East US"
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

variable "sig_name" {
  description = "Name of the Shared Image Gallery for your personal sub"
  default     = "infra_testing_demo"
}

variable "tfstate_storage_account_name" {
  description = "Azure Storage account name. WARNING: this should be globally unique so make sure it's not something generic."
}

