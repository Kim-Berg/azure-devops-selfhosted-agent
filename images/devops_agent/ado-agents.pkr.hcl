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
    "source.azure-arm.agent-windows"
  ]

  provisioner "ansible" {
      use_proxy               = false
      playbook_file           = "./ansible/playbook.yml"
      ansible_env_vars        = ["PACKER_BUILD_NAME={{ build_name }}"]
      inventory_file_template = "{{ .HostAlias }} ansible_host={{ .ID }} ansible_user={{ .User }} ansible_ssh_common_args='-o StrictHostKeyChecking=no -o'\n"

      only = ["source.azure-arm.agent-ubuntu"]
    }

  provisioner "ansible" {
    playbook_file   = "./ansible/playbook.yml"
    user            = "Administrator"
    use_proxy       = false
    extra_arguments = [
      "-e",
      "ansible_winrm_server_cert_validation=ignore"
    ]

    only = ["source.azure-arm.agent-windows"]
  }
}

