resource "azurerm_storage_account" "sa" {
    name = var.SA_NAME
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    account_tier = "Standard"
    account_replication_type = "GRS"
}
resource "azurerm_storage_container" "sc" {
    name = "ai-faas"
    storage_account_id = azurerm_storage_account.sa.id
    container_access_type = "private"
}
resource "azurerm_storage_container" "sc-chats" {
    name = "ai-conversations"
    storage_account_id = azurerm_storage_account.sa.id
    container_access_type = "private"
}
resource "azurerm_storage_container" "sc-state" {
    name = "ai-states"
    storage_account_id = azurerm_storage_account.sa.id
    container_access_type = "private"
}
resource "azurerm_storage_queue" "sq" {
    name = "ai-queue"
    storage_account_id = azurerm_storage_account.sa.id
}