packer {
  required_plugins {
    azure-rm = {
      version = ">= 1.0.6"
      source  = "github.com/hashicorp/azure"
    }
  }
}

variable "client_id" {
  type        = string
  description = "Specifies the service principal client-id"
}

variable "client_secret" {
  type        = string
  description = "Specifies the service principal secret"
  sensitive   = true
}

variable "tenant_id" {
  type        = string
  description = "Specifies the Azure tenant id"
}

variable "subscription_id" {
  type        = string
  description = "Specifies the Azure subscription id where image should be saved"
  sensitive   = true
}

variable "location" {
  type        = string
  default     = "westeurope"
  description = "Specifies in what region the image(s) is saved"
}

variable "resource_group_name" {
  type        = string
  description = "Specifies the resource group name used where image is saved"
}

variable "env" {
  type        = string
  description = "Specifies the lifecycle notation used in image name"

  validation {
    condition     = can(regex("dev|test|qa|prod|uat|lab", var.env))
    error_message = "The env variable does not match regex."
  }
}

locals {
  location_abbreviations = {
    "westeurope"  = "weeu",
    "northeurope" = "noeu",
    "westus"      = "weus",
    "westus"      = "weus"
  }
}

# source block configures a specific builder plugin, which is then invoked by a build block.
source "azure-arm" "agent-ubuntu" {
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id

  managed_image_resource_group_name = var.resource_group_name
  managed_image_name                = "adolinux-img-${local.location_abbreviations[var.location]}-${var.env}-001"

  os_type         = "Linux"
  image_publisher = "Canonical"
  image_offer     = "UbuntuServer"
  image_sku       = "18.04-LTS"

  location = "West Europe"
  vm_size  = "Standard_B1s"
}

// source "azure-arm" "agent-windows" {
//   client_id       = var.client_id
//   client_secret   = var.client_secret
//   tenant_id       = var.tenant_id
//   subscription_id = var.subscription_id

//   managed_image_storage_account_type = "Standard_LRS"
//   managed_image_resource_group_name  = "ben-packer-weeu-lab-001"
//   managed_image_name                 = "adowindows-img-weeu-lab-003"


//   os_type         = "Windows"
//   image_publisher = "MicrosoftWindowsServer"
//   image_offer     = "WindowsServer"
//   image_sku       = "2022-datacenter"
//   image_version   = "20348.587.220303"

//   location = "West Europe"
//   vm_size  = "Standard_D2_v2"

//   communicator   = "winrm"
//   winrm_insecure = true
//   winrm_username = "packer"
//   winrm_use_ssl  = true
// }

# The build block defines what Packer should do with the Docker container after it launches.
build {
  name = "learn-packer"
  sources = [
    "source.azure-arm.agent-ubuntu"
  ]
  // sources = [
  //   "source.azure-arm.agent-ubuntu",
  //   "source.azure-arm.agent-windows"
  // ]

  provisioner "ansible" {
    use_proxy               = false
    playbook_file           = "ansible/playbook.yaml"
    inventory_directory     = "ansible/"
    inventory_file_template = "{{ .HostAlias }} ansible_host={{ .Host }} ansible_user={{ .User }} ansible_port={{ .Port }} ansible_become=true"
    only                    = ["azure-arm.agent-ubuntu"]
  }

  // provisioner "ansible" {
  //   playbook_file   = "ansible/playbook.yaml"
  //   user            = "Administrator"
  //   use_proxy       = false
  //   extra_arguments = [
  //     "-e",
  //     "ansible_winrm_server_cert_validation=ignore"
  //   ]

  //   only = ["azure-arm.agent-windows"]
  // }
}

