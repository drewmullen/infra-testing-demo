variable "runner_admin_user_name" {
  description = "The name of the administrator user for the runner instance"
  default     = "runneradmin"
}

variable "arm_subscription_id" {
  description = "The Azure subscription ID"
}

variable "sig_subscription_id" {
  description = "The Azure subscription ID where the Shared Image Gallery is hosted"
}

variable "arm_tenant_id" {
  description = "Azure tenant ID"
}

variable "arm_client_id" {
  description = "Azure application client ID"
}

variable "arm_client_secret" {
  description = "Azure application secret"
}

variable "runner_instance_size" {
  description = "The size of the runner Azure Instance"
  default     = "Standard_DS2_v2"
}

variable "runner_prefix" {
  default = "runner"
}

variable "dev_admin_user_name" {
  description = "The admin user for the dev/runner VM to SSH into the runner"
  default     = "devadmin"
}

variable "overprovision" {
  description = "Enable or disable Azure overprovisioning of scaleset instances. Warning: we saw issues with raft quorum when enabled ('true') - 4/15/2019. "
  default     = false
}

variable "location" {
  default = "East US"
}

variable "network" {
  description = "Map of network properties. Should include 'name', 'cidr' and 'subnet'."
  type        = map(string)

  default = {
    name                = "vault-network"
    cidr                = "10.0.0.0/16"
    subnet              = "10.0.2.0/24"
    subnet_name         = "subnet1"
    resource_group_name = ""
  }
}

variable "resource_group_name" {
}

variable "vault_admin_ssh_key" {
}

variable "runner_image_version" {
  default = "0.0.1"
}

variable "runner_image_name" {
  default = "runner"
}

variable "image_gallery_name" {
  default = "infra_testing_demo"
}

variable "image_gallery_resource_group" {
  default = ""
}

