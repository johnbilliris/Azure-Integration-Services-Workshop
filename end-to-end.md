# Azure Integration Services Workshop

## End-to-End Integration Solution

Now that you have individual experience with APIM, Logic Apps, Functions, Service Bus, Dynamics 365, and Office 365. This lab will guide you through a scenario that combines all these skills together.

The scenario is a simplified new product announcement workflow for a fictitious application, where multiple Azure services work in concert:

- API Management: Exposes an "Product" API” to accept the new product. Azure Function (Product Intake): Receives the product submission, and places a 'new product' message on a Service Bus queue.
- Service Bus: Queues the 'new product' message to decouple and asynchronously process it.
- Logic App (Processor): Triggered by the queue message, it processes the new product (simulated by logging or transforming data) and then, for each Dynamics 365 Contact, queues an email message on a Service Bus queue.
- Logic App (Email): Triggered by the queue message, it sends out an email confirmation via Office 365 of the new product.

This integrated exercise will show how all six services can be used together to implement a cloud integration pattern. It mirrors real-world enterprise integration scenarios (for example, an HTTP API frontend feeding into a message-based workflow and using events to signal completion)

### Skill Objective: End-to-End Integration Solution

Learn to create an end-to-end Azure Integration Services solution that integrates multiple components.

## Guide Steps

### Step 0: Prerequisites

Before executing the steps, ensure you have the following resources ready (you created many of these in earlier exercises):

- An API Management instance.
- A Service Bus namespace with two queues (e.g., “product” and “notification”).
- A Dynamics 365 instance with a Contact entity.
- An Office 365 account for sending emails.
- Appropriate access/permissions: The Logic Apps and Function will need to connect to Service Bus. For simplicity, you can use shared access keys or managed identity. In a hands-on setting, using shared connection strings in the Logic App and a function output is straightforward.

### Step 1

Implement New Product Azure Function (API backend) – Implement a HTTP-triggered Azure Function that will handle the payload from Azure API Management. In your Function App, add a new Function with a HTTP trigger (use VS Code). The function should be set to trigger on the HTTP POST verb. (Provide the connection string or use the ServiceBus connection setting, and queue name in function configuration.) In the function code, parse the product payload and perform a stub “processing” – for example, create a new globally unique product ID or perform any transformation. Then, as part of processing, have the function send a message to Service Bus. You can do this by using the Service Bus output binding, the Service Bus SDK, or by calling the Service Bus REST API.

### Step 2

Expose Azure Function via API Management – In your API Management instance, create a new API by importing the Function App. APIM can directly import a Function app as an API. Go to APIs > + Add API > Function App. Browse and select the “NewProductFunctionApp” you just built in Step 1, and name this API “Product API” and assign it a suffix like “products”. APIM will import the HTTP trigger as an operation in a new API (it auto-generates the OpenAPI definition). Once imported, you can see the operation – you can rename it to “NewProduct”. Now, developers/apps could call this via APIM’s endpoint (which is friendlier and governed by APIM policies).

### Step 3

1. Create a new Logic App (Consumption) named “NewProductLogicApp”. This logic app will handle the new product requests. In the Logic App designer, add a When a message is received in a queue (auto-complete) trigger. Design the expected JSON schema for a product if possible (or leave it freeform).
2. Add a List rows action to retrieve Contacts from Dynamics 365. Configure the connection to your Dynamics 365 instance and select the Contact entity. This will fetch all contacts.
3. Next, add a For each Control action.
4. Inside the For each, compose a email message and add a Service Bus action to send a message to the Service Bus "notification" queue. This will be used to enqueue the product data for further processing.

### Step 4

1. Create a new Logic App (Consumption) named “NotificationLogicApp”. This logic app will send an email of the new product to your Dynamics 365 contact. In the Logic App designer, add a When a message is received in a queue (auto-complete) trigger.
2. Add a Send an email (Office 365) action to send an email to the contact. Configure the connection to your Office 365 account. Use the email address from the Dynamics 365 Contact retrieved in the previous step. For the email body, include details about the new product (you can use dynamic content from the Service Bus message).

### Step 5

Test End-to-End Flow – Time to see everything in action. Use API Management’s Test console or a tool like cURL/Postman to call the Product API endpoint (the APIM gateway URL) with a sample order JSON. For example, POST a product:  { "ProductName":"Starfruit Explosion", "ProductDescription":"This starfruit ice cream is out of this world!"} to the APIM endpoint.

Through APIM, the request goes to the New Product Function (Step 1) which puts the message on the Service Bus queue (Step 2). Check the Service Bus queue in the portal – the message count should increment and then likely decrement shortly after as the Logic App picks it up.

The New Product Logic App (Step 3) will be triggered by the queue message; verify its logs to ensure it processed the message and a message is enqueued to the "notifications" queue.

Next, the Notification Logic App (Step 4) should trigger on that message. Check its run history – it should show a successful run triggered by the event, and the email action completed. Finally, confirm the notification (e.g., the confirmation email was received).

## Conclusion

You have now built and tested an integrated solution using several Azure Integration Services components together. This lab demonstrated how an API call can initiate a workflow via Logic App and Service Bus, with a Function handling back-end logic and Logic Apps using downstream external systems. Such patterns (API + queue + events) are common in real systems to achieve reliability and scalability. We used APIM for a consistent interface, Logic Apps for orchestration, Service Bus for decoupling and buffering, and Azure Functions for custom logic – aligning with the workshop’s objectives to “integrate, scale and monitor applications using Azure services like APIM, Logic Apps, Event Grid, Service Bus, Functions”.

**Congratulations on completing the end-to-end lab!**
