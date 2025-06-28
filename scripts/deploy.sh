#!/bin/bash

RESOURCE_GROUP_NAME="ai-services-rg"
LOCATION="eastus"

# Create resource group if it doesn't exist
az group show --name $RESOURCE_GROUP_NAME &> /dev/null

if [ $? -ne 0 ]; then
    echo "Creating resource group $RESOURCE_GROUP_NAME in $LOCATION..."
    az group create --name $RESOURCE_GROUP_NAME --location $LOCATION
else
    echo "Resource group $RESOURCE_GROUP_NAME already exists."
fi

echo "Deploying ARM template..."
az deployment group create \
  --resource-group $RESOURCE_GROUP_NAME \
  --template-file main.json \
  --parameters @parameters.json

echo "Deployment complete."
