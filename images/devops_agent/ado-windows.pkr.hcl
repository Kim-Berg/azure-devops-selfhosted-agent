# block contains Packer settings, including specifying a required Packer version.
packer {
  required_plugins {
    azure-rm = {
      version = ">= 1.0.6"
      source  = "github.com/hashicorp/azure"
    }
  }
}

variable "client_id" {
  type    = string
  description = "Specifies the service principal client-id"
}

variable "client_secret" {
  type    = string
  description = "Specifies the service principal secret"
}

variable "tenant_id" {
  type    = string
  description = "Specifies the Azure tenant id"
}

variable "subscription_id" {
  type    = string
  description = "Specifies the Azure subscription id where image should be saved"
}

source "azure-arm" "agent-windows" {
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id

  managed_image_storage_account_type = "Standard_LRS"
  managed_image_resource_group_name  = "ben-packer-weeu-lab-001"
  managed_image_name                 = "adowindows-img-weeu-lab-001"


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
    "source.azure-arm.agent-windows"
  ]

  provisioner "ansible" {
    playbook_file = "./playbooks/windows.yml"
    extra_arguments = [
      "--extra-vars @playbooks/vars/windows-vars.yaml"
    ]
    ansible_env_vars = [
      "WINRM_PASSWORD={{.WinRMPassword}}"
    ]
  }
}

