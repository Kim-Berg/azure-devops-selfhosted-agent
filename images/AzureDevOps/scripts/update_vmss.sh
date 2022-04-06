#!/bin/bash

# set -x 

# Metadata
#   description: Read and parse manifest file created by packer post-processor
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
VMSS_NAME=$(jq '.builds[0].custom_data.target_vmss_name' ${MANIFEST_PATH})
VMSS_RG=$(jq '.builds[0].custom_data.target_vmss_rg' ${MANIFEST_PATH})

printf "______ ${COLOUR}Current Settings${NC} ______\n"
printf "MANIFEST_PATH..${COLOUR}${MANIFEST_PATH}${NC}\n"
printf "IMAGE_ID.........${COLOUR}${IMAGE_ID}${NC}\n"
printf "TARGET_VMSS......${COLOUR}${VMSS_NAME}${NC}\n"
printf "TARGET_VMSS_RG...${COLOUR}${VMSS_RG}${NC}\n"

if [[ -z ${MANIFEST_PATH} ]] || [[ -z ${IMAGE_ID} ]] || [[ -z ${VMSS_NAME} ]] || [[ -n ${VMSS_RG} ]]; then

    printf "re-image virtual machine scale set named ${VMSS_NAME}...\n"
    printf "az vmss update --resource-group ${VMSS_RG} --name ${VMSS_NAME} --set virtualMachineProfile.storageProfile.imageReference.id=${IMAGE_ID}\n"
    az vmss update --resource-group ${VMSS_RG} --name ${VMSS_NAME} --set virtualMachineProfile.storageProfile.imageReference.id=${IMAGE_ID}

    printf "updating running instances..."
    printf "az vmss update-instances --resource-group ${VMSS_RG} --name ${VMSS_NAME} --instance-ids \"*\"\n"
    az vmss update-instances --resource-group ${VMSS_RG} --name ${VMSS_NAME} --instance-ids "*"

else
    usage
fi