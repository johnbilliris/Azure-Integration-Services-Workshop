# Azure Integration Services Workshop

## Azure Functions – Hands-On Guide

Azure Functions is a serverless compute service that lets you run code in response to events. In this guide, you’ll create a simple Function App and an HTTP-triggered function, then test it. This will illustrate how Functions can be used to run custom logic as part of an integration.

### Skill Objective: Azure Functions

Learn to create a serverless function that runs on-demand. You will set up a Function App, create an HTTP-triggered function, and test it to see how custom code can integrate into workflows.

## Guide Steps

### Step 0: Prerequisites

Before you get started, make sure you have the following requirements in place:

+ An Azure account with an active subscription.

+ [.NET 8.0 SDK](https://dotnet.microsoft.com/download/dotnet/8.0).

+ [Visual Studio Code](https://code.visualstudio.com/) on one of the [supported platforms](https://code.visualstudio.com/docs/supporting/requirements#_platforms).

+ [C# extension](https://marketplace.visualstudio.com/items?itemName=ms-dotnettools.csharp) for Visual Studio Code.  

+ [Azure Functions extension](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-azurefunctions) for Visual Studio Code.

#### Install or update Core Tools

The Azure Functions extension for Visual Studio Code integrates with Azure Functions Core Tools so that you can run and debug your functions locally in Visual Studio Code using the Azure Functions runtime. Before getting started, it's a good idea to install Core Tools locally or update an existing installation to use the latest version.

In Visual Studio Code, select F1 to open the command palette, and then search for and run the command **Azure Functions: Install or Update Core Tools**.

This command tries to either start a package-based installation of the latest version of Core Tools or update an existing package-based installation. If you don't have npm or Homebrew installed on your local computer, you must instead [manually install or update Core Tools](../articles/azure-functions/functions-run-local.md#install-the-azure-functions-core-tools).

### Step 1

Create your local project

In this section, you use Visual Studio Code to create a local Azure Functions project in C#. Later in this article, you'll publish your function code to Azure.

1. In Visual Studio Code, press <kbd>F1</kbd> to open the command palette and search for and run the command `Azure Functions: Create New Project...`.

1. Select the directory location for your project workspace and choose **Select**. You should either create a new folder or choose an empty folder for the project workspace. Don't choose a project folder that is already part of a workspace.
 
1. Provide the following information at the prompts:

    |Prompt|Selection|
    |--|--|
    |**Select a language for your function project**|Choose `C#`.|
    | **Select a .NET runtime** | Choose `.NET 8.0 Isolated (LTS)`.|
    |**Select a template for your project's first function**|Choose `HTTP trigger`.<sup>1</sup>|
    |**Provide a function name**|Type `HttpExample`.|
    |**Provide a namespace** | Type `My.Functions`. |
    |**Authorization level**|Choose `Anonymous`, which enables anyone to call your function endpoint. For more information, see [Authorization level](functions-bindings-http-webhook-trigger.md#http-auth).|
    |**Select how you would like to open your project**|Select `Open in current window`.|

    <sup>1</sup> Depending on your VS Code settings, you may need to use the `Change template filter` option to see the full list of templates.

1. Visual Studio Code uses the provided information and generates an Azure Functions project with an HTTP trigger. You can view the local project files in the Explorer.

### Step 2

Run the function locally

Visual Studio Code integrates with [Azure Functions Core tools](https://learn.microsoft.com/en-us/azure/azure-functions/functions-run-local) to let you run this project on your local development computer before you publish to Azure. If you don't already have Core Tools installed locally, you are prompted to install it the first time you run your project.

1. To call your function, press <kbd>F5</kbd> to start the function app project. The **Terminal** panel displays the output from Core Tools. Your app starts in the **Terminal** panel. You can see the URL endpoint of your HTTP-triggered function running locally.

![Function run locally](images/functions-vscode-f5.png)

If you don't already have Core Tools installed, select **Install** to install Core Tools when prompted to do so.  
If you have trouble running on Windows, make sure that the default terminal for Visual Studio Code isn't set to **WSL Bash**.

2. With the Core Tools running, go to the **Azure: Functions** area. Under **Functions**, expand **Local Project** > **Functions**. Right-click (Windows) or <kbd>Ctrl -</kbd> click (macOS) the `HttpExample` function and choose **Execute Function Now...**.

![Execute Function Now](images/functions-execute-function-now.png)

3. In the **Enter request body**, press <kbd>Enter</kbd> to send a request message to your function.

4. When the function executes locally and returns a response, a notification is raised in Visual Studio Code. Information about the function execution is shown in the **Terminal** panel.

5. Press <kbd>Ctrl + C</kbd> to stop Core Tools and disconnect the debugger.

After checking that the function runs correctly on your local computer, it's time to use Visual Studio Code to publish the project directly to Azure.

### Step 3

Sign in to Azure

Before you can create Azure resources or publish your app, you must sign in to Azure.

1. If you aren't already signed in, in the **Activity bar**, select the Azure icon. Then under **Resources**, select **Sign in to Azure**.

![Sign in to Azure](images/functions-sign-into-azure.png)

If you're already signed in and can see your existing subscriptions, go to the next section.

2. When you are prompted in the browser, select your Azure account and sign in by using your Azure account credentials. If you create a new account, you can sign in after your account is created.

1. After you successfully sign in, you can close the new browser window. The subscriptions that belong to your Azure account are displayed in the side bar.

### Step 4

Create the function app in Azure

In this section, you create a function app in the Flex Consumption plan along with related resources in your Azure subscription. Many of the resource creation decisions are made for you based on default behaviours.

1. In Visual Studio Code, select F1 to open the command palette. At the prompt (`>`), enter and then select **Azure Functions: Create Function App in Azure**.

1. At the prompts, provide the following information:

    |Prompt|Action|
    |--|--|
    |**Select subscription**| Select the Azure subscription to use. The prompt doesn't appear when you have only one subscription visible under **Resources**. |
    |**Enter a new function app name**| Enter a globally unique name that's valid in a URL path. The name you enter is validated to make sure that it's unique in Azure Functions. |
    |**Select a location for new resources**| Select an Azure region. For better performance, select a [region](https://azure.microsoft.com/regions/) near you. Only regions supported by Flex Consumption plans are displayed. |
    |**Select a runtime stack**| Select the language version you currently run locally. |
    | **Select resource authentication type** | Select **Managed identity**, which is the most secure option for connecting to the [default host storage account](../articles/azure-functions/storage-considerations.md#storage-account-guidance). |

1. When the function app is created, the following related resources are created in your Azure subscription. The resources are named based on the name you entered for your function app.

+ A resource group, which is a logical container for related resources.
+ A function app, which provides the environment for executing your function code. A function app lets you group functions as a logical unit for easier management, deployment, and sharing of resources within the same hosting plan.
+ An Azure App Service plan, which defines the underlying host for your function app.
+ A standard Azure Storage account, which is used by the Functions host to maintain state and other information about your function app.
+ An Application Insights instance that's connected to the function app, and which tracks the use of your functions in the app.
+ A user-assigned managed identity that's added to the [Storage Blob Data Contributor](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles/storage#storage-blob-data-contributor) role in the new default host storage account.

A notification is displayed after your function app is created and the deployment package is applied.

### Step 5

Deploy the project to Azure

> IMPORTANT: Deploying to an existing function app always overwrites the contents of that app in Azure.

1. In the command palette, enter and then select **Azure Functions: Deploy to Function App**.  

1. Select the function app you just created. When prompted about overwriting previous deployments, select **Deploy** to deploy your function code to the new function app resource.

1. When deployment is completed, select **View Output** to view the creation and deployment results, including the Azure resources that you created. If you miss the notification, select the bell icon in the lower-right corner to see it again.

### Step 6

Run the function in Azure

1. Press <kbd>F1</kbd> to display the command palette, then search for and run the command `Azure Functions:Execute Function Now...`. If prompted, select your subscription.

2. Select your new function app resource and `HttpExample` as your function.

3. In **Enter request body** type `{ "name": "Azure" }`, then press Enter to send this request message to your function.

4. When the function executes in Azure, the response is displayed in the notification area. Expand the notification to review the full response.

### Step 7

Optional: Connection functions to Azure service using bindings.

https://learn.microsoft.com/en-us/azure/azure-functions/add-bindings-existing-function

The binding reference for Azure Service Bus. https://learn.microsoft.com/en-us/azure/azure-functions/functions-bindings-service-bus-trigger

## Conclusion

With these steps, you’ve deployed a function app and created a simple HTTP-triggered serverless function. This skill is crucial in integration scenarios where you need to execute custom business logic – for example, transforming data, performing calculations, or integrating with systems for which no connector exists. Azure Functions can be triggered by many events (HTTP requests, timers, Service Bus messages, Event Grid events, etc.), making them very flexible for integrating different parts of a cloud solution.
