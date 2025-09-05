@minLength(1)
@description('Location for all resources')
param location string = resourceGroup().location

@description('Name of the Service Bus')
@minLength(1)
param servicebus_name string = 'servicebus-aishol'

@description('SKU for the Service Bus namespace')
@allowed(['Basic', 'Standard', 'Premium'])
@minLength(1)
param servicebus_namespace_sku string = 'Standard'

param logAnalyticsWorkspaceId string

param tags object = {}

resource servicebus 'Microsoft.ServiceBus/namespaces@2024-01-01' = {
  name: servicebus_name
  location: location
  tags: tags
  sku: {
    name: servicebus_namespace_sku
    tier: servicebus_namespace_sku
  }
  properties: {
    premiumMessagingPartitions: 0
    minimumTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
    disableLocalAuth: false
    zoneRedundant: true
  }
}

resource servicebus_product_queue 'Microsoft.ServiceBus/namespaces/queues@2024-01-01' = {
  parent: servicebus
  name: 'product'
  properties: {
    maxMessageSizeInKilobytes: 256
    lockDuration: 'PT1M'
    maxSizeInMegabytes: 1024
    requiresDuplicateDetection: false
    requiresSession: false
    defaultMessageTimeToLive: 'P14D'
    deadLetteringOnMessageExpiration: false
    enableBatchedOperations: true
    duplicateDetectionHistoryTimeWindow: 'PT10M'
    maxDeliveryCount: 10
    status: 'Active'
    autoDeleteOnIdle: 'P10675199DT2H48M5.4775807S'
    enablePartitioning: false
    enableExpress: false
  }
}

resource servicebus_notification_queue 'Microsoft.ServiceBus/namespaces/queues@2024-01-01' = {
  parent: servicebus
  name: 'notification'
  properties: {
    maxMessageSizeInKilobytes: 256
    lockDuration: 'PT1M'
    maxSizeInMegabytes: 1024
    requiresDuplicateDetection: false
    requiresSession: false
    defaultMessageTimeToLive: 'P14D'
    deadLetteringOnMessageExpiration: false
    enableBatchedOperations: true
    duplicateDetectionHistoryTimeWindow: 'PT10M'
    maxDeliveryCount: 10
    status: 'Active'
    autoDeleteOnIdle: 'P10675199DT2H48M5.4775807S'
    enablePartitioning: false
    enableExpress: false
  }
}

resource serviceBusName_RootManageSharedAccessKey 'Microsoft.ServiceBus/namespaces/authorizationrules@2024-01-01' = {
  parent: servicebus
  name: 'RootManageSharedAccessKey'
  properties: {
    rights: [
      'Listen'
      'Manage'
      'Send'
    ]
  }
}

resource serviceBusDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'servicebus-diagnostics'
  scope: servicebus
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      { category: 'OperationalLogs', enabled: true }
    ]
    metrics: [
      { category: 'AllMetrics', enabled: true }
    ]
  }
}

// Note: These outputs are for running from local machine
output name string = servicebus.name
//@secure()
output serviceBusConnectionString string = serviceBusName_RootManageSharedAccessKey.listKeys().primaryConnectionString
