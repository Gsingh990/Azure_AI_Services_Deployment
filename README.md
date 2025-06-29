# AI Services in Azure

This project provides a modular Azure Resource Manager (ARM) template solution for deploying and managing various Azure AI services, including Azure AI Services (Cognitive Services), Azure OpenAI Service, Azure Machine Learning Workspace, and an Azure Chatbot integrated with OpenAI.

## Architecture Overview

This solution deploys the following key Azure AI components:

*   **Azure AI Services (Cognitive Services):** A unified endpoint for various cognitive capabilities like Text Analytics, Document Intelligence, **Vision**, and more.
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

*   **`modules/azure_ai_services/`**: Deploys an Azure AI Services (Cognitive Services) account, providing access to Text Analytics, Document Intelligence, **Vision**, and other cognitive APIs.
*   **`modules/azure_openai/`**: Deploys an Azure OpenAI Service account and a specified model deployment (e.g., `gpt-4`).
*   **`modules/machine_learning/`**: Deploys an Azure Machine Learning Workspace along with its dependent resources (Storage Account, Key Vault, Application Insights, Container Registry). Supports private endpoint integration.
*   **`modules/azure_chatbot/`**: Deploys an Azure Bot Service, an App Service Plan, and an App Service. The App Service is configured with application settings to connect to the Azure OpenAI endpoint and API key, enabling the bot to use the deployed LLM.

## Important Notes

*   **Azure OpenAI Access:** Ensure your subscription has the necessary approvals for Azure OpenAI and the specific models you intend to deploy.
*   **Chatbot Implementation:** The `azure_chatbot` module provisions the Azure infrastructure for the bot. You will still need to deploy your bot's code (e.g., a C# or Node.js bot application) to the created App Service. The application settings for OpenAI connectivity are provided, which your bot code can consume.
*   **Private Endpoints:** For Machine Learning Workspace, if you specify `mlWorkspaceVnetName` and `mlWorkspaceSubnetName`, a private endpoint will be created, and public network access will be disabled for the workspace.

## Azure DevOps Pipeline

An Azure DevOps YAML pipeline (`azure-pipelines.yml`) is provided to automate the deployment of these ARM templates. This pipeline is designed to be triggered manually or via a REST API.

### Pipeline Setup

1.  **Import Pipeline:** In your Azure DevOps project, navigate to **Pipelines** -> **New pipeline**. Select **Azure Repos Git** (or your repository type), choose your repository, and then select **Existing Azure Pipelines YAML file**. Point to `azure-pipelines.yml` in the root of this repository.
2.  **Service Connection:** Ensure you have an Azure Resource Manager service connection configured in your Azure DevOps project. The pipeline expects a service connection named `AzureRM-ServiceConnection`. This service connection must have sufficient permissions to deploy resources to your Azure subscription.
3.  **Pipeline Variables:** The pipeline uses a variable `$(SubscriptionId)`. You should define this as a pipeline variable or ensure your service connection is configured to provide it.

### Pipeline Parameters

The pipeline defines several parameters that map to the ARM template parameters, allowing you to customize the deployment when triggering the pipeline. These include:

*   `resourceGroupName`
*   `location`
*   `environment` (for tagging)
*   `cognitiveServicesName`
*   `openAiName`
*   `openAiModelName`
*   `openAiModelVersion`
*   `openAiModelDeploymentName`
*   `mlWorkspaceName`
*   `botName`

### Triggering from ServiceNow (REST API)

Azure DevOps pipelines can be triggered programmatically using the Azure DevOps REST API. ServiceNow can be configured to make a REST API call to initiate a pipeline run.

**1. Obtain Personal Access Token (PAT):**
    You will need a Personal Access Token (PAT) from Azure DevOps with sufficient permissions to queue builds (e.g., `Build (Read & execute)` scope). Store this PAT securely in ServiceNow.

**2. Construct the REST API Request:**
    The API endpoint for queuing a build is:
    `POST https://dev.azure.com/{organization}/{project}/_apis/build/builds?api-version=7.1`

    **Headers:**
    *   `Content-Type: application/json`
    *   `Authorization: Basic {base64EncodedPat}` (where `base64EncodedPat` is your PAT encoded in Base64)

    **Request Body (JSON):**
    You can pass pipeline parameters in the request body. The `definition.id` refers to the ID of your pipeline in Azure DevOps.

    ```json
    {
      "definition": {
        "id": [Your_Pipeline_ID]
      },
      "parameters": "{\"resourceGroupName\":\"my-custom-rg\", \"location\":\"westus2\", \"environment\":\"prod\"}"
    }
    ```
    *   Replace `[Your_Pipeline_ID]` with the actual ID of your pipeline in Azure DevOps.
    *   The `parameters` field is a stringified JSON object. Ensure proper escaping of double quotes within this string.

**3. ServiceNow Configuration:**
    In ServiceNow, you would typically use a REST Message or Scripted REST API to construct and send this HTTP POST request. You would map fields from your ServiceNow incident, change request, or catalog item to the pipeline parameters in the request body.

This setup allows for automated, controlled deployments of your Azure AI services directly from your IT Service Management (ITSM) platform.
