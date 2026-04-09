#!/usr/bin/env bash
set -euo pipefail
set -x

###############################################################################
# CONFIG
###############################################################################
RESOURCE_GROUP="devops90days"
LOCATION="eastus2"

VM_NAME="ubuntu-vm"
ADMIN_USER="devopsadmin"
IMAGE="Ubuntu2404"
VM_SIZE="Standard_D2ads_v7"

SSH_KEY="$HOME/.ssh/id_rsa.pub"
SSH_PRIV="$HOME/.ssh/id_rsa"

VNET_NAME="vnet-main"
SUBNET_NAME="subnet-main"
NSG_NAME="nsg-main"

ADDRESS_PREFIX="10.10.0.0/16"
SUBNET_PREFIX="10.10.1.0/24"


# helper function (OK)
get_public_ip() {
  az vm show -d \
    -g "$RESOURCE_GROUP" \
    -n "$VM_NAME" \
    --query publicIps \
    -o tsv | tr -d '\r'
}

