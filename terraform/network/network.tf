data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

resource "azurerm_virtual_network" "main" {
  name                = var.network["name"]
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
  # force an interpolation expression to be interpreted as a list by wrapping it
  # in an extra set of list brackets. That form was supported for compatibility in
  # v0.11, but is no longer supported in Terraform v0.12.
  #
  # If the expression in the following list itself returns a list, remove the
  # brackets to avoid interpretation as a list of lists. If the expression
  # returns a single list item then leave it as-is and remove this TODO comment.
  address_space = [var.network["cidr"]]
}

resource "azurerm_subnet" "main" {
  name                 = "subnet1"
  resource_group_name  = data.azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefix       = var.network["subnet"]
}

resource "azurerm_network_security_group" "main" {
  name                = "${var.app_name}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
}

# nsg_rules example { api = 8200,  }
resource "azurerm_network_security_rule" "main" {
  count                       = length(var.nsg_rules)
  name                        = "${var.app_name}-${element(keys(var.nsg_rules), count.index)}"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.main.name

  access                     = "Allow"
  direction                  = "Inbound"
  source_port_range          = "*"
  source_address_prefix      = "*"
  destination_port_range     = element(values(var.nsg_rules), count.index)
  destination_address_prefix = "*"
  protocol                   = "Tcp"
  priority                   = 100 + count.index
}

resource "azurerm_network_security_rule" "ssh" {
  count = length(var.allowed_ssh_cidr_blocks)

  access                      = "Allow"
  destination_address_prefix  = "*"
  destination_port_range      = "22"
  direction                   = "Inbound"
  name                        = "SSH${count.index}"
  network_security_group_name = azurerm_network_security_group.main.name
  priority                    = 200 + count.index
  protocol                    = "Tcp"
  resource_group_name         = var.resource_group_name
  source_address_prefix       = element(var.allowed_ssh_cidr_blocks, count.index)
  source_port_range           = "1024-65535"
}

resource "azurerm_subnet_network_security_group_association" "main" {
  # the association is only necessary when creating a standard LB
  subnet_id = azurerm_subnet.main.id

  network_security_group_id = azurerm_network_security_group.main.id
}

