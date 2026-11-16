#!/usr/bin/env bash

# Creates this project's Terraform state container in the shared state account.
# Safe to re-run: it only creates the container if it doesn't already exist.

set -euo pipefail

RG="tfstate"
SA="tfstate7920"
CONTAINER="tfstate-azure-env"

# Show which subscription az is pointed at, so a wrong login is obvious before anything changes
SUB_NAME=$(az account show --query name -o tsv)
SUB_ID=$(az account show --query id -o tsv)
echo "Subscription: ${SUB_NAME} (${SUB_ID})"

# Ask Azure Resource Manager whether the container already exists
# --query exists -o tsv turns the JSON {"exists": true} into plain "true" or "false"
EXISTS=$(az storage container-rm exists \
  --name "$CONTAINER" \
  --storage-account "$SA" \
  --resource-group "$RG" \
  --query exists -o tsv)

if [ "$EXISTS" = "true" ]; then
  echo "Container '${CONTAINER}' already exists in ${SA}. Nothing to do."
else
  # container-rm goes through the control plane
  az storage container-rm create \
    --name "$CONTAINER" \
    --storage-account "$SA" \
    --resource-group "$RG" \
    --public-access off \
    --output none
  echo "Created container '${CONTAINER}' in ${SA}."
fi