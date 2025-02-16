provider "azurerm" {
    subscription_id = "9b35fd22-ce26-4191-b1f8-6f672cdd3350"
    features {
      
    }
}
resource "azurerm_resource_group" "Resources-group" {
  name     = "container"
  location = "central india"
}

resource "azurerm_container_registry" "acr" {
  name                = "containerRegistry675"
  resource_group_name = azurerm_resource_group.Resources-group.name
  location            = azurerm_resource_group.Resources-group.location
  sku                 = "Basic"
  admin_enabled       = false
}

resource "azurerm_kubernetes_cluster" "example" {
  name                = "example-aks1"
  location            = azurerm_resource_group.Resources-group.location
  resource_group_name = azurerm_resource_group.Resources-group.name
  dns_prefix          = "exampleaks1"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
  }
}

output "client_certificate" {
  value     = azurerm_kubernetes_cluster.example.kube_config[0].client_certificate
  sensitive = true
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.example.kube_config_raw

  sensitive = true
}
