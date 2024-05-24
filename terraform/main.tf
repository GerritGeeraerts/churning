terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }
  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "linux_dev_rg" {
  name     = var.linux_dev_rg_name
  location = var.location
  tags = {
    environment = "dev"
  }
}

resource "azurerm_resource_group" "mlflow_rg" {
  name     = var.mlflow_rg_name
  location = var.location
}