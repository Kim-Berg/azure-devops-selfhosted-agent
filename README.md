# azure-devops-selfhosted-agent
Fully desired state managed self hosted azure devops agent

# Tooling

Developed with the following tool versions

* Ansible version 2.9.97
* Packer version 1.8.0

# How to use

Edit the playbook.yaml file inside the `images/<imageType>/ansible` folder and add your dependencies under for your desired OS type.

# Image types

The following build agents are supported by this project

* Azure DevOps Self Hosted Agent

![alt text](docs/images/overview.png "Title")