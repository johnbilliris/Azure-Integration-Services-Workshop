# Azure Integration Services Workshop

## Azure API Management – Hands-On Guide - Solution

This folder provides the necessary Bicep templates and configuration file to deploy the Azure API Management as part of the Azure Integration Services Workshop. The Bicep templates define the infrastructure and resources required for the API Management resource, while the parameter file contain the necessary parameters for deployment.

### Steps

1. Modify the `infra/main.parameters.json` file to set the parameters for your deployment.
1. Ensure you have the Azure Developer CLI (`azd`) installed
1. Run the `azd auth login` command to authenticate with your Azure account.
1. Use `azd up` to deploy the Service Bus.
1. Use `azd down` to tear down the resource group and the resources.
