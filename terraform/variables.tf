variable "location" {
  description = "The Azure location where the resources will be created."
  type        = string
  default     = "eastus"
}

variable "linux_dev_rg_name" {
  description = "Name of the resource group for Linux Dev."
  type        = string
  default     = "linuxDev"
}

variable "mlflow_rg_name" {
  description = "Name of the resource group for MLFlow."
  type        = string
  default     = "mlflow-rg"
}

variable "admin_username" {
  description = "Admin username for the Linux VM."
  type        = string
  default     = "adminuser"
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key."
  type        = string
  default     = "~/.ssh/azurekey.pub"
}