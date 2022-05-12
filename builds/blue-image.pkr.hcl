packer {
  required_plugins {
    azure-rm = {
      version = ">= 1.0.6"
      source  = "github.com/hashicorp/azure"
    }
  }
}

variable "ansible_playbook_path" {
  type = string
  description = "Specifies where ansible playbooks are located"
  default="../../build_config"
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

locals {
  location_abbreviations = {
    "westeurope"  = "weeu",
    "northeurope" = "noeu",
    "westus"      = "weus",
    "westus"      = "weus"
  }
  blue_img_linux       = "linuxbg-img-${local.location_abbreviations["westeurope"]}-dev-001"
  blue_img_windows     = "windowsbg-img-${local.location_abbreviations["westeurope"]}-dev-001"
}

# source block configures a specific builder plugin, which is then invoked by a build block.

source "azure-arm" "agent-ubuntu-blue" {
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
  build_resource_group_name = "ben-packer-weeu-lab-001"
  managed_image_resource_group_name  = "ben-packer-weeu-lab-001"
  managed_image_name                 = local.blue_img_linux
  managed_image_storage_account_type = "Standard_LRS"
  os_type         = "Linux"
  image_publisher = "Canonical"
  image_offer     = "0001-com-ubuntu-server-focal"
  image_sku       = "20_04-lts-gen2"
  vm_size  = "Standard_B1s"
}

source "azure-arm" "agent-windows-blue" {
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
  build_resource_group_name = "ben-packer-weeu-lab-001"
  managed_image_resource_group_name  = "ben-packer-weeu-lab-001"
  managed_image_name                 = local.blue_img_windows
  managed_image_storage_account_type = "Standard_LRS"
  os_type         = "Windows"
  image_publisher = "MicrosoftWindowsServer"
  image_offer     = "WindowsServer"
  image_sku       = "2022-datacenter"
  vm_size         = "Standard_B1s"
  communicator   = "winrm"
  winrm_insecure = true
  winrm_username = "packer"
  winrm_use_ssl  = true
}


# The build block defines what Packer should do with the Docker container after it launches.
build {
  name = "self-hosted-build-agents"
  sources = ["source.azure-arm.agent-ubuntu-blue","source.azure-arm.agent-windows-blue",]

  post-processor "manifest" {
      output = "manifest-blue.json"
      strip_path = true
      custom_data = {
          source_image_name = "${build.SourceImageName}"
          target_vmss_name = ""
          target_vmss_rg = ""
      }
  }
}