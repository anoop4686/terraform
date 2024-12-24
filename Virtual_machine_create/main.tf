provider "azurerm" {
    subscription_id = "9b35fd22-ce26-4191-b1f8-6f672cdd3350"
    features {

    }
}
resource "azurerm_resource_group" "demo" {
  name     = "automation_demo"
  location = "Central India"
}

resource "azurerm_virtual_network" "demo" {
  name                = "demo-network"
  address_space       = ["192.168.0.0/16"]
  location            = azurerm_resource_group.demo.location
  resource_group_name = azurerm_resource_group.demo.name
}

resource "azurerm_subnet" "demo" {
  name                 = "internal_1"
  resource_group_name  = azurerm_resource_group.demo.name
  virtual_network_name = azurerm_virtual_network.demo.name
  address_prefixes     = ["192.168.1.0/24"]
}

resource "azurerm_subnet" "vm" {
  name                 = "internal_2"
  resource_group_name  = azurerm_resource_group.demo.name
  virtual_network_name = azurerm_virtual_network.demo.name
  address_prefixes     = ["192.168.2.0/24"]
}

resource "azurerm_network_interface" "demo" {
  name                = "demo-nic"
  location            = azurerm_resource_group.demo.location
  resource_group_name = azurerm_resource_group.demo.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.demo.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_public_ip" "demo" {
  name                = "test"
  location            = azurerm_resource_group.demo.location
  resource_group_name = azurerm_resource_group.demo.name
  allocation_method   = "Static"
  tags = {
    environment = "staging"
    name = "ANoop"
  }
}

resource "azurerm_network_security_group" "demo" {
  name                = "acceptanceTestSecurityGroup1"
  location            = azurerm_resource_group.demo.location
  resource_group_name = azurerm_resource_group.demo.name

  security_rule {
    name                       = "Anywhere"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "ssh"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "Production"
  }
}

resource "azurerm_linux_virtual_machine" "demo" {
  name                = "demo-machine"
  resource_group_name = azurerm_resource_group.demo.name
  location            = azurerm_resource_group.demo.location
  size                = "Standard_F2"
  admin_username      = "anoop"
  admin_password      = "anoopmaurya@8898"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.demo.id,
  ]

    tags = {
    environment = "staging"
    name = "ANoop"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

resource "azurerm_storage_account" "demo" {
  name                     = "demostoraccount"
  resource_group_name      = azurerm_resource_group.demo.name
  location                 = azurerm_resource_group.demo.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_storage_container" "demo" {
  name                  = "vhds"
  storage_account_id    = azurerm_storage_account.demo.id
  container_access_type = "private"
}