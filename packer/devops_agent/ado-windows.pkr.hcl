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
  image_sku       = "2019-Datacenter-Core"
  image_version   = "17763.737.1909062324"

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

  provisioner "powershell" {
    inline = [
      " # NOTE: the following *3* lines are only needed if the you have installed the Guest Agent.",
      "  while ((Get-Service RdAgent).Status -ne 'Running') { Start-Sleep -s 5 }",
      "  while ((Get-Service WindowsAzureTelemetryService).Status -ne 'Running') { Start-Sleep -s 5 }",
      "  while ((Get-Service WindowsAzureGuestAgent).Status -ne 'Running') { Start-Sleep -s 5 }",

      "& $env:SystemRoot\\System32\\Sysprep\\Sysprep.exe /oobe /generalize /quiet /quit /mode:vm",
      "while($true) { $imageState = Get-ItemProperty HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Setup\\State | Select ImageState; if($imageState.ImageState -ne 'IMAGE_STATE_GENERALIZE_RESEAL_TO_OOBE') { Write-Output $imageState.ImageState; Start-Sleep -s 10  } else { break } }"
    ]
  }


}
