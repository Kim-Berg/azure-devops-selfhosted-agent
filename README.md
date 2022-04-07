# azure-devops-selfhosted-agent
Fully desired state managed self hosted azure devops agent.
I created this project because I needed a way control the dependencies on my self-hosted build agents with immutable images.

# Features

* Create immutable images for VMSS hosted build agents
* Automated building of images and re-imaging of exising virtual machine scale sets
* Support for several self hosted build agent providers (github, ado etc.) (**todo**)
* Supports Windows and Ubuntu images (**todo**)
* Input is controlled with DaC (Data as Config) (**todo**)

# Tooling

Developed with the following tool versions

* Ansible version 2.9.97
* Packer version 1.8.0

# How to use

Edit the playbook.yaml file inside the `images/<imageType>/ansible` folder and add your dependencies under for your desired OS type.

# Image types

The following build agents are supported by this project

* Azure DevOps Self Hosted Agent

# Notes

1. Upgrade policy for vmss must be set to manual.
2. I think we need to perform the following after updating images: https://docs.microsoft.com/en-gb/azure/virtual-machine-scale-sets/virtual-machine-scale-sets-upgrade-scale-set#how-to-bring-vms-up-to-date-with-the-latest-scale-set-model

![alt text](docs/images/overview.png "Title")