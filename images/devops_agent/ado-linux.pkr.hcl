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

# source block configures a specific builder plugin, which is then invoked by a build block.
source "azure-arm" "agent-ubuntu" {
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id

  managed_image_resource_group_name = "ben-packer-weeu-lab-001"
  managed_image_name                = "adolinux-img-weeu-lab-001"

  os_type         = "Linux"
  image_publisher = "Canonical"
  image_offer     = "UbuntuServer"
  image_sku       = "18.04-LTS"

  location = "West Europe"
  vm_size  = "Standard_B1s"
}

# The build block defines what Packer should do with the Docker container after it launches.
build {
  name = "learn-packer"
  sources = [
    "source.azure-arm.agent-ubuntu"
  ]

  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E sh '{{ .Path }}'"
    inline = [
      "/usr/sbin/waagent -force -deprovision+user && export HISTSIZE=0 && sync"
    ]
    inline_shebang = "/bin/sh -x"
  }
}
