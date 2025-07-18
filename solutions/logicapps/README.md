# Azure Integration Services Workshop

## Azure Logic Apps – Hands-On Guide - Solution

This folder provides the necessary Bicep templates and configuration file to deploy the Azure Logic Apps as part of the Azure Integration Services Workshop. The Bicep templates define the infrastructure and resources required for the Logic Apps, while the parameter file contain the necessary parameters for deployment.

### Steps

1. Modify the `infra/main.bicepparam` file to set the parameters for your deployment, such as `resourceGroupName`, `location`, and `email_recipient`.
2. Use `azd up` to deploy the two Logic Apps and the Office 365 connection.
3. The Office 365 connection is initially in `error` state. You need to manually configure the connection by providing the necessary credentials and permissions. (Instructions are not provided here, but typically you would do this through the Azure Portal by navigating to the Logic App and configuring the Office 365 connection.)

### Notes

1. Currently, `azd down` has issues and fails to tear down (delete) the Logic Apps. You need to manually delete the resource group from the Azure Portal.
