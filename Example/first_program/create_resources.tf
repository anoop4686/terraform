# az account list : Shows account information

provider "azurerm" {
    subscription_id = "9b35fd22-ce26-4191-b1f8-6f672cdd3350"
    features {

    }
}

resource "azurerm_resource_group" "name" {
  name     = "terrafrom_script"
  location = "West Europe"
}
output "name" {
    value = "Hello"
}
