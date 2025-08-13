@minLength(1)
@description('Location for all resources')
param location string = resourceGroup().location

param storageAccountName string
param appServicePlanName string
param functionAppName string
param serviceBusName string
param logAnalyticsName string
param applicationInsightsName string

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
  serviceBusConnectionString__fullyQualifiedNamespace: '${serviceBusName}.servicebus.windows.net'
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

// Service Bus
resource serviceBus 'Microsoft.ServiceBus/namespaces@2024-01-01' = {
  name: serviceBusName
  location: location
  tags: tags
  sku: {
    name: 'Standard'
    tier: 'Standard'
  }
  properties: {
    premiumMessagingPartitions: 0
    minimumTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
    disableLocalAuth: false
    zoneRedundant: true
  }
}

// Diagnostics: Service Bus Namespace -> Log Analytics
resource serviceBusDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'servicebus-diagnostics'
  scope: serviceBus
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      { category: 'OperationalLogs', enabled: true }
    ]
    metrics: [
      { category: 'AllMetrics', enabled: true }
    ]
  }
}

resource serviceBusName_RootManageSharedAccessKey 'Microsoft.ServiceBus/namespaces/authorizationrules@2024-01-01' = {
  parent: serviceBus
  name: 'RootManageSharedAccessKey'
  properties: {
    rights: [
      'Listen'
      'Manage'
      'Send'
    ]
  }
}

resource serviceBusName_default 'Microsoft.ServiceBus/namespaces/networkrulesets@2024-01-01' = {
  parent: serviceBus
  name: 'default'
  properties: {
    publicNetworkAccess: 'Enabled'
    defaultAction: 'Allow'
    virtualNetworkRules: []
    ipRules: []
    trustedServiceAccessEnabled: false
  }
}

resource serviceBusName_productTopic 'Microsoft.ServiceBus/namespaces/topics@2024-01-01' = {
  parent: serviceBus
  name: 'product'
  properties: {
    maxMessageSizeInKilobytes: 256
    defaultMessageTimeToLive: 'P14D'
    maxSizeInMegabytes: 1024
    requiresDuplicateDetection: false
    duplicateDetectionHistoryTimeWindow: 'PT10M'
    enableBatchedOperations: true
    status: 'Active'
    supportOrdering: false
    autoDeleteOnIdle: 'P10675199DT2H48M5.4775807S'
    enablePartitioning: false
    enableExpress: false
  }
}

resource serviceBusName_productTopic_defaultSubscription 'Microsoft.ServiceBus/namespaces/topics/subscriptions@2024-01-01' = {
  parent: serviceBusName_productTopic
  name: 'default-subscription'
  properties: {
    isClientAffine: false
    lockDuration: 'PT1M'
    requiresSession: false
    defaultMessageTimeToLive: 'P14D'
    deadLetteringOnMessageExpiration: false
    deadLetteringOnFilterEvaluationExceptions: false
    maxDeliveryCount: 10
    status: 'Active'
    enableBatchedOperations: true
    autoDeleteOnIdle: 'P10675198DT2H48M5.477S'
  }
}

resource serviceBusName_productTopic_defaultSubscription_defaultRule 'Microsoft.ServiceBus/namespaces/topics/subscriptions/rules@2024-01-01' = {
  parent: serviceBusName_productTopic_defaultSubscription
  name: '$Default'
  properties: {
    action: {}
    filterType: 'SqlFilter'
    sqlFilter: {
      sqlExpression: '1=1'
      compatibilityLevel: 20
    }
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
            //storageAccountConnectionStringName: 'AzureWebJobsStorage__accountName'
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
    }
  }
  dependsOn: [ storageAccountForDeployment ]
}

module rbac 'rbac.bicep' = {
  name: 'rbacAssigments'
  params: {
    storageAccountName: storageAccount.name
    applicationInsightsName: applicationInsights.name
    managedIdentityPrincipalId: functionAppDeployment.outputs.?systemAssignedMIPrincipalId  ?? ''
    serviceBusName: serviceBus.name
  }
}


// Note: These outputs are for running from local machine
//@secure()
output serviceBusConnectionString string = serviceBusName_RootManageSharedAccessKey.listKeys().primaryConnectionString
