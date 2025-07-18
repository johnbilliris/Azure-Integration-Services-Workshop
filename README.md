# Azure Integration Services Workshop

## Workshop Context

The “Accelerating Innovation with Integration Services” workshop identifies five key digital skills for modern enterprise integration:

1. [Azure API Management (APIM)](/apim.md)
2. [Azure Logic Apps](/logicapps.md)
3. [Azure Functions](/functions.md)
4. [Azure Event Grid](/eventgrid.md)
5. [Azure Service Bus](/servicebus.md)

Each skill corresponds to a service in Azure Integration Services and is essential for successful cloud-based integration solutions. Below, we provide a detailed hands-on training guide for each digital skill, followed by a comprehensive lab that integrates all these skills into one scenario.

## Azure API Management (APIM) – Hands-On Guide

APIM allows organizations to publish and manage APIs at scale, acting as a secure front door to backend services. This hands-on exercise will guide you through creating an API Management instance, adding APIs, adding policies, and testing.

### Skill Objective: API Management

Learn how to create an API gateway, publish a backend service as an API, and apply basic operations and tests using Azure API Management.

[Click here to learn more about Azure API Management (APIM)](https://learn.microsoft.com/en-us/azure/api-management/)

## Azure Logic Apps – Hands-On Guide

Azure Logic Apps enable you to orchestrate workflows that integrate various services without writing code. In this guide, you will create two Logic Apps; one that triggers on a schedule and performs an action, and the other which receives a HTTP request, retrieves external data, and processes it. These teach the core concepts of triggers and actions in Logic Apps.

### Skill Objective: Logic Apps

Learn to build an automated workflow with a trigger and actions. This includes configuring a trigger (event or schedule) and adding steps such as sending an email or calling an API in a logic app.

[Click here to learn more about Azure Logic Apps](https://learn.microsoft.com/en-us/azure/logic-apps/)

## Azure Functions – Hands-On Guide

Azure Functions is a serverless compute service that lets you run code in response to events. In this guide, you’ll create a simple Function App and an HTTP-triggered function, then test it. This will illustrate how Functions can be used to run custom logic as part of an integration.

### Skill Objective: Functions

Learn to create a serverless function that runs on-demand. You will set up a Function App, create an HTTP-triggered function, and test it to see how custom code can integrate into workflows.

[Click here to learn more about Azure Functions](https://learn.microsoft.com/en-us/azure/azure-functions/)

## Azure Service Bus – Hands-On Guide

Azure Service Bus is a message queuing service for enterprise integration, enabling reliable messaging between services. In this guide, you’ll create a Service Bus namespace and queue, and learn how to send and receive messages using the built-in Service Bus Explorer tool. This covers the basics of queued messaging in integration scenarios.

### Skill Objective: Service Bus

Learn to provision a message queue and exchange messages. You will create a Service Bus namespace with a queue, then use the Service Bus Explorer to send a test message and receive it, demonstrating decoupled communication.

[Click here to learn more about Azure Service Bus](https://learn.microsoft.com/en-us/azure/service-bus-messaging/)

## Azure Event Grid – Hands-On Guide

Azure Event Grid is an event routing service that enables reactive, event-driven architectures. In this exercise, you will set up a custom Event Grid Topic, subscribe an Azure Function to it, and send a test event. This demonstrates how to use Event Grid to loosely couple event producers and consumers.

### Skill Objective: Event Grid

Learn to create a custom event stream and subscribe services to it. You will create an Event Grid Topic, configure a subscriber (Function), and publish a test event to observe end-to-end event handling.

[Click here to learn more about Azure Event Grid](https://learn.microsoft.com/en-us/azure/event-grid/)

## Putting It All Together

After completing the individual skill exercises, you will have a solid foundation in Azure Integration Services. The final lab will integrate all these skills into a cohesive scenario, demonstrating how to build an end-to-end integration solution using Azure AI Services.

[Click here to build an end to end integration solution](/end-to-end.md)
