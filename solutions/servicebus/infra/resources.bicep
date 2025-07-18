@minLength(1)
@description('Location for all resources')
param location string = 'australiaeast'

@description('Name of the Service Bus')
@minLength(1)
param servicebus_name string = 'servicebus-ais-hol'

@description('SKU for the Service Bus namespace')
@allowed(['Basic', 'Standard', 'Premium'])
@minLength(1)
param servicebus_namespace_sku string = 'Standard'

resource servicebus 'Microsoft.ServiceBus/namespaces@2024-01-01' = {
  name: servicebus_name
  location: location
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

resource servicebus_queue 'Microsoft.ServiceBus/namespaces/queues@2024-01-01' = {
  parent: servicebus
  name: 'myqueue'
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
