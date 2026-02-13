resource "azurerm_resource_group" "rg" {
    name = var.APP_NAME
    location = var.AZURE_LOCATION
}