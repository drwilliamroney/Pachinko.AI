resource "azurerm_container_app_environment" "acae" {
    name = "environment"
    resource_group_name = var.RESOURCE_GROUP_NAME
    location = var.AZURE_LOCATION

}