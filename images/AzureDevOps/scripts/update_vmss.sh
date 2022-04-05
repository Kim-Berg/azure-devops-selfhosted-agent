#!/bin/bash

# this is pseudo code, work in progres...

new_image="/subscriptions/<subid>/resourceGroups/General_Ben/providers/Microsoft.Compute/images/<imagename>"
vmss_name="ado-agent-lab"
resource_group="general_ben"
az vmss update --resource-group ${resource_group} --name ${vmss_name} --set virtualMachineProfile.storageProfile.imageReference.id="${new_image}"

# retrieve minimum number of instance numbers
instances=@(1 2)
for vm in ${instances[@]}; do 
    az vmss update-instances --resource-group general_ben --name ado-agent-lab --instance-ids ${vm}
done