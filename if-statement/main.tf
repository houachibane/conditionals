data "azurerm_resource_group" "main" {
  name = "${var.prefix}-resources"
}

# Create virtual network
resource "azurerm_virtual_network" "main" {
  count = var.create_instance ? 1 : 0

  name                = "${var.prefix}-vnet"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]

  tags = {
    studentid   = "${var.prefix}"
    provider    = "terraform"
    environment = "workshop"
  }
}

# Create subnet
resource "azurerm_subnet" "main" {
  count = var.create_instance ? 1 : 0

  name                 = "${var.prefix}-subnet"
  resource_group_name  = data.azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main[0].name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create network interface
resource "azurerm_network_interface" "main" {
  count = var.create_instance ? 1 : 0

  name                = "${var.prefix}-nic"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location

  ip_configuration {
    name                          = "external"
    subnet_id                     = azurerm_subnet.main[0].id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    studentid   = "${var.prefix}"
    provider    = "terraform"
    environment = "workshop"
  }
}

# Create VM
resource "azurerm_linux_virtual_machine" "default" {
  count = var.create_instance ? 1 : 0

  name                  = "my-instance"
  location              = data.azurerm_resource_group.main.location
  resource_group_name   = data.azurerm_resource_group.main.name
  network_interface_ids = [azurerm_network_interface.main[0].id]
  size                  = "Standard_B1s"

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  admin_username                  = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  tags = {
    studentid   = "${var.prefix}"
    provider    = "terraform"
    environment = "workshop"
  }
}