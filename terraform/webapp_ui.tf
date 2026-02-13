resource "azurerm_service_plan" "ui" {
    name = "${var.APP_NAME}-ui"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    os_type = "Linux"
    sku_name = var.WEBAPP_SKU
}
resource "azurerm_linux_web_app" "ui" {
    name = "${var.APP_NAME}-ui"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    service_plan_id = azurerm_service_plan.ui.id
    identity {
        type = "SystemAssigned"
    }
    site_config {
        always_on = false
        app_command_line = "gunicorn -w 2 -k uvicorn.workers.UvicornWorker -b 0.0.0.0:8000 asgi.app"
        application_stack {
            python_version = "3.13"
        }
    }
    logs {
        application_logs {
            file_system_level = "Verbose"
        }
        http_logs {
            file_system {
                retention_in_days = 7
                retention_in_mb = 25
            }
        }
    }
    app_settings = {
        "SCM_DO_BUILD_DURING_DEPLOYMENT" = 1
    }
}