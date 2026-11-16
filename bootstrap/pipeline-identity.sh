#!/usr/bin/env bash

# Gives the azure-env pipeline, and you, the roles this project needs.
# Run once, after creating the github-azure-env app registration and its
# two federated credentials in the portal.

set -euo pipefail

RG="tfstate"
SA="tfstate7920"
CONTAINER="tfstate-azure-env"
APP_NAME="github-azure-env"

# Show which subscription az is pointed at, so a wrong login is obvious before anything changes.
SUB_NAME=$(az account show --query name -o tsv)
SUB_ID=$(az account show --query id -o tsv)
echo "Subscription: ${SUB_NAME} (${SUB_ID})"

# The app registration's ID. [0] takes only the first match, and the filter makes the name match exactly.
APP_ID=$(az ad app list --display-name "$APP_NAME" \
  --query "[?displayName=='$APP_NAME'].appId | [0]" -o tsv)

if [ -z "$APP_ID" ]; then
  echo "No app registration called '${APP_NAME}' found. Create it in the portal first." >&2
  exit 1
fi

# Role assignments go to the service principal (the app's identity in this tenant), not the app registration.
SP_ID=$(az ad sp show --id "$APP_ID" --query id -o tsv)

# Your own user, so terraform init and plan work from your laptop.
ME=$(az ad signed-in-user show --query id -o tsv)

# Scopes: this project's container only, and the whole subscription.
SA_ID=$(az storage account show --name "$SA" --resource-group "$RG" --query id -o tsv)
CONTAINER_SCOPE="${SA_ID}/blobServices/default/containers/${CONTAINER}"
SUB_SCOPE="/subscriptions/${SUB_ID}"

# 1. Pipeline: read and write this project's state, and nothing else in the account.
az role assignment create \
  --assignee-object-id "$SP_ID" --assignee-principal-type ServicePrincipal \
  --role "Storage Blob Data Contributor" --scope "$CONTAINER_SCOPE" --output none

# 2. You: same access, so local init and plan can read the state.
az role assignment create \
  --assignee-object-id "$ME" --assignee-principal-type User \
  --role "Storage Blob Data Contributor" --scope "$CONTAINER_SCOPE" --output none

# 3. Pipeline: create resource groups and everything in them.
az role assignment create \
  --assignee-object-id "$SP_ID" --assignee-principal-type ServicePrincipal \
  --role "Contributor" --scope "$SUB_SCOPE" --output none

echo "Role assignments done. Values for the GitHub repository variables:"
echo "  AZURE_CLIENT_ID       = ${APP_ID}"
echo "  AZURE_TENANT_ID       = $(az account show --query tenantId -o tsv)"
echo "  AZURE_SUBSCRIPTION_ID = ${SUB_ID}"