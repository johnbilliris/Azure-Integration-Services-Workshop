# Azure Integration Services Workshop

## Azure Logic Apps – Hands-On Guide - Solution

This folder provides the necessary Bicep templates and configuration file to deploy the Azure Logic Apps as part of the Azure Integration Services Workshop. The Bicep templates define the infrastructure and resources required for the Logic Apps, while the parameter file contain the necessary parameters for deployment.

### Steps

1. Modify the `infra/main.parameters.json` file to set the parameters for your deployment, such as `location`, and `email_recipient`.
1. Ensure you have the Azure Developer CLI (`azd`) installed
1. Run the `azd auth login` command to authenticate with your Azure account.
1. Use `azd up` to deploy the two Logic Apps and the Office 365 connection.
1. The Office 365 connection is initially in `error` state. You need to manually configure the connection by providing the necessary credentials and permissions. (Instructions are not provided here, but typically you would do this through the Azure Portal by navigating to the API Connection in the resource group, and configuring the Office 365 connection.)
