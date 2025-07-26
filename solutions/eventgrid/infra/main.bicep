targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param environmentName string = 'azure'

@minLength(1)
@description('Location for all resources')
@allowed([
  'australiaeast'
  'australiasoutheast'
  'brazilsouth'
  'canadacentral'
  'centralindia'
  'centralus'
  'eastasia'
  'eastus'
  'eastus2'
  'eastus2euap'
  'francecentral'
  'germanywestcentral'
  'italynorth'
  'japaneast'
  'koreacentral'
  'northcentralus'
  'northeurope'
  'norwayeast'
  'southafricanorth'
  'southcentralus'
  'southeastasia'
  'southindia'
  'spaincentral'
  'swedencentral'
  'uaenorth'
  'uksouth'
  'ukwest'
  'westcentralus'
  'westeurope'
  'westus'
  'westus2'
  'westus3'
])
@metadata({
  azd: {
    type: 'location'
  }
})
param location string = 'australiaeast'

@description('Deployment time in UTC')
param deploymentTime string = utcNow()


var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))

@description('Name of the resource group for all resources')
var resourceGroupName = take('ais-hol-eventhub-${environmentName}-rg', 90)

@description('Name of the Event Hub')
var eventhub_name = take('eventhub-aishol-${resourceToken}', 50)

@description('SKU for the EventHub namespace')
// @allowed(['Basic', 'Standard', 'Premium'])
var eventhub_namespace_sku = 'Standard'

@description('Name of the Event Grid Namespace')
var eventgrid_name = take('evtgrid-aishol-${resourceToken}', 50)

@description('SKU for the Event Grid namespace')
// @allowed(['Basic', 'Standard'])
var eventgrid_namespace_sku = 'Standard'


var tags = { 'azd-env-name': environmentName 
            'azd-resource-group': resourceGroupName
            'azd-location': location
            'azd-deployment-time': deploymentTime }


var appServicePlanName = take('asp-aishol-${resourceToken}', 60)
var functionAppName = take('func-aishol-${resourceToken}', 60)
var storageAccountName = toLower(take('staishol${resourceToken}', 24)) // Storage account names must be between 3 and 24 characters long and can only contain lowercase letters and numbers
var logAnalyticsName = take('law-aishol-${resourceToken}', 63)
var applicationInsightsName = take('appinsights-aishol-${resourceToken}', 260)

// Create application settings
var appSettings = {
  AzureWebJobsStorage__accountName: storage.outputs.name
  AzureWebJobsStorage__blobServiceUri: storage.outputs.primaryBlobEndpoint
  AzureWebJobsStorage: storage.outputs.primaryConnectionString
  APPLICATIONINSIGHTS_CONNECTION_STRING: monitoring.outputs.connectionString
  EventStorage: storage.outputs.primaryConnectionString
  EventHubName: resources.outputs.eventHubName
  EventHubConsumerGroupName: resources.outputs.eventHubConsumerGroupName
  EventHubConnection: resources.outputs.eventHubConnectionString
}

// Organize resources in a resource group
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

module resources 'resources.bicep' = {
  name: 'resources'
  scope: rg
  params: {
    eventhub_name: eventhub_name
    eventhub_namespace_sku: eventhub_namespace_sku
    location: location
    eventgrid_name: eventgrid_name
    eventgrid_namespace_sku: eventgrid_namespace_sku
    tags: tags
    eventgridviewer_endpoint: '${eventGridViewer.outputs.appServiceEndpoint}/api/updates'
  }
}

module appServicePlan 'br/public:avm/res/web/serverfarm:0.1.1' = {
  name: 'appserviceplan'
  scope: rg
  params: {
    name: appServicePlanName
    sku: {
      name: 'FC1'
      tier: 'FlexConsumption'
    }
    reserved: true
    location: location
    tags: tags
  }
}

module function 'br/public:avm/res/web/site:0.15.1' = {
  name: '${functionAppName}-flex-consumption'
  scope: rg
  params: {
    kind: 'functionapp,linux'
    name: functionAppName
    location: location
    tags: union(tags, { 'azd-service-name': 'function'} )
    serverFarmResourceId: appServicePlan.outputs.resourceId
    managedIdentities: {
      systemAssigned: true
    }
    functionAppConfig: {
      deployment: {
        storage: {
          type: 'blobContainer'
          value: '${storage.outputs.primaryBlobEndpoint}events'
          authentication: {
            type: 'SystemAssignedIdentity'
          }
        }
      }
      scaleAndConcurrency: {
        instanceMemoryMB: 512
        maximumInstanceCount: 100
      }
      runtime: {
        name: 'dotnet-isolated'
        version: '8.0'
      }
    }
    siteConfig: {
      alwaysOn: false
    }
    virtualNetworkSubnetId: null
    appSettingsKeyValuePairs: appSettings
  }
}

module storage 'br/public:avm/res/storage/storage-account:0.25.1' = {
  name: 'storage'
  scope: rg
  params: {
    name: storageAccountName
    allowBlobPublicAccess: true
    allowSharedKeyAccess: true
    dnsEndpointType: 'Standard'
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
    blobServices: {
      containers: [{name: 'events'}]
    }
    minimumTlsVersion: 'TLS1_2'  // Enforcing TLS 1.2 for better security
    skuName: 'Standard_LRS'
    location: location
    tags: tags
  }
}

module logAnalytics 'br/public:avm/res/operational-insights/workspace:0.11.1' = {
  name: '${uniqueString(deployment().name, location)}-loganalytics'
  scope: rg
  params: {
    name: logAnalyticsName
    location: location
    tags: tags
    dataRetention: 30
  }
}
 
module monitoring 'br/public:avm/res/insights/component:0.6.0' = {
  name: '${uniqueString(deployment().name, location)}-appinsights'
  scope: rg
  params: {
    name: applicationInsightsName
    location: location
    tags: tags
    workspaceResourceId: logAnalytics.outputs.resourceId
    disableLocalAuth: true
  }
}

// RBAC
module rbac 'rbac.bicep' = {
  name: 'rbacAssigments'
  scope: rg
  params: {
    storageAccountName: storage.outputs.name
    appInsightsName: monitoring.outputs.name
    managedIdentityPrincipalId: function.outputs.?systemAssignedMIPrincipalId ?? ''
  }
}

// Event Grid Viewer application
var eventGridAppServicePlanName = take('asp-aishol-eventgridviewer-${resourceToken}', 60)
var eventGridAppName = take('app-aishol-eventgridviewer-${resourceToken}', 60)
module eventGridViewer 'eventgrid-viewer.bicep' = {
  name: 'eventGridViewer'
  scope: rg
  params: {
    hostingPlanName: eventGridAppServicePlanName
    siteName: eventGridAppName
    tags: tags
    location: location
  }
}


@description('Connection string for the Azure Storage Account. Output name matches the AzureWebJobsStorage key in local settings.')
#disable-next-line outputs-should-not-contain-secrets 
output AZUREWEBJOBSSTORAGE string = storage.outputs.primaryConnectionString
output EventHubName string = resources.outputs.eventHubName
output EventHubConsumerGroupName string = resources.outputs.eventHubConsumerGroupName
#disable-next-line outputs-should-not-contain-secrets 
output EventHubConnection string = resources.outputs.eventHubConnectionString
