# Azure Integration Services Workshop

## Azure API Management (APIM) – Hands-On Guide

APIM allows organizations to publish and manage APIs at scale, acting as a secure front door to backend services. This hands-on exercise will guide you through creating an API Management instance, adding a simple API, and testing it.

### Skill Objective: API Management

Learn how to create an API gateway, publish a backend service as an API, and apply basic operations and tests using Azure API Management.

### Acknowledgement

This lab is based on the [Azure API Management Hands on Lab](https://azure.github.io/apim-lab/). This hands-on lab will guide you through the different concepts around Azure API Management, from the creation to the DevOps, including good practices in terms of versioning, security, and so on. It is designed to bring customers and partners to a 200-level understanding of Azure Api Management. This is meant to be a hands-on lab experience, all instructions are provided, but a basic level of understanding of apis is expected (http operations, networking basics, openapi, rest, soap, oauth2, and other concepts).

## Guide Steps

### Step 1

Create an API Management Service – In the Azure portal, create a new API Management instance. Go to Create a resource > Integration > API Management. Fill in the basics (resource group, service name, region, organization name, admin email, pricing tier) and create the service.

Please note that the **service name must be unique** across Azure, as it will be part of the public URL for your API Management instance (e.g., https://<service-name>.azure-api.net).

> The **Pricing tier** is important. For this lab, you can use the **Developer** tier, which is the cheapest and ideal for our hands-on lab. If you want to use the **Standard** or **Premium** tiers, please ensure you have the necessary permissions and budget.

> API Management stv2 services can take ~30-40 minutes to deploy, so plan accordingly. Otherwise, using API Management v2 services will take 5 minutes to deploy, however, as there is no **Developer** tier available for v2 services, you will need to use the **Basic** tier, which is more expensive than the Developer tier.

![APIM deploy blade](images/apim-deploy-blade.png)

Please do not modify other settings. Specifically, the *Virtual network* tab should remain as **None**.

![APIM deploy blade Virtual Network tab](images/apim-deploy-blade-vnet.png)

Once started, it is not necessary to remain on this page or in the Azure Portal. If you entered a valid email address, you will receive a provisioning completion email:

![APIM creation email](images/apim-creation-email.png)

### Step 2

Add a Backend API – Once APIM is running, navigate to your API Management service and select APIs from the left menu.

![APIM APIs](images/apim-apis.png)

For this lab you will use the existing [*Star Wars* API](https://swapi.py4e.com/api/):

1) Click on **Add API**.  
2) Click on **HTTP - Manually define an HTTP API**.  
3) Select the **Full** option in the **Create an HTTP API** dialog.  
4) Enter **Display name** `Star Wars`, **Name** `star-wars`, and, optionally, **Description**.  
5) Assign `https://swapi.py4e.com/api/` to the **Web service URL**.  
6) Keep the **URL scheme** at `HTTPS` as we strive to enforce HTTPS only.  
7) Set the **API URL suffix** to `sw`. This allows us to compartmentalize the Azure API Management URLs for distinct APIs.  
8) Assign **Starter** and **Unlimited** products.  
9) Press **Create**.  

  > While it is conventionally a good idea to version APIs from the onset, we are omitting this step here for brevity of the labs.

![APIM Add Blank API](images/apim-add-blank-api.png)

Once created, inside the *Star Wars* API press **+ Add operation** to declare two new operations:

1) **Get People**

- Display name: **Get People**  
- Name will be populate with: **get-people**  
- URL: **GET /people/**  

2) **Get People By Id**

- Display name: **Get People By Id**  
- Name will be populate with: **get-people-by-id**  
- URL: **GET /people/{id}/**  

![APIM Star Wars API Add Operation](images/apim-star-wars-api-add-operation.png)

### Step 3

Let's add another API, the [Colors API](https://colors-api.azurewebsites.net/swagger/v1/swagger.json).

![APIM Colors API](images/apim-add-color-api.png)

- Create a new API with OpenAPI specification and import swagger from <https://colors-api.azurewebsites.net/swagger/v1/swagger.json>. 
- This time we will choose to not provide API URL suffix. Without API URL suffix, there could be endpoint conflicts, you can always leverage [rewrite-uri](https://learn.microsoft.com/en-us/azure/api-management/api-management-transformation-policies#RewriteURL) policy to convert a request URL form to the form expected by the backend web service. 

  ![APIM Add Colors API](images/apim-add-color-api-1.png)

  ![APIM Add Colors API](images/apim-add-color-api-2.png)

- We can test the newly-added API from the **Test** tab. Note the successful `200` response.

  ![APIM Test Colors API](images/apim-test-color-api.png)

- Products can be configured after the API is initially created as well. On the **Settings** tab, set **Products** to include **Starter** and **Unlimited**, then press **Save**.

  ![APIM Colors API Add Products](images/apim-color-api-add-products.png)

- Optional: Test other APIs from the **Test** tab.

### Step 4

Azure API Management uses **rate limiting** to protect APIs from being overwhelmed and helps prevent exposure to DDoS attacks. As Azure API Management sits in between your API and their callers, it effectively governs access to your APIs.  

  ![APIM Test Colors API](images/apim-test-color-api.png)

We can test the **Get random color API** from the **Test** tab. Select the **Unlimited** product and press **Send**. Note the successful `200` response. Repeat pressing **Send** multiple times (greater than 5 times). Notice that the rate limiting is not applied to the **Unlimited** product, so you will continue to receive `200 OK` responses.

Repeat testing the **Get random color API** from the **Test** tab, however this time select the **Starter** product and press **Send**. Note the successful `200` response initially. Repeat pressing **Send** multiple times (greater than 5 times). Notice that after a few requests, you will receive a `429 Too Many Requests` response, indicating that the rate limit has been reached.

### Step 5

Optional: Explore the **Policies** tab for the *Star Wars* API. Policies allow you to modify the behavior of your API Management instance, such as adding headers, transforming requests/responses, or enforcing security measures. Find where the rate limiting policy is applied. You can also add custom policies to control how requests are processed. Which other policies can you apply?

## Conclusion

By completing these steps, you have created an API Management instance, published a simple backend API, and tested an API call. You’ve learned how APIM can quickly front existing services with a consistent API endpoint. This skill is foundational for exposing integration workflows and services to external or internal consumers in a controlled manner.
