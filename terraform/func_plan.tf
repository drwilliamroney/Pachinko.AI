resource "azurerm_service_plan" "airunners" {
    name = "pachinkorunners"
    resource_group_name = var.RESOURCE_GROUP_NAME
    location = var.AZURE_LOCATION
    sku_name = "FC1"
    os_type = "Linux"
}