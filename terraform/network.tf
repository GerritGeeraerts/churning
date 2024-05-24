resource "azurerm_virtual_network" "dev_vnet" {
  name                = "dev-network"
  resource_group_name = azurerm_resource_group.linux_dev_rg.name
  location            = azurerm_resource_group.linux_dev_rg.location
  address_space       = ["10.123.0.0/16"]

  tags = {
    environment = "dev"
  }
}

resource "azurerm_subnet" "dev_subnet" {
  name                 = "subnet1"
  resource_group_name  = azurerm_resource_group.linux_dev_rg.name
  virtual_network_name = azurerm_virtual_network.dev_vnet.name
  address_prefixes     = ["10.123.1.0/24"]
}

resource "azurerm_network_security_group" "dev_nsg" {
  name                = "dev-nsg"
  location            = azurerm_resource_group.linux_dev_rg.location
  resource_group_name = azurerm_resource_group.linux_dev_rg.name
  tags = {
    environment = "dev"
  }
}

resource "azurerm_network_security_rule" "dev_rule" {
  name                        = "dev-rule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.linux_dev_rg.name
  network_security_group_name = azurerm_network_security_group.dev_nsg.name
}

resource "azurerm_subnet_network_security_group_association" "dev_nsga" {
  subnet_id                 = azurerm_subnet.dev_subnet.id
  network_security_group_id = azurerm_network_security_group.dev_nsg.id
}