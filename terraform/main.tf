# Configure the Azure provider
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

resource "azurerm_resource_group" "rg" {
  name     = "mlflow-rg"
  location = "westeurope"
}

resource "azurerm_storage_account" "example" {
  name                     = "mlflowstoracc"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_data_lake_gen2_filesystem" "example" {
  name               = "data-lake-gen2-filesystem"
  storage_account_id = azurerm_storage_account.example.id

  properties = {
    hello = "aGVsbG8="
  }
}

resource "null_resource" "upload_file" {
  provisioner "local-exec" {
    command = <<EOT
      az storage fs file upload --account-name ${azurerm_storage_account.example.name} \
        --file-system ${azurerm_storage_data_lake_gen2_filesystem.example.name} \
        --path bank_churners.csv \
        --source /home/gg/PycharmProjects/churning2/data/raw/bank_churners.csv
    EOT
    # --source ../data/raw/bank_churners.csv
  }

  depends_on = [
    azurerm_storage_data_lake_gen2_filesystem.example
  ]
}
