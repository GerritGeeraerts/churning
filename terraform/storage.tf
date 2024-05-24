resource "azurerm_storage_account" "mlflow_storage" {
  name                     = "mlflowstoracc"
  resource_group_name      = azurerm_resource_group.mlflow_rg.name
  location                 = azurerm_resource_group.mlflow_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_data_lake_gen2_filesystem" "example" {
  name               = "data-lake-gen2-filesystem"
  storage_account_id = azurerm_storage_account.mlflow_storage.id
  properties = {
    hello = "aGVsbG8="
  }
}

resource "null_resource" "upload_file" {
  provisioner "local-exec" {
    command = <<EOT
      az storage fs file upload --account-name ${azurerm_storage_account.mlflow_storage.name} \
        --file-system ${azurerm_storage_data_lake_gen2_filesystem.example.name} \
        --path bank_churners.csv \
        --source /home/gg/PycharmProjects/churning/data/raw/bank_churners.csv
    EOT
  }

  depends_on = [azurerm_storage_data_lake_gen2_filesystem.example]
}