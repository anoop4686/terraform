provider "azurerm" {
    subscription_id = "9b35fd22-ce26-4191-b1f8-6f672cdd3350"
    features {
      
    }
  
}
resource "azurerm_resource_group" "Resorces_group" {
  name     = "superapp"
  location = "Central India"
}

output "Resource_name" {
  value = azurerm_resource_group.Resorces_group.id
}

resource "azurerm_virtual_network" "Vnet" {
  name                = "Production"
  address_space       = ["192.168.0.0/16"]
  location            = azurerm_resource_group.Resorces_group.location
  resource_group_name = azurerm_resource_group.Resorces_group.name
}

resource "azurerm_subnet" "Subnet" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.Resorces_group.name
  virtual_network_name = azurerm_virtual_network.Vnet.name
  address_prefixes     = ["192.168.1.0/24"]
}

resource "azurerm_subnet" "Subnet_2" {
  name                 = "internal_2"
  resource_group_name  = azurerm_resource_group.Resorces_group.name
  virtual_network_name = azurerm_virtual_network.Vnet.name
  address_prefixes     = ["192.168.2.0/24"]
}

resource "azurerm_network_interface" "Nic_card" {
  name                = "Production"
  location            = azurerm_resource_group.Resorces_group.location
  resource_group_name = azurerm_resource_group.Resorces_group.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.Subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "VM" {
  name                = "VM1"
  resource_group_name = azurerm_resource_group.Resorces_group.name
  location            = azurerm_resource_group.Resorces_group.location
  size                = "Standard_F2s_v2"
  admin_username      = "anoop"
  admin_password      =  "Anoopmaurya@123"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.Nic_card.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}

output "VM_info" {
    value = azurerm_linux_virtual_machine.VM.virtual_machine_id    
}

resource "azurerm_storage_account" "Storage" {
  name                     = "terraformstorage890s9"
  resource_group_name      = azurerm_resource_group.Resorces_group.name
  location                 = azurerm_resource_group.Resorces_group.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "Conatiner" {
  name                  = "terraformbackup"
  storage_account_id    = azurerm_storage_account.Storage.id
  container_access_type = "private"
}
