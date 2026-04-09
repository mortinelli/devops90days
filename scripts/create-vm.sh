#!/usr/bin/env bash
set -euo pipefail
set -x

###############################################################################
# SANITY
###############################################################################
[[ -f "$SSH_KEY" ]] || { echo "❌ SSH key not found"; exit 1; }

###############################################################################
# RESOURCE GROUP
###############################################################################
az group create \
  --name "$RESOURCE_GROUP" \
  --location "$LOCATION"

###############################################################################
# NETWORK: VNET + SUBNET
###############################################################################
az network vnet create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VNET_NAME" \
  --address-prefix "$ADDRESS_PREFIX" \
  --subnet-name "$SUBNET_NAME" \
  --subnet-prefix "$SUBNET_PREFIX"

###############################################################################
# NETWORK SECURITY GROUP (EXPLICIT)
###############################################################################
az network nsg create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$NSG_NAME"

###############################################################################
# NSG RULES
###############################################################################

# SSH
az network nsg rule create \
  --resource-group "$RESOURCE_GROUP" \
  --nsg-name "$NSG_NAME" \
  --name Allow-SSH \
  --priority 1000 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp \
  --destination-port-ranges 22

# HTTP
az network nsg rule create \
  --resource-group "$RESOURCE_GROUP" \
  --nsg-name "$NSG_NAME" \
  --name Allow-HTTP \
  --priority 1100 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp \
  --destination-port-ranges 80

###############################################################################
# ATTACH NSG TO SUBNET
###############################################################################
az network vnet subnet update \
  --resource-group "$RESOURCE_GROUP" \
  --vnet-name "$VNET_NAME" \
  --name "$SUBNET_NAME" \
  --network-security-group "$NSG_NAME"

###############################################################################
# VM CREATE (NO MAGIC, NO DEFAULTS)
###############################################################################
az vm create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VM_NAME" \
  --image "$IMAGE" \
  --size "$VM_SIZE" \
  --admin-username "$ADMIN_USER" \
  --ssh-key-values "$SSH_KEY" \
  --nsg "$NSG_NAME" \
  --vnet-name "$VNET_NAME" \
  --subnet "$SUBNET_NAME" \
  --public-ip-sku Standard

###############################################################################
# OUTPUT
###############################################################################

PUBLIC_IP=$(az vm show -d \
  -g "$RESOURCE_GROUP" \
  -n "$VM_NAME" \
  --query publicIps \
  -o tsv | tr -d '\r')

echo "✅ VM READY"
echo "🌍 SSH: ssh $ADMIN_USER@$PUBLIC_IP"
echo "🌍 HTTP: http://$PUBLIC_IP"
