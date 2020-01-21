variable "location" {
  default     = "East US"
  description = "Azure Location"
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

variable "environment" {
  description = "Environment name to use as a prefix for resources. Should look like `stg`,`prd`,`dev`. Use `personal` if in personal subscription."
}

variable "resource_group_name" {
  description = "Azure resource Group"
}

variable "storage_account_name" {
  description = "Storage account which will host the storage devices and containers"
}

variable "vault_image_version" {
  description = "Version of the Vault image in the Image Gallery. Should look like 1.2.3"
}

variable "vault_image_name" {
  description = "Name of the Vault image in the Image Gallery"
  default     = "vault"
}


variable "image_gallery_name" {
  description = "Name of the Shared Image Gallery where the images are stored"
  default     = "nextgen_secrets_management"
}

variable "image_gallery_resource_group" {
  description = "Resource Group where the Shared Image Gallery is located"
}

variable "vault_instance_size" {
  description = "VM size for Vault"
  default     = "Standard_A1_v2"
}



variable "vault_admin_ssh_key" {
  description = "SSH key for Vault administrators"
}

variable "vault_cluster_size" {
  description = "Amount of instances in a Vault cluster"
  default     = 3
}

variable "vault_unseal_secret_name" {
  default     = "vault-unseal"
  description = "This sets the name of the Azure key-vault-key used to store Hashicorp Vault's unseal keys"
}

variable "create_load_balancer" {
  description = "Creates load balancer Vault"
  default     = true
}

variable "internal_domain" {
  type        = string
  default     = "vault.internal"
  description = "This sets the internal domain used for local name resolution"
}

variable "keyvault_name" {
  description = "The name of the Azure key vault. IMPORTANT: Max character limit of 10. Do not end in '-', thats already included. If empty, Terraform will create one automatically"

  default = ""
}

variable "vault_lb_sku" {
  description = "Defines the type of loadbalancer SKU to build. Options: Basic, Standard"
  default     = "Standard"
}

variable "retention_in_days" {
  description = "Time to retain logs, in days."
  type        = string
  default     = "30"
}

variable "vault_cluster_name" {
  description = "Name of the Azure vault scale set resource. If you want to change the default, make sure the Vault PKI is consuming the correct `bound_scale_sets`"
  default     = "vault-cluster"
}

variable "lb_prefix" {
  description = "Prefix for the Vault load balancer. Usually the default is OK, unless you're creating several stacks in the same Resource Group"
  default     = "vault"
}

variable "network" {
  type = map

  default = {
    name                = "vault-network"
    cidr                = "10.0.0.0/16"
    subnet              = "10.0.2.0/24"
    subnet_name         = "subnet1"
    resource_group_name = "drew-rsg"
  }
}

variable "vault_lb_health_probes" {
  description = "Protocols to be used for lb health probes. [frontend_port, protocol, backend_port, request_path (if not tcp)]"
  type        = map

  default = {
    api         = [8200, "http", 8200, "/v1/sys/health?uninitcode=200&performancestandbycode=200&drsecondarycode=200"]
  }
}

variable "vault_lb_rules" {
  description = "Protocols to be used for lb rules. lb rule names must match a probe name [frontend_port, protocol, backend_port]"
  type        = map

  default = {
    api         = [8200, "Tcp", 8200]
  }
}

#### CSR Metadata
variable "conf_country" {
  description = "The two-letter ISO code for the country where your organization is located"
  default     = "US"
}

variable "conf_state" {
  description = "The state where your organization is located. This should not be abbreviated e.g. Sussex, Normandy, New Jersey"
  default     = "Florida"
}

variable "conf_locality" {
  description = "The town/city where your organization is located"
  default     = "Tampa"
}

variable "conf_org" {
  description = "Usually the legal incorporated name of a company and should include any suffixes such as Ltd., Inc., or Corp."
  default     = "PwC"
}

variable "conf_orgunit" {
  description = "The department name / organizational unit"
  default     = "PwCLabs"
}

variable "vault_admin_user_name" {
  description = "The name of the administrator user for each instance in the cluster"
  default     = "vaultadmin"
}

variable "instance_tier" {
  description = "Specifies the tier of virtual machines in a scale set. Possible values, standard or basic."
  default     = "standard"
}

variable "overprovision" {
  description = "Enable or disable Azure overprovisioning of scaleset instances. Warning: we saw issues with raft quorum when enabled ('true') - 4/15/2019. "
  default     = false
}

variable "lb_type" {
  type        = string
  description = "(Optional) Defined if the loadbalancer is private or public"
  default     = "private"
}

variable "lb_probe_unhealthy_threshold" {
  description = "Number of times the load balancer health probe has an unsuccessful attempt before considering the endpoint unhealthy."
  default     = 2
}

variable "lb_probe_interval" {
  description = "Interval in seconds the load balancer health probe rule does a check"
  default     = 5
}

variable "lb_tags" {
  type = map(string)

  default = {
    source = "terraform"
  }
}

variable "remote_port" {
  description = "Protocols to be used for remote vm access. [protocol, backend_port,range].  Frontend port will be automatically generated starting at 50000 and in the output."
  default     = {ssh=["tcp","22","10"]}
}

variable "frontend_private_ip_address" {
  description = "(Optional) Private ip address to assign to frontend. Use it with type = private"
  default     = ""
}

variable "frontend_private_ip_address_allocation" {
  description = "(Optional) Frontend ip allocation type (Static or Dynamic)"
  default     = "Dynamic"
}

variable "public_ip_address_allocation" {
  description = "(Required) Defines how an IP address is assigned. Options are Static or Dynamic."
  default     = "Static"
}

variable "public_ip_dns" {
  description = "Define DNS of public IP Address"
  default     = "azlb"
}

variable "private_dns_record_name_primary" {
  description = "subdomain name for private dns A record. will yield <eastus>.vault.internal. only useful in personal sub (environment = 'personal')"
  default     = "eastus"
}

variable "private_dns_record_name_secondary" {
  description = "subdomain name for private dns A record. will yield <eastus2>.vault.internal. only useful in personal sub (environment = 'personal')"
  default     = "eastus2"
}

variable "private_dns_zone_name" {
  description = "Azure id for your private dns zone. only useful in personal sub (environment = 'personal')"
  default     = "vault.internal"
}

variable "private_dns_record_ip_primary" {
  description = "IP address for DNS record to resolve to. only useful in personal sub (environment = 'personal')"
  default     = "10.0.2.4"
}

variable "private_dns_record_ip_secondary" {
  description = "IP address for DNS record to resolve to. only useful in personal sub (environment = 'personal')"
  default     = "10.1.2.4"
}

variable "build_private_dns_records" {
  description = "Set to 'true' if building the primary cluster for a personal sub. This is a parameter for conditions when build private dns a records for personal subscriptions."
  default     = "false"
}

