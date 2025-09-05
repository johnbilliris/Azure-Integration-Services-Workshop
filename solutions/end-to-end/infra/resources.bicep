@minLength(1)
@description('Location for all resources')
param location string = resourceGroup().location

@description('Name of the API Management')
@minLength(1)
param apimName string = 'apim-aishol'

@description('SKU for the API Management')
@allowed(['Developer', 'Basic', 'Standard', 'Premium'])
@minLength(1)
param apim_sku string = 'Developer'

@description('Email address of the API Management publisher')
@minLength(1)
param publisherEmail string

@description('Name of the Service Bus')
@minLength(1)
param serviceBusName string = 'servicebus-aishol'

@description('SKU for the Service Bus namespace')
@allowed(['Basic', 'Standard', 'Premium'])
@minLength(1)
param serviceBusNamespaceSku string = 'Standard'

param storageAccountName string
param appServicePlanName string
param functionAppName string
param logAnalyticsName string
param applicationInsightsName string

param connections_office365_name string = 'office365'
param connections_serviceBus_name string = 'serviceBus'
param workflows_NewProductLogicApp_name string = 'NewProductLogicApp'
param workflows_Notifications_name string = 'Notifications'
@minLength(1)
@description('Email recipient for notifications')
param email_recipient string


param tags object = {}


// Create application settings
// Note: These app settings are for the Azure deployment, not for running from local machine
var appSettings = {
  APPLICATIONINSIGHTS_CONNECTION_STRING: applicationInsights.properties.ConnectionString
  AzureWebJobsStorage__accountName: storageAccount.name
  AzureWebJobsStorage__blobServiceUri: storageAccount.properties.primaryEndpoints.blob
  AzureWebJobsStorage__queueServiceUri: storageAccount.properties.primaryEndpoints.queue
  AzureWebJobsStorage__tableServiceUri: storageAccount.properties.primaryEndpoints.table
  DEPLOYMENT_STORAGE_CONNECTION_STRING: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
  ServiceBusConnection__fullyQualifiedNamespace: '${serviceBusName}.servicebus.windows.net'
}

// Service Bus
// Need Log Analytics workspace to be deployed prior
module serviceBusDeployment 'servicebus.bicep' = {
  name: 'serviceBusDeployment'
  params: {
    location: location
    servicebus_name: serviceBusName
    servicebus_namespace_sku: serviceBusNamespaceSku
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    tags: tags
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2025-01-01' = {
  name: storageAccountName
  location: location
  tags: tags
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'Storage'
  properties: {
    defaultToOAuthAuthentication: true
    publicNetworkAccess: 'Enabled'
    allowCrossTenantReplication: false
    isLocalUserEnabled: false
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
    networkAcls: {
      resourceAccessRules: []
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Allow'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
  }
}

resource storageAccountName_default 'Microsoft.Storage/storageAccounts/blobServices@2025-01-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    containerDeleteRetentionPolicy: {
      enabled: true
      days: 7
    }
    cors: {
      corsRules: []
    }
    deleteRetentionPolicy: {
      allowPermanentDelete: false
      enabled: true
      days: 7
    }
  }
}

resource storageAccountForDeployment 'Microsoft.Storage/storageAccounts/blobServices/containers@2025-01-01' = {
  parent: storageAccountName_default
  name: 'app-package-${functionAppName}-02496a5'
  properties: {
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'None'
  }
}


// Log Analytics Workspace
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2025-02-01' = {
  name: logAnalyticsName
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'pergb2018'
    }
    retentionInDays: 30
    features: {
      legacy: 0
      searchVersion: 1
      enableLogAccessUsingOnlyResourcePermissions: true
    }
    workspaceCapping: {
      dailyQuotaGb: json('-1')
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

// Application Insights
resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Flow_Type: 'Redfield'
    Request_Source: 'IbizaAIExtension'
    RetentionInDays: 90
    WorkspaceResourceId: logAnalyticsWorkspace.id
    IngestionMode: 'LogAnalytics'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

module appServicePlan 'br/public:avm/res/web/serverfarm:0.5.0' = {
  name: 'appServicePlanDeployment'
  params: {
    name: appServicePlanName
    location: location
    kind: 'functionapp'
    tags: tags
    skuName: 'FC1'
    skuCapacity: 0
    zoneRedundant: false
    reserved: true
  }
}

module functionAppDeployment 'br/public:avm/res/web/site:0.19.0' = {
  name: 'functionAppDeployment'
  params: {
    // Required parameters
    kind: 'functionapp'
    name: functionAppName
    serverFarmResourceId: appServicePlan.outputs.resourceId
    // Non-required parameters
    basicPublishingCredentialsPolicies: [
      {
        allow: true
        name: 'ftp'
      }
      {
        allow: true
        name: 'scm'
      }
    ]
    configs: [
      {
        applicationInsightResourceId: applicationInsights.id
        name: 'appsettings'
        properties: appSettings
        storageAccountResourceId: storageAccount.id
        storageAccountUseIdentityAuthentication: true
      }
    ]
    diagnosticSettings: [
      {
        metricCategories: [
          {
            category: 'AllMetrics'
          }
        ]
        logCategoriesAndGroups: [
          {
            category: 'FunctionAppLogs'
          }
        ]
        name: 'functionapp-diagnostics'
        workspaceResourceId: logAnalyticsWorkspace.id
      }
    ]
    functionAppConfig: {
      deployment: {
        storage: {
          type: 'blobcontainer'
          value: 'https://${storageAccount.name}.blob.core.windows.net/app-package-${functionAppName}-02496a5'
          authentication: {
            type: 'SystemAssignedIdentity'
          }
        }
      }
      runtime: {
        name: 'dotnet-isolated'
        version: '8.0'
      }
      scaleAndConcurrency: {
        maximumInstanceCount: 100
        instanceMemoryMB: 512
      }
    }
    location: location
    managedIdentities: {
      systemAssigned: true
    }
    tags: union(tags, {
      'azd-service-name': 'function'
    })
    siteConfig: {
      alwaysOn: false
      use32BitWorkerProcess: false
      cors: {
        allowedOrigins: [
          'https://portal.azure.com'
          'https://${apimName}.azure-api.net'
        ]
        supportCredentials: false
      }
    }
  }
  dependsOn: [ storageAccountForDeployment ]
}

resource functionApp 'Microsoft.Web/sites@2024-11-01' existing = {
  name: functionAppName
  dependsOn: [ functionAppDeployment ]
}

var managedIdentities array = [
  functionApp.identity.principalId
  newProductLogicAppDeployment.outputs.principalId
  notificationLogicAppDeployment.outputs.principalId
]

module rbac 'rbac.bicep' = {
  name: 'rbacAssignments'
  params: {
    storageAccountName: storageAccount.name
    applicationInsightsName: applicationInsights.name
    managedIdentityPrincipalIds: managedIdentities
    serviceBusName: serviceBusDeployment.outputs.name
  }
}

resource apim 'Microsoft.ApiManagement/service@2024-06-01-preview' = {
  name: apimName
  location: location
  tags: tags
  sku: {
    name: apim_sku
    capacity: 1
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publisherEmail: publisherEmail
    publisherName: 'Microsoft'
    notificationSenderEmail: 'apimgmt-noreply@mail.windowsazure.com'
    virtualNetworkType: 'None'
    apiVersionConstraint: {
      minApiVersion: '2021-08-01'
    }
  }
}

resource administrators 'Microsoft.ApiManagement/service/groups@2024-06-01-preview' = {
  parent: apim
  name: 'administrators'
  properties: {
    displayName: 'Administrators'
    description: 'Administrators is a built-in group containing the admin email account provided at the time of service creation. Its membership is managed by the system.'
    type: 'system'
  }
}

resource developers 'Microsoft.ApiManagement/service/groups@2024-06-01-preview' = {
  parent: apim
  name: 'developers'
  properties: {
    displayName: 'Developers'
    description: 'Developers is a built-in group. Its membership is managed by the system. Signed-in users fall into this group.'
    type: 'system'
  }
}

resource guests 'Microsoft.ApiManagement/service/groups@2024-06-01-preview' = {
  parent: apim
  name: 'guests'
  properties: {
    displayName: 'Guests'
    description: 'Guests is a built-in group. Its membership is managed by the system. Unauthenticated users visiting the developer portal fall into this group.'
    type: 'system'
  }
}

resource starter 'Microsoft.ApiManagement/service/products@2024-06-01-preview' = {
  parent: apim
  name: 'starter'
  properties: {
    displayName: 'Starter'
    description: 'Subscribers will be able to run 5 calls/minute up to a maximum of 100 calls/week.'
    subscriptionRequired: true
    approvalRequired: false
    subscriptionsLimit: 1
    state: 'published'
  }
}

resource unlimited 'Microsoft.ApiManagement/service/products@2024-06-01-preview' = {
  parent: apim
  name: 'unlimited'
  properties: {
    displayName: 'Unlimited'
    description: 'Subscribers have completely unlimited access to the API. Administrator approval is required.'
    subscriptionRequired: true
    approvalRequired: true
    subscriptionsLimit: 1
    state: 'published'
  }
}

resource product 'Microsoft.ApiManagement/service/products@2024-06-01-preview' = {
  parent: apim
  name: 'product'
  properties: {
    displayName: 'Products'
    description: 'Subscribers have access to the Products API. Administrator approval is required.'
    subscriptionRequired: true
    approvalRequired: true
    subscriptionsLimit: 1
    state: 'published'
  }
}

resource product_product_api 'Microsoft.ApiManagement/service/products/apis@2024-06-01-preview' = {
  parent: product
  name: 'product-api'
  dependsOn: [ productApi ]
}

resource starter_administrators 'Microsoft.ApiManagement/service/products/groups@2024-06-01-preview' = {
  parent: starter
  name: 'administrators'
  dependsOn: [ administrators]
}

resource unlimited_administrators 'Microsoft.ApiManagement/service/products/groups@2024-06-01-preview' = {
  parent: unlimited
  name: 'administrators'
  dependsOn: [ administrators]
}

resource starter_developers 'Microsoft.ApiManagement/service/products/groups@2024-06-01-preview' = {
  parent: starter
  name: 'developers'
  dependsOn: [ developers]
}

resource unlimited_developers 'Microsoft.ApiManagement/service/products/groups@2024-06-01-preview' = {
  parent: unlimited
  name: 'developers'
  dependsOn: [ developers]
}

resource starter_guests 'Microsoft.ApiManagement/service/products/groups@2024-06-01-preview' = {
  parent: starter
  name: 'guests'
  dependsOn: [ guests]
}

resource unlimited_guests 'Microsoft.ApiManagement/service/products/groups@2024-06-01-preview' = {
  parent: unlimited
  name: 'guests'
  dependsOn: [ guests]
}

resource starter_policy 'Microsoft.ApiManagement/service/products/policies@2024-06-01-preview' = {
  parent: starter
  name: 'policy'
  properties: {
    value: '<!--\r\n            IMPORTANT:\r\n            - Policy elements can appear only within the <inbound>, <outbound>, <backend> section elements.\r\n            - Only the <forward-request> policy element can appear within the <backend> section element.\r\n            - To apply a policy to the incoming request (before it is forwarded to the backend service), place a corresponding policy element within the <inbound> section element.\r\n            - To apply a policy to the outgoing response (before it is sent back to the caller), place a corresponding policy element within the <outbound> section element.\r\n            - To add a policy position the cursor at the desired insertion point and click on the round button associated with the policy.\r\n            - To remove a policy, delete the corresponding policy statement from the policy document.\r\n            - Position the <base> element within a section element to inherit all policies from the corresponding section element in the enclosing scope.\r\n            - Remove the <base> element to prevent inheriting policies from the corresponding section element in the enclosing scope.\r\n            - Policies are applied in the order of their appearance, from the top down.\r\n        -->\r\n<policies>\r\n  <inbound>\r\n    <rate-limit calls="5" renewal-period="60" />\r\n    <quota calls="100" renewal-period="604800" />\r\n    <base />\r\n  </inbound>\r\n  <backend>\r\n    <base />\r\n  </backend>\r\n  <outbound>\r\n    <base />\r\n  </outbound>\r\n</policies>'
    format: 'xml'
  }
}

// Product APIs
resource productApi 'Microsoft.ApiManagement/service/apis@2024-06-01-preview' = {
  parent: apim
  name: 'product-api'
  properties: {
    displayName: 'Products API'
    apiRevision: '1'
    description: 'Products API'
    subscriptionRequired: true
    protocols: [
      'https'
    ]
    authenticationSettings: {
      oAuth2AuthenticationSettings: []
      openidAuthenticationSettings: []
    }
    subscriptionKeyParameterNames: {
      header: 'Ocp-Apim-Subscription-Key'
      query: 'subscription-key'
    }
    isCurrent: true
    path: 'product'
  }
}

resource productApiOperation 'Microsoft.ApiManagement/service/apis/operations@2024-06-01-preview' = {
  parent: productApi
  name: 'post-product'
  properties: {
    displayName: 'Product'
    method: 'POST'
    urlTemplate: '/'
    templateParameters: []
    responses: []
  }
}

resource productApiPolicy 'Microsoft.ApiManagement/service/apis/policies@2024-06-01-preview' = {
  parent: productApi
  name: 'policy'
  properties: {
    value: '<!--\r\n    - Policies are applied in the order they appear.\r\n    - Position <base/> inside a section to inherit policies from the outer scope.\r\n    - Comments within policies are not preserved.\r\n-->\r\n<!-- Add policies as children to the <inbound>, <outbound>, <backend>, and <on-error> elements -->\r\n<policies>\r\n  <!-- Throttle, authorize, validate, cache, or transform the requests -->\r\n  <inbound>\r\n    <base />\r\n    <set-backend-service backend-id="${functionApp.name}" />\r\n  <set-header name="Content-Type" exists-action="override">\r\n      <value>application/json</value>\r\n    </set-header>\r\n  </inbound>\r\n  <!-- Control if and how the requests are forwarded to services  -->\r\n  <backend>\r\n    <base />\r\n  </backend>\r\n  <!-- Customize the responses -->\r\n  <outbound>\r\n    <base />\r\n  </outbound>\r\n  <!-- Handle exceptions and customize error responses  -->\r\n  <on-error>\r\n    <base />\r\n  </on-error>\r\n</policies>'
    format: 'xml'
  }
  dependsOn: [productBackend]
}

resource productBackend 'Microsoft.ApiManagement/service/backends@2024-06-01-preview' = {
  parent: apim
  name: functionAppName 
  properties: {
    description: functionAppName
    url: 'https://${functionApp.name}.azurewebsites.net/api/product'
    protocol: 'http'
    resourceId: 'https://management.azure.com/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Web/sites/${functionAppName}'
    credentials: {
      header: {
        'x-functions-key': [
          '{{${functionApp.name}-key}}'
        ]
      }
    }
  }
  dependsOn: [productNamedValue]
}

resource productNamedValue 'Microsoft.ApiManagement/service/namedValues@2024-06-01-preview' = {
  parent: apim
  name: '${functionAppName}-key'
  properties: {
    displayName: '${functionAppName}-key'
    tags: [
      'key'
      'function'
      'auto'
    ]
    secret: true
    value: listKeys('${functionApp.id}/host/default', '2024-11-01').functionKeys.default
  }
}

resource apimLogger 'Microsoft.ApiManagement/service/loggers@2024-06-01-preview' = {
  parent: apim
  name: applicationInsightsName
  properties: {
    loggerType: 'applicationInsights'
    credentials: {
      instrumentationKey: '{{Logger-Credentials}}'
    }
    isBuffered: true
    resourceId: applicationInsights.id
  }
  dependsOn: [apimLoggerCredentials]
}

resource apimLoggerCredentials 'Microsoft.ApiManagement/service/namedValues@2024-06-01-preview' = {
  parent: apim
  name: '68a80eea217d200e00c872f9'
  properties: {
    displayName: 'Logger-Credentials'
    secret: true
    value: applicationInsights.properties.InstrumentationKey
  }
}

resource apimAzureMonitor 'Microsoft.ApiManagement/service/loggers@2024-06-01-preview' = {
  parent: apim
  name: 'azuremonitor'
  properties: {
    loggerType: 'azureMonitor'
    isBuffered: true
  }
}

resource productApiApplicationInsights 'Microsoft.ApiManagement/service/apis/diagnostics@2024-06-01-preview' = {
  parent: productApi
  name: 'applicationinsights'
  properties: {
    alwaysLog: 'allErrors'
    httpCorrelationProtocol: 'Legacy'
    verbosity: 'information'
    logClientIp: true
    loggerId: apimLogger.id
    sampling: {
      samplingType: 'fixed'
      percentage: json('100')
    }
    frontend: {
      request: {
        headers: []
        body: {
          bytes: 0
        }
      }
      response: {
        headers: []
        body: {
          bytes: 0
        }
      }
    }
    backend: {
      request: {
        headers: []
        body: {
          bytes: 0
        }
      }
      response: {
        headers: []
        body: {
          bytes: 0
        }
      }
    }
  }
}

resource apimApplicationinsights 'Microsoft.ApiManagement/service/diagnostics@2024-06-01-preview' = {
  parent: apim
  name: 'applicationinsights'
  properties: {
    alwaysLog: 'allErrors'
    httpCorrelationProtocol: 'Legacy'
    logClientIp: true
    loggerId: apimLogger.id
    sampling: {
      samplingType: 'fixed'
      percentage: json('100')
    }
    frontend: {
      request: {
        dataMasking: {
          queryParams: [
            {
              value: '*'
              mode: 'Hide'
            }
          ]
        }
      }
    }
    backend: {
      request: {
        dataMasking: {
          queryParams: [
            {
              value: '*'
              mode: 'Hide'
            }
          ]
        }
      }
    }
  }
}

resource connections_office365 'Microsoft.Web/connections@2016-06-01' = {
  name: connections_office365_name
  location: location
  tags: tags
  #disable-next-line BCP187
  kind: 'V1'
  properties: {
    displayName: email_recipient
    api: {
      name: connections_office365_name
      displayName: 'Office 365 Outlook'
      description: 'Microsoft Office 365 is a cloud-based service that is designed to help meet your organization\'s needs for robust security, reliability, and user productivity.'
      iconUri: 'https://conn-afd-prod-endpoint-bmc9bqahasf3grgk.b01.azurefd.net/v1.0.1757/1.0.1757.4256/${connections_office365_name}/icon.png'
      brandColor: '#0078D4'
      id: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Web/locations/${location}/managedApis/${connections_office365_name}'
      type: 'Microsoft.Web/locations/managedApis'
    }
    testLinks: [
      {
        #disable-next-line no-hardcoded-env-urls
        requestUri: 'https://management.azure.com:443/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Web/connections/${connections_office365_name}/extensions/proxy/testconnection?api-version=2016-06-01'
        method: 'get'
      }
    ]
  }
}

resource connections_serviceBus 'Microsoft.Web/connections@2016-06-01' = {
  name: connections_serviceBus_name
  location: location
  tags: tags
  #disable-next-line BCP187
  kind: 'V1'
  properties: {
    displayName: 'connectionServiceBus'
    api: {
      name: connections_serviceBus_name
      displayName: 'Service Bus'
      description: 'Connect to Azure Service Bus to send and receive messages. You can perform actions such as send to queue, send to topic, receive from queue, receive from subscription, etc.'
      iconUri: 'https://conn-afd-prod-endpoint-bmc9bqahasf3grgk.b01.azurefd.net/v1.0.1751/1.0.1751.4207/${connections_serviceBus_name}/icon.png'
      id: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Web/locations/${location}/managedApis/${connections_serviceBus_name}'
      type: 'Microsoft.Web/locations/managedApis'
    }
    #disable-next-line BCP089
    parameterValueSet: {
      name: 'managedIdentityAuth'
      values: {
        namespaceEndpoint: {
          value: 'sb://${serviceBusDeployment.outputs.name}.servicebus.windows.net/'
        }
      }
    }
    testLinks: []
  }
}


module newProductLogicAppDeployment 'workflow.bicep' = {
  name: 'newProductLogicAppDeployment'
  params: {
    workflowName: workflows_NewProductLogicApp_name
    location: location
    tags: tags
  }
  dependsOn: [ connections_serviceBus ]
}

module newProductLogicAppDeploymentPostRbac 'workflow.bicep' = {
  name: 'newProductLogicAppDeploymentPostRbac'
  dependsOn: [ rbac ]
  params: {
    workflowName: workflows_NewProductLogicApp_name
    location: location
    tags: tags
    definition: {
      '$schema': 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'
      contentVersion: '1.0.0.0'
      parameters: {
        '$connections': {
          defaultValue: {}
          type: 'Object'
        }
      }
      triggers: {
        'When_a_message_is_received_in_a_queue_(auto-complete)': {
          recurrence: {
            interval: 3
            frequency: 'Minute'
          }
          evaluatedRecurrence: {
            interval: 3
            frequency: 'Minute'
          }
          type: 'ApiConnection'
          inputs: {
            host: {
              connection: {
                name: '@parameters(\'$connections\')[\'servicebus\'][\'connectionId\']'
              }
            }
            method: 'get'
            path: '/@{encodeURIComponent(encodeURIComponent(\'product\'))}/messages/head'
            queries: {
              queueType: 'Main'
            }
          }
        }
      }
      actions: {
        Parse_JSON: {
          runAfter: {}
          type: 'ParseJson'
          inputs: {
            content: '@triggerBody()'
            schema: {
              type: 'object'
              properties: {
                id: {
                  type: 'string'
                }
                name: {
                  type: 'string'
                }
                description: {
                  type: 'string'
                }
                price: {
                  type: 'number'
                }
              }
            }
          }
        }
        Initialize_variables: {
          runAfter: {
            Parse_JSON: [
              'Succeeded'
            ]
          }
          type: 'InitializeVariable'
          inputs: {
            variables: [
              {
                name: 'varContacts'
                type: 'array'
                value: [
                  {
                    firstname: 'john'
                    lastname: 'billiris'
                    emailaddress1: 'john@thebestcompany.com'
                  }
                  {
                    firstname: 'anna'
                    lastname: 'smith'
                    emailaddress1: 'anna@thebestcompany.com'
                  }
                ]
              }
            ]
          }
        }
        For_each: {
          foreach: '@variables(\'varContacts\')'
          actions: {
            Compose: {
              type: 'Compose'
              inputs: {
                to: '@{items(\'For_each\')?[\'emailaddress1\']}'
                subject: 'New Product Confirmation - @{body(\'Parse_JSON\')?[\'name\']}'
                body: 'Dear @{items(\'For_each\')?[\'firstname\']}, A new product has been received...'
                productId: '@{body(\'Parse_JSON\')?[\'id\']}'
                customerName: '@{items(\'For_each\')?[\'firstname\']} @{items(\'For_each\')?[\'lastname\']}'
              }
            }
            Send_message: {
              runAfter: {
                Compose: [
                  'Succeeded'
                ]
              }
              type: 'ApiConnection'
              inputs: {
                host: {
                  connection: {
                    name: '@parameters(\'$connections\')[\'servicebus\'][\'connectionId\']'
                  }
                }
                method: 'post'
                body: {
                  ContentData: '@base64(outputs(\'Compose\'))'
                }
                path: '/@{encodeURIComponent(encodeURIComponent(\'notification\'))}/messages'
                queries: {
                  systemProperties: 'None'
                }
              }
            }
          }
          runAfter: {
            Initialize_variables: [
              'Succeeded'
            ]
          }
          type: 'Foreach'
        }
      }
      outputs: {}
    }
    parameters: {
      '$connections': {
        value: {
          servicebus: {
            id: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Web/locations/${location}/managedApis/servicebus'
            connectionId: connections_serviceBus.id
            connectionName: 'servicebus'
            connectionProperties: {
              authentication: {
                type: 'ManagedServiceIdentity'
              }
            }
          }
        }
      }
    }
  }
}

module notificationLogicAppDeployment 'workflow.bicep' = {
  name: 'notificationLogicAppDeployment'
  params: {
    workflowName: workflows_Notifications_name
    location: location
    tags: tags
  }
   dependsOn: [ connections_serviceBus, connections_office365 ]
}

module notificationLogicAppDeploymentPostRbac 'workflow.bicep' = {
  name: 'notificationLogicAppDeploymentPostRbac'
  dependsOn: [ rbac ]
  params: {
    workflowName: workflows_Notifications_name
    location: location
    tags: tags
        definition: {
      '$schema': 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'
      contentVersion: '1.0.0.0'
      parameters: {
        '$connections': {
          defaultValue: {}
          type: 'Object'
        }
      }
      triggers: {
        'When_a_message_is_received_in_a_queue_(auto-complete)': {
          recurrence: {
            interval: 3
            frequency: 'Minute'
          }
          evaluatedRecurrence: {
            interval: 3
            frequency: 'Minute'
          }
          type: 'ApiConnection'
          inputs: {
            host: {
              connection: {
                name: '@parameters(\'$connections\')[\'servicebus\'][\'connectionId\']'
              }
            }
            method: 'get'
            path: '/@{encodeURIComponent(encodeURIComponent(\'notification\'))}/messages/head'
            queries: {
              queueType: 'Main'
            }
          }
        }
      }
      actions: {
        Parse_JSON: {
          runAfter: {}
          type: 'ParseJson'
          inputs: {
            content: '@decodeBase64(triggerBody()?[\'ContentData\'])'
            schema: {
              type: 'object'
              properties: {
                to: {
                  type: 'string'
                }
                subject: {
                  type: 'string'
                }
                body: {
                  type: 'string'
                }
                productId: {
                  type: 'string'
                }
                customerName: {
                  type: 'string'
                }
              }
            }
          }
        }
        'Send_an_email_(V2)': {
          runAfter: {
            Parse_JSON: [
              'Succeeded'
            ]
          }
          type: 'ApiConnection'
          inputs: {
            host: {
              connection: {
                name: '@parameters(\'$connections\')[\'office365\'][\'connectionId\']'
              }
            }
            method: 'post'
            body: {
              To: '@body(\'Parse_JSON\')?[\'to\']'
              Subject: '@body(\'Parse_JSON\')?[\'subject\']'
              Body: '<p class="editor-paragraph">@{body(\'Parse_JSON\')?[\'subject\']}</p>'
              Importance: 'Normal'
            }
            path: '/v2/Mail'
          }
        }
      }
      outputs: {}
    }
    parameters: {
      '$connections': {
        value: {
           servicebus: {
            id: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Web/locations/${location}/managedApis/servicebus'
            connectionId: connections_serviceBus.id
            connectionName: 'servicebus'
            connectionProperties: {
              authentication: {
                type: 'ManagedServiceIdentity'
              }
            }
          }
          office365: {
            id: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Web/locations/${location}/managedApis/office365'
            connectionId: connections_office365.id
            connectionName: 'office365'
          }
        }
      }
    }
  }
}

// Note: These outputs are for running from local machine
//@secure()
output serviceBusConnectionString string = serviceBusDeployment.outputs.serviceBusConnectionString
