provider "azurerm" {
    subscription_id = "9b35fd22-ce26-4191-b1f8-6f672cdd3350"
    features {
      
    }
  
}
resource "azurerm_resource_group" "Resorces_group" {
  name     = "Terraform"
  location = "Central India"
}

resource "azurerm_availability_set" "avset" {
  name                = "production"
  location            = azurerm_resource_group.Resorces_group.location
  resource_group_name = azurerm_resource_group.Resorces_group.name
  managed             = true
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
  count = 2  
  name                = "Production_${count.index + 1}"
  location            = azurerm_resource_group.Resorces_group.location
  resource_group_name = azurerm_resource_group.Resorces_group.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.Subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# resource "azurerm_public_ip" "public_ip" {
#   count = 2  
#   name                = "IP-${count.index + 1}"
#   resource_group_name = azurerm_resource_group.Resorces_group.name
#   location            =azurerm_resource_group.Resorces_group.location
#   allocation_method   = "Static"

#   tags = {
#     environment = "Production"
#   }
# }
resource "azurerm_linux_virtual_machine" "VM" {
  count = 2  
  name                = "VM-${count.index + 1}"
  resource_group_name = azurerm_resource_group.Resorces_group.name
  location            = azurerm_resource_group.Resorces_group.location
  size                = "Standard_F2s_v2"
  admin_username      = "anoop"
  admin_password      =  "Anoopmaurya@123"
  disable_password_authentication = false
  availability_set_id = azurerm_availability_set.avset.id

  network_interface_ids = [
   azurerm_network_interface.Nic_card[count.index].id,
    
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

  custom_data = base64encode(<<EOF
        !# /bin/bash
        sudo apt update -y
        sudo apt install apache2 -y 
        sudo systemctl enable apache2
        sudo systemctl restart apache2 |"
        EOF
)


}

resource "azurerm_storage_account" "Storage" {
  name                     = "terraformstorage8909"
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

resource "azurerm_network_security_group" "nsg" {
  name                = "Terraform-NSG"
  location            = azurerm_resource_group.Resorces_group.location
  resource_group_name = azurerm_resource_group.Resorces_group.name

  security_rule {
    name                       = "HTTPS"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
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

resource "azurerm_subnet_network_security_group_association" "nsg_associate" {
  subnet_id                 = azurerm_subnet.Subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
