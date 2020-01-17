# Azure load balancer module

resource "random_id" "load_balancer_dns_suffix" {
  byte_length = 8
}

resource "azurerm_public_ip" "azlb" {
  count                        = var.lb_type == "public" && var.create_load_balancer ? 1 : 0
  name                         = "${var.lb_prefix}-publicIP"
  location                     = var.location
  resource_group_name          = var.resource_group_name
  public_ip_address_allocation = var.public_ip_address_allocation
  domain_name_label            = var.public_ip_dns
  tags                         = var.lb_tags
  sku                          = var.vault_lb_sku
}

data "azurerm_public_ip" "azlb" {
  count               = var.lb_type == "public" && var.create_load_balancer ? 1 : 0
  name                = "${var.lb_prefix}-publicIP"
  resource_group_name = var.resource_group_name
  depends_on          = [azurerm_public_ip.azlb]
}

resource "azurerm_lb" "azlb" {
  count               = var.create_load_balancer ? 1 : 0
  name                = "${var.lb_prefix}-lb"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.lb_tags
  sku                 = var.vault_lb_sku

  frontend_ip_configuration {
    name                          = "vault_frontend"
    public_ip_address_id          = var.lb_type == "public" ? join("", azurerm_public_ip.azlb.*.id) : ""
    subnet_id                     = var.lb_type == "private" ? data.azurerm_subnet.main.id : ""
    private_ip_address            = var.frontend_private_ip_address
    private_ip_address_allocation = var.frontend_private_ip_address_allocation
  }
}

resource "azurerm_lb_backend_address_pool" "azlb" {
  count               = var.create_load_balancer ? 1 : 0
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.azlb[0].id
  name                = "${var.lb_prefix}BackEndAddressPool"
}

resource "azurerm_lb_nat_pool" "azlb" {
  count               = var.create_load_balancer && length(var.remote_port) > 0 ? length(var.remote_port) : 0
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.azlb[0].id
  name                = "${var.lb_prefix}NATpool"
  protocol            = "tcp"
  frontend_port_start = 5000
  frontend_port_end = 5000 + element(
    var.remote_port[element(keys(var.remote_port), count.index)],
    2,
  )
  backend_port = element(
    var.remote_port[element(keys(var.remote_port), count.index)],
    1,
  )
  frontend_ip_configuration_name = "vault_frontend"
}

# extraction examples
# vault  = ["*", "https", "8200", "/v1/sys/health"]
# name   = "${element(keys(var.vault_lb_health_probes), count.index)}"
# "https" = "${element(var.vault_lb_health_probes["${element(keys(var.vault_lb_health_probes), count.index)}"], 1)}"
resource "azurerm_lb_probe" "azlb" {
  count               = var.create_load_balancer ? length(var.vault_lb_health_probes) : 0
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.azlb[0].id
  name                = element(keys(var.vault_lb_health_probes), count.index)
  protocol = element(
    var.vault_lb_health_probes[element(keys(var.vault_lb_health_probes), count.index)],
    1,
  )
  port = element(
    var.vault_lb_health_probes[element(keys(var.vault_lb_health_probes), count.index)],
    2,
  )
  interval_in_seconds = var.lb_probe_interval
  number_of_probes    = var.lb_probe_unhealthy_threshold

  # include path value (vault[3] above) when protocol is http or https 
  request_path = lower(
    element(
      var.vault_lb_health_probes[element(keys(var.vault_lb_health_probes), count.index)],
      1,
    ),
    ) != "tcp" ? element(
    var.vault_lb_health_probes[element(keys(var.vault_lb_health_probes), count.index)],
    3,
  ) : ""
}

resource "azurerm_lb_rule" "azlb" {
  count               = var.create_load_balancer ? length(var.vault_lb_rules) : 0
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.azlb[0].id
  name                = element(keys(var.vault_lb_rules), count.index)
  protocol = element(
    var.vault_lb_rules[element(keys(var.vault_lb_rules), count.index)],
    1,
  )
  frontend_port = element(
    var.vault_lb_rules[element(keys(var.vault_lb_rules), count.index)],
    0,
  )
  backend_port = element(
    var.vault_lb_rules[element(keys(var.vault_lb_health_probes), count.index)],
    2,
  )
  frontend_ip_configuration_name = "vault_frontend"
  enable_floating_ip             = false
  backend_address_pool_id        = azurerm_lb_backend_address_pool.azlb[0].id
  idle_timeout_in_minutes        = 5
  probe_id                       = element(azurerm_lb_probe.azlb.*.id, count.index)
  depends_on                     = [azurerm_lb_probe.azlb]
}

output "loadbalancer_private_ip" {
  value = azurerm_lb.azlb[0].private_ip_address
}

