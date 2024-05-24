output "linux_dev_rg_name" {
  description = "The name of the resource group for Linux Dev."
  value       = azurerm_resource_group.linux_dev_rg.name
}

output "mlflow_rg_name" {
  description = "The name of the resource group for MLFlow."
  value       = azurerm_resource_group.mlflow_rg.name
}

output "linux_vm_public_ip" {
  description = "The public IP address of the Linux VM."
  value       = azurerm_public_ip.dev_ip.ip_address
}