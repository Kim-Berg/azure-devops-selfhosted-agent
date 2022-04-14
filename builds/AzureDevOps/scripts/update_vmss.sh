#!/bin/bash

# set -x 

# Metadata
#   description: Read and parse manifest file created by packer post-processor
#       This script is used as an inline script in the CI pipelines. The reason why it is kept here to for local debugging purposes.
#   creator: ben@kooijman.se
#   date: 2022-04-06

function usage {
    echo "Usage: $0 [ -i <manifest path> ]" 1>&2; exit 1;
}

while getopts "i:" o; do
    case "${o}" in
        i)
            MANIFEST_PATH=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done

COLOUR='\033[1;32m' # Green
NC='\033[0m' # No Color

IMAGE_ID=$(jq '.builds[0].artifact_id' ${MANIFEST_PATH} | tr -d '"')
VMSS_NAME=$(jq '.builds[0].custom_data.target_vmss_name' ${MANIFEST_PATH} | tr -d '"')
VMSS_RG=$(jq '.builds[0].custom_data.target_vmss_rg' ${MANIFEST_PATH} | tr -d '"')
CREATE_NEW_VMSS=$(jq '.builds[0].custom_data.create_new_scale_set' ${MANIFEST_PATH} | tr -d '"')

printf "______ ${COLOUR}Current Settings${NC} ______\n"
printf "MANIFEST_PATH..${COLOUR}${MANIFEST_PATH}${NC}\n"
printf "IMAGE_ID.........${COLOUR}${IMAGE_ID}${NC}\n"
printf "TARGET_VMSS......${COLOUR}${VMSS_NAME}${NC}\n"
printf "TARGET_VMSS_RG...${COLOUR}${VMSS_RG}${NC}\n"

if [[ -z ${MANIFEST_PATH} ]] || [[ -z ${IMAGE_ID} ]] || [[ -z ${VMSS_NAME} ]] || [[ -n ${VMSS_RG} ]]; then
    read -p "Do you wish to continue Yes/No? " yn
    while true; do
        case $yn in
            Yes )   printf "re-image virtual machine scale set named ${VMSS_NAME}...\n"; \
                    printf "az vmss update --resource-group ${VMSS_RG} --name ${VMSS_NAME} --set virtualMachineProfile.storageProfile.imageReference.id=${IMAGE_ID}\n"; \
                    if [[ -${CREATE_NEW_VMSS} -eq 'true' ]]; then \
                        az vmss create \
                        --name ${VMSS_NAME} \
                        --resource-group ${VMSS_RG} \
                        --image ${IMAGE_ID} \
                        --vm-sku Standard_B1s \
                        --storage-sku StandardSSD_LRS \
                        --authentication-type SSH \
                        --instance-count 2 \
                        --disable-overprovision \
                        --upgrade-policy-mode manual \
                        --single-placement-group false \
                        --platform-fault-domain-count 1 \
                        --load-balancer ""; \
                    else; \
                        az vmss update --resource-group ${VMSS_RG} --name ${VMSS_NAME} --set virtualMachineProfile.storageProfile.imageReference.id=${IMAGE_ID}; \
                    fi; \
                    if [[ $? -eq 0 ]]; then \
                        printf "updating running instances..."; \
                        printf "az vmss update-instances --resource-group ${VMSS_RG} --name ${VMSS_NAME} --instance-ids \"*\"\n"; \
                        az vmss update-instances --resource-group ${VMSS_RG} --name ${VMSS_NAME} --instance-ids "*";;
                    else; \
                        break;; \
                    fi
            No ) exit;;
        esac
    done
else
    usage
fi