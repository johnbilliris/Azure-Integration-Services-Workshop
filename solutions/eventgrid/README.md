# Azure Integration Services Workshop

## Azure Event Grid and Event Hub – Hands-On Guide - Solution

This folder provides the necessary Bicep templates and configuration file to deploy the Azure Event Grid, Azure Event Hub, Azure App Service for the Event Grid Viewer application, and Azure Function as part of the Azure Integration Services Workshop. The Bicep templates define the infrastructure and resources required for the Event Grid and Event Hub, while the parameter file contain the necessary parameters for deployment.

### Steps

1. Modify the `infra/main.parameters.json` file to set the parameters for your deployment, such as `location`, and `email_recipient`.
1. Ensure you have the Azure Developer CLI (`azd`) installed
1. Run the `azd auth login` command to authenticate with your Azure account.
1. Use `azd up` to deploy the resources.
1. Use `azd down` to tear down the resource group and the resources.
