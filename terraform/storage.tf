resource "azurerm_storage_account" "sa" {
    name = var.SA_NAME
    resource_group_name = var.RESOURCE_GROUP_NAME
    location = var.AZURE_LOCATION
    account_tier = "Standard"
    account_replication_type = "GRS"
}
resource "azurerm_storage_container" "sc" {
    name = "data"
    storage_account_id = azurerm_storage_account.sa.id
    container_access_type = "private"
}