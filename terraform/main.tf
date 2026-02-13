terraform {
    required_version = ">= 0.14"
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
            version= "~> 4.49.0"
        }
    }
}

provider "azurerm" {
    tenant_id = var.TENANT_ID
    subscription_id = var.SUBSCRIPTION_ID
    features {}
}