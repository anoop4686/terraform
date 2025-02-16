# terraform {
#   backend "azurerm" {
#     resource_group_name  = "superapp"  # Can be passed via `-backend-config=`"resource_group_name=<resource group name>"` in the `init` command.
#     storage_account_name = "terraformstorage8909"  # Can be passed via `-backend-config=`"storage_account_name=<storage account name>"` in the `init` command.
#     container_name       = "terraformbackup"             # Can be passed via `-backend-config=`"container_name=<container name>"` in the `init` command.
#     key                  = "backup"  # Can be passed via `-backend-config=`"key=<blob key name>"` in the `init` command.
#   }
# }
