#!/bin/bash
echo "Registering new image definitions to gallery"
existing_linux_definition=$(az sig image-definition list --gallery-name img_gal_weeu_lab_001 --resource-group ben-packer-weeu-lab-001 --query '[?contains(name, `adolinux`)].{name:name}' | jq '.[]|select(.name|length>0)')
if [[ -n ${existing_linux_definition} ]];then
    az sig image-definition create \
        --resource-group ben-packer-weeu-lab-001 \
        --gallery-name img_gal_weeu_lab_001 \
        --gallery-image-definition adolinux \
        --publisher benkooijman \
        --offer 0001-com-ubuntu-server-focal \
        --sku 20_04-lts-gen2 \
        --hyper-v-generation "V2" \
        --os-type linux
fi
exit 0;