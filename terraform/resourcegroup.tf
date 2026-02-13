resource "azurerm_resource_group" "rg" {
    name = var.RESOURCE_GROUP_NAME
    location = var.AZURE_LOCATION
}