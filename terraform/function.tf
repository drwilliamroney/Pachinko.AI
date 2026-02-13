resource "azurerm_function_app_flex_consumption" "runner" {
    name = "airunner"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    service_plan_id = azurerm_service_plan.airunners.id

    storage_container_type = "blobContainer"
    storage_container_endpoint  = "${azurerm_storage_account.sa.primary_blob_endpoint}${azurerm_storage_container.sc.name}"
    storage_authentication_type = "StorageAccountConnectionString"
    storage_access_key          = azurerm_storage_account.sa.primary_access_key
    runtime_name = "python"
    runtime_version = "3.13"
    maximum_instance_count = 40
    instance_memory_in_mb = 2048
    ## zip_deploy_file = ""
    ##app_settings {
    ##   SCM_DO_BUILD_DURING_DEPLOYMENT=true 
    ##}
    site_config {
    }
}