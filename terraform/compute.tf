resource "azurerm_public_ip" "dev_ip" {
  name                = "dev-ip"
  resource_group_name = azurerm_resource_group.linux_dev_rg.name
  location            = azurerm_resource_group.linux_dev_rg.location
  allocation_method   = "Dynamic"

  tags = {
    environment = "dev"
  }
}

resource "azurerm_network_interface" "dev_nic" {
  name                = "dev-nic"
  location            = azurerm_resource_group.linux_dev_rg.location
  resource_group_name = azurerm_resource_group.linux_dev_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.dev_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.dev_ip.id
  }
  tags = {
    environment = "dev"
  }
}

resource "azurerm_linux_virtual_machine" "dev_vm" {
  name                  = "dev-vm"
  resource_group_name   = azurerm_resource_group.linux_dev_rg.name
  location              = azurerm_resource_group.linux_dev_rg.location
  size                  = "Standard_B1s"
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.dev_nic.id]
  custom_data           = filebase64("${path.module}/customdata.tpl")

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    offer     = "0001-com-ubuntu-server-jammy"
    publisher = "canonical"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}
