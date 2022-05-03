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
  default="../../../build_config"
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

variable "target_scale_set_name" {
  type        = string
  description = ""
}

variable "target_scale_set_rg" {
  type        = string
  description = ""
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
  managed_image_name_linux   = "adolinux-img-${local.location_abbreviations[var.location]}-${var.env}-001"
  managed_image_name_windows = "adowindows-img-${local.location_abbreviations[var.location]}-${var.env}-001"
  blue_green_img_linux       = "linuxbg-img-${local.location_abbreviations[var.location]}-${var.env}-001"
  blue_green_img_windows     = "windowsbg-img-${local.location_abbreviations[var.location]}-${var.env}-001"
}

# source block configures a specific builder plugin, which is then invoked by a build block.
source "azure-arm" "agent-ubuntu" {
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id

  build_resource_group_name = var.resource_group_name
  managed_image_resource_group_name = var.resource_group_name
  managed_image_name                = local.managed_image_name_linux

  os_type         = "Linux"
  image_publisher = "Canonical"
  image_offer     = "0001-com-ubuntu-server-focal"
  image_sku       = "20_04-lts-gen2"

  vm_size  = "Standard_B1s"
}


source "azure-arm" "agent-windows" {
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id

  build_resource_group_name = var.resource_group_name

  managed_image_storage_account_type = "Standard_LRS"
  managed_image_resource_group_name  = var.resource_group_name
  managed_image_name                 = local.managed_image_name_windows

  os_type         = "Windows"
  image_publisher = "MicrosoftWindowsServer"
  image_offer     = "WindowsServer"
  image_sku       = "2022-datacenter"
  image_version   = "20348.587.220303"

  location = "West Europe"
  vm_size  = "Standard_D2_v2"

  communicator   = "winrm"
  winrm_insecure = true
  winrm_username = "packer"
  winrm_use_ssl  = true
}


# The build block defines what Packer should do with the Docker container after it launches.
build {
  name = "learn-packer"
  sources = [
    "source.azure-arm.agent-ubuntu"
  ]

  provisioner "ansible" {
    use_proxy               = false
    playbook_file           = "${var.ansible_playbook_path}/playbook.yaml"
    inventory_directory     = "${var.ansible_playbook_path}/"
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

  post-processor "manifest" {
      output = "manifest-green.json"
      strip_path = true
      custom_data = {
          source_image_name = "${build.SourceImageName}"
          target_vmss_name = "${var.target_scale_set_name}"
          target_vmss_rg = "${var.target_scale_set_rg}"
      }
  }
}