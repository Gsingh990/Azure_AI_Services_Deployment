# AI Services in Azure

This project provides a modular Azure Resource Manager (ARM) template solution for deploying and managing various Azure AI services, including Azure AI Services (Cognitive Services), Azure OpenAI Service, Azure Machine Learning Workspace, and an Azure Chatbot integrated with OpenAI.

## Architecture Overview

This solution deploys the following key Azure AI components:

*   **Azure AI Services (Cognitive Services):** A unified endpoint for various cognitive capabilities like Text Analytics and Document Intelligence.
*   **Azure OpenAI Service:** Provides access to OpenAI's powerful language models (e.g., GPT-4) hosted on Azure.
*   **Azure Machine Learning Workspace:** A centralized environment for managing the end-to-end machine learning lifecycle.
*   **Azure Chatbot:** An Azure Bot Service instance with an associated App Service, configured to interact with the deployed Azure OpenAI Service for conversational AI capabilities.

All resources are deployed within a single resource group, orchestrated by a main ARM template that links to modular templates for each service.

## Prerequisites

Before deploying this solution, ensure you have the following:

*   **Azure Subscription:** An active Azure subscription.
*   **Azure CLI:** Installed and configured (`az login`).
*   **Permissions:** Sufficient permissions in your Azure subscription to create resource groups and deploy the listed Azure resources.
*   **Azure OpenAI Access:** Access to Azure OpenAI Service is currently by application only. Ensure your Azure subscription has been approved for Azure OpenAI access. You may also need to request specific model deployments (e.g., `gpt-4`) in your region.

## Deployment Steps

1.  **Clone the repository:**
    ```bash
    git clone <repository-url>
    cd ai_services_azure_arm
    ```

2.  **Review and Customize Parameters:**
    Open the `parameters.json` file in the root directory. This file contains default values for all configurable parameters. Review and modify these values as needed for your deployment (e.g., resource names, locations, SKUs, tags).

    *   **Important for Chatbot:** The `openAiEndpoint` and `openAiApiKey` parameters in `modules/azure_chatbot/azure_chatbot.parameters.json` are populated dynamically by the `main.json` template using outputs from the `azure_openai` deployment. You do not need to manually set these in `parameters.json`.

3.  **Execute the Deployment Script:**
    Navigate to the root of the project (`ai_services_azure_arm`) in your terminal and run the deployment script:
    ```bash
    ./scripts/deploy.sh
    ```
    This script will:
    *   Create the specified Azure Resource Group if it doesn't already exist.
    *   Initiate the ARM deployment using `main.json` and `parameters.json`.

4.  **Verify Deployment:**
    After the deployment completes, you can verify the created resources in the Azure portal under the specified resource group.

## Configuration

The `parameters.json` file is the primary place to customize your deployment. Key parameters include:

*   `resourceGroupName`: The name of the Azure Resource Group.
*   `location`: The Azure region for resource deployment.
*   `tags`: Global tags to apply to all resources.
*   `cognitiveServicesName`, `cognitiveServicesSku`, `cognitiveServicesPublicNetworkAccess`, `cognitiveServicesDisableLocalAuth`
*   `openAiName`, `openAiSku`, `openAiPublicNetworkAccess`, `openAiDisableLocalAuth`, `openAiModelName`, `openAiModelVersion`, `openAiModelDeploymentName`, `openAiModelCapacity`
*   `mlWorkspaceName`, `mlWorkspaceSku`, `mlWorkspaceDescription`, `mlWorkspacePrimaryStorageAccountName`, `mlWorkspaceKeyVaultName`, `mlWorkspaceApplicationInsightsName`, `mlWorkspaceContainerRegistryName`, `mlWorkspaceEnablePublicReadAccess`, `mlWorkspaceVnetName`, `mlWorkspaceSubnetName`, `mlWorkspacePrivateDnsZoneName`
*   `botName`, `botDisplayName`, `appServicePlanSku`, `appServicePlanKind`, `appServicePlanReserved`, `appServiceAlwaysOn`, `appServiceHttpsOnly`, `openAiApiVersion`

## Module Breakdown

*   **`modules/azure_ai_services/`**: Deploys an Azure AI Services (Cognitive Services) account, providing access to Text Analytics, Document Intelligence, and other cognitive APIs.
*   **`modules/azure_openai/`**: Deploys an Azure OpenAI Service account and a specified model deployment (e.g., `gpt-4`).
*   **`modules/machine_learning/`**: Deploys an Azure Machine Learning Workspace along with its dependent resources (Storage Account, Key Vault, Application Insights, Container Registry). Supports private endpoint integration.
*   **`modules/azure_chatbot/`**: Deploys an Azure Bot Service, an App Service Plan, and an App Service. The App Service is configured with application settings to connect to the Azure OpenAI endpoint and API key, enabling the bot to use the deployed LLM.

## Important Notes

*   **Azure OpenAI Access:** Ensure your subscription has the necessary approvals for Azure OpenAI and the specific models you intend to deploy.
*   **Chatbot Implementation:** The `azure_chatbot` module provisions the Azure infrastructure for the bot. You will still need to deploy your bot's code (e.g., a C# or Node.js bot application) to the created App Service. The application settings for OpenAI connectivity are provided, which your bot code can consume.
*   **Private Endpoints:** For Machine Learning Workspace, if you specify `mlWorkspaceVnetName` and `mlWorkspaceSubnetName`, a private endpoint will be created, and public network access will be disabled for the workspace.
