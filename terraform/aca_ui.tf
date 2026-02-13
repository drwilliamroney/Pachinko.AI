resource "azurerm_container_app" "ui" {
    name = "ui"
    container_app_environment_id = azurerm_container_app_environment.acae.id
    resource_group_name = var.RESOURCE_GROUP_NAME
    revision_mode = "Single"
    template {
        container {
            name = "ui"
            image = "docker.io/hashicorp/http-echo:latest"
            args = ["--text='hello from ui'"]
            cpu = 0.25
            memory = "0.5Gi"
        }
    }
    ingress {
        external_enabled = true
        target_port = 5678
        transport = "http"
        traffic_weight {
            latest_revision = true
            percentage = 100
        }
    }
}