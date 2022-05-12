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
  default="../build_config"
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
  green_img_linux   = "adolinux-img-${local.location_abbreviations["westeurope"]}-dev-001"
  green_img_windows = "adowindows-img-${local.location_abbreviations["westeurope"]}-dev-001"
}

# source block configures a specific builder plugin, which is then invoked by a build block.

source "azure-arm" "agent-ubuntu" {
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
  build_resource_group_name = "ben-packer-weeu-lab-001"
  shared_image_gallery_destination {
    subscription = var.subscription_id
    resource_group = "ben-packer-weeu-lab-001"
    gallery_name = "img_gal_weeu_lab_001"
    image_name = local.green_img_linux
    image_version = "0.0.1"
    replication_regions = ["West Europe"]
    storage_account_type = "Standard_LRS"
  }
  managed_image_resource_group_name  = "ben-packer-weeu-lab-001"
  managed_image_name                 = local.green_img_linux
  os_type         = "Linux"
  image_publisher = "Canonical"
  image_offer     = "0001-com-ubuntu-server-focal"
  image_sku       = "20_04-lts-gen2"
  vm_size  = "Standard_B1s"
}


# The build block defines what Packer should do with the Docker container after it launches.
build {
  name = "self-hosted-build-agents"
  sources = ["source.azure-arm.agent-ubuntu",]
  provisioner "ansible" {
    use_proxy               = false
    playbook_file           = "${var.ansible_playbook_path}/playbook.yaml"
    inventory_directory     = "${var.ansible_playbook_path}/"
  
    inventory_file_template = "{{ .HostAlias }} ansible_host={{ .Host }} ansible_user={{ .User }} ansible_port={{ .Port }} ansible_become=true"
  
    only                    = ["azure-arm.agent-ubuntu"]
  }
  
  post-processor "manifest" {
      output = "manifest.json"
      strip_path = true
      custom_data = {
          source_image_name = "${build.SourceImageName}"      
          vmss_1_name = "vmss-linux-weeu-lab-001"
          vmss_1_resource_group = "ben-packer-weeu-lab-001"
          image_1_name = local.green_img_linux
          image_1_resource_group = "ben-packer-weeu-lab-001"      
          vmss_2_name = "vmss-windows-weeu-lab-001"
          vmss_2_resource_group = "ben-packer-weeu-lab-001"
          image_2_name = local.green_img_linux
          image_2_resource_group = "ben-packer-weeu-lab-001"
      }
  }
}