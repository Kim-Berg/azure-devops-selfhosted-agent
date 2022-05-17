# Notice

This is a work in progress project! This means that some documentation is wrong and code do not work as intended yet

# azure-devops-selfhosted-agent
Managed self-hosted agent creation + OS level dependencies from a single `desired_state.yaml` file
I created this project because I needed a way control the dependencies on my self-hosted build agents with immutable images.

# Features

* Create immutable images for VMSS hosted build agents
* Automated building of images and re-imaging of exising virtual machine scale sets
* Supports Windows and Ubuntu images
* Input is controlled with DaC (Data as Config)

# Tooling

Developed with the following tool versions

* Ansible version 2.9.97
* Packer version 1.8.0
* Python version 3.10.0


# Create VMSS
```
az vmss create \
--name <name> \
--resource-group <rg> \
--image Canonical:0001-com-ubuntu-server-focal-daily:20_04-daily-lts-gen2:20.04.202205110 \
--vm-sku Standard_B1ls \
--storage-sku StandardSSD_LRS \
--authentication-type SSH \
--instance-count 2 \
--disable-overprovision \
--upgrade-policy-mode manual \
--single-placement-group false \
--platform-fault-domain-count 1 \
--load-balancer ""
```

# How does it work?

1. Everything from the desired_state.yaml file
2. This file is converted by `templater.py` to Hasicorp Packer HCL templates for IaC image provisioning + Ansible playbook for OS level Config-as-Code
3. CI pipeline runs everything in sequence

# How to use

1. Install the CI/\*.yaml file inside your building environment
2. Update the desired_state.yaml (see reference docs here)

# Image types

The following build agents are supported by this project

* Azure DevOps Self Hosted Agent

# TODO

* Create reference docs for desired_state.yaml

# Important links

1. Creating VMSS based self hosted Azure DevOps agents: https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/scale-set-agents?view=azure-devops

![alt text](docs/images/overview.png "Title")
