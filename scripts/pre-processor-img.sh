#!/bin/bash
echo "Registering new image definitions to gallery"
existing_linux_definition=$(az sig image-definition list --gallery-name img_mlcmn_weeu_dev_001 --resource-group ml-enterprise-dev-rg --query '[?contains(name, `esml-devops-agent-linux`)].{name:name}' | jq '.[]|select(.name|length>0)')
if [[ -z ${existing_linux_definition} ]];then
    az sig image-definition create \
        --resource-group ml-enterprise-dev-rg \
        --gallery-name img_mlcmn_weeu_dev_001 \
        --gallery-image-definition esml-devops-agent-linux \
        --publisher esml-infra-team \
        --offer 0001-com-ubuntu-server-focal-daily \
        --sku 20_04-daily-lts-gen2 \
        --hyper-v-generation "V2" \
        --os-type linux
else
    echo "image definition already exists. Doing nothing :)"
fi
exit 0;