add a hosts file for local debugging purposes


sample file:
---
local_debugging:
  hosts:
    linux-ansible-target:
      ansible_host: <pub ip>
      ansible_ssh_user: azureuser
      ansible_connection: ssh
      ansible_become: true
    windows-ansible-target:
      ansible_host: <pub ip>
      ansible_user: azureuser
      ansible_password: <password>
      ansible_connection: winrm
      ansible_winrm_user: azureuser
      ansible_winrm_server_cert_validation: ignore