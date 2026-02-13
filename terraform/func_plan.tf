resource "azurerm_service_plan" "airunners" {
    name = "${var.APP_NAME}-runners"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    sku_name = var.AI_SKU
    os_type = "Linux"
}