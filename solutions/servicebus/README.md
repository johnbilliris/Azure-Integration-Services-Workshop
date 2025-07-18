# Azure Integration Services Workshop

## Azure Service Bus – Hands-On Guide - Solution

This folder provides the necessary Bicep templates and configuration file to deploy the Azure Service Bus as part of the Azure Integration Services Workshop. The Bicep templates define the infrastructure and resources required for the Service Bus, while the parameter file contain the necessary parameters for deployment.

### Steps

1. Modify the `infra/main.bicepparam` file to set the parameters for your deployment, such as `resourceGroupName` and `location`.
2. Use `azd up` to deploy the Service Bus.

### Notes

1. Currently, `azd down` has issues and fails to tear down (delete) the Service Bus. You need to manually delete the resource group from the Azure Portal.
