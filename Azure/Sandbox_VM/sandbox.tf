variable "subscription_id" { 
  default = "9b35fd22-ce26-4191-b1f8-6f672cdd3350" 
  }

variable "resource_group_name" { 
  default = "Terraform" 
  }

variable "location" { 
  default = "Central India" 
  }

variable "virtual_network_name" { 
  default = "Terraform_Vnet" 
  }

variable "subnet_name" { 
  default = "Terraform_subnet" 
  }

variable "vm_name" { 
  default = "sandbox-01" 
  }

variable "vm_user_name" { 
  default = "anoop" 
  }

variable "vm_password" { 
  default = "Welcome@123" 
  }

variable "disk_type" { 
  default = "StandardSSD_LRS" 
  }

variable "disk_size" { 
  default = 64 
  }

variable "vm_size" { 
  default = "Standard_DS1_v2" 
  }

variable "tags" {
  default = {
    Project     = "Sandbox"
    Owner       = "Anoop"
    Co-Owner    = "Nisha"
    Environment = "Virtual Machine"
  }
}

provider "azurerm" {
  subscription_id = var.subscription_id
  features {}
}

data "azurerm_virtual_network" "existing_vnet" {
  name                = var.virtual_network_name
  resource_group_name = var.resource_group_name
}

data "azurerm_subnet" "existing_subnet" {
  name                 = var.subnet_name
  virtual_network_name = var.virtual_network_name
  resource_group_name  = var.resource_group_name
}

resource "azurerm_managed_disk" "disk" {
  name                 = "${var.vm_name}-disk"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = var.disk_type
  create_option        = "Empty"
  disk_size_gb         = var.disk_size
  tags                 = var.tags
}

resource "azurerm_linux_virtual_machine" "virtual_machine" {
  name                  = var.vm_name
  location              = var.location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.new_nic.id]
  size                  = var.vm_size

  priority        = "Spot"
  eviction_policy = "Deallocate"
  max_bid_price   = 0.20

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.disk_type
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  computer_name  = var.vm_name
  admin_username = var.vm_user_name
  admin_password = var.vm_password

  disable_password_authentication = false
  tags                             = var.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "data_disk" {
  managed_disk_id    = azurerm_managed_disk.disk.id
  virtual_machine_id = azurerm_linux_virtual_machine.virtual_machine.id
  lun                = 0
  caching            = "ReadWrite"
}

resource "azurerm_network_interface" "new_nic" {
  name                = "${var.vm_name}-nic-card"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.existing_subnet.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.tags
}
