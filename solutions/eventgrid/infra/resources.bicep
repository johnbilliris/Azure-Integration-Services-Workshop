@minLength(1)
@description('Location for all resources')
param location string = resourceGroup().location

@description('Name of the Event Hub')
@minLength(6)
param eventhub_name string = 'eventhub-aishol'

@description('SKU for the Event Hub namespace')
@allowed(['Basic', 'Standard', 'Premium'])
@minLength(1)
param eventhub_namespace_sku string = 'Standard'

@description('Name of the Event Grid Namespace')
@minLength(6)
param eventgrid_name string = 'evtgrid-aishol'

@description('SKU for the Event Grid namespace')
@allowed(['Basic', 'Standard'])
@minLength(1)
param eventgrid_namespace_sku string = 'Standard'

param tags object = {}

@description('Endpoint for the Event Grid Viewer Application')
param eventgridviewer_endpoint string

resource eventgrid_name_resource 'Microsoft.EventGrid/namespaces@2025-04-01-preview' = {
  name: eventgrid_name
  location: location
  tags: tags
  sku: {
    name: eventgrid_namespace_sku
    capacity: 1
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    topicsConfiguration: {}
    isZoneRedundant: true
    publicNetworkAccess: 'Enabled'
    inboundIpRules: []
  }
}

resource eventgrid_name_incoming 'Microsoft.EventGrid/namespaces/topics@2025-04-01-preview' = {
  parent: eventgrid_name_resource
  name: 'incoming'
  properties: {
    publisherType: 'Custom'
    inputSchema: 'CloudEventSchemaV1_0'
    eventRetentionInDays: 7
  }
}

resource eventgrid_name_incoming_eventhub_subscription 'Microsoft.EventGrid/namespaces/topics/eventSubscriptions@2025-04-01-preview' = {
  parent: eventgrid_name_incoming
  name: 'eventhub-subscription'
  properties: {
    deliveryConfiguration: {
      deliveryMode: 'Push'
      push: {
        maxDeliveryCount: 10
        eventTimeToLive: 'P7D'
        deliveryWithResourceIdentity: {
          identity: {
            type: 'SystemAssigned'
          }
          destination: {
            properties: {
              resourceId: eventhub_name_events.id
              deliveryAttributeMappings: []
            }
            endpointType: 'EventHub'
          }
        }
      }
    }
    eventDeliverySchema: 'CloudEventSchemaV1_0'
    filtersConfiguration: {
      includedEventTypes: []
    }
  }
  dependsOn: [ roleAssignment ]
}

resource eventgrid_name_incoming_incoming_eventgridviewer_subscription 'Microsoft.EventGrid/namespaces/topics/eventSubscriptions@2025-04-01-preview' = {
  parent: eventgrid_name_incoming
  name: 'eventgridviewer-subscription'
  properties: {
    deliveryConfiguration: {
      deliveryMode: 'Push'
      push: {
        maxDeliveryCount: 10
        eventTimeToLive: 'P7D'
        destination: {
          properties: {
            maxEventsPerBatch: 1
            preferredBatchSizeInKilobytes: 64
            deliveryAttributeMappings: []
            endpointUrl: eventgridviewer_endpoint
          }
          endpointType: 'WebHook'
        }
      }
    }
    eventDeliverySchema: 'CloudEventSchemaV1_0'
    filtersConfiguration: {
      includedEventTypes: []
    }
  }
}

resource eventhub_name_resource 'Microsoft.EventHub/namespaces@2024-05-01-preview' = {
  name: eventhub_name
  location: location
  tags: tags
  sku: {
    name: eventhub_namespace_sku
    tier: eventhub_namespace_sku
    capacity: 1
  }
  properties: {
    geoDataReplication: {
      maxReplicationLagDurationInSeconds: 0
      locations: [
        {
          locationName: location
          roleType: 'Primary'
        }
      ]
    }
    minimumTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
    disableLocalAuth: false
    zoneRedundant: true
    isAutoInflateEnabled: false
    maximumThroughputUnits: 0
    kafkaEnabled: true
  }
}

resource eventhub_name_RootManageSharedAccessKey 'Microsoft.EventHub/namespaces/authorizationrules@2024-05-01-preview' = {
  parent: eventhub_name_resource
  name: 'RootManageSharedAccessKey'
  properties: {
    rights: [
      'Listen'
      'Manage'
      'Send'
    ]
  }
}

resource eventhub_name_events 'Microsoft.EventHub/namespaces/eventhubs@2024-05-01-preview' = {
  parent: eventhub_name_resource
  name: 'events'
  properties: {
    messageTimestampDescription: {
      timestampType: 'LogAppend'
    }
    retentionDescription: {
      cleanupPolicy: 'Delete'
      retentionTimeInHours: 1
    }
    messageRetentionInDays: 1
    partitionCount: 2
    status: 'Active'
  }
}

resource eventhub_name_default 'Microsoft.EventHub/namespaces/networkrulesets@2024-05-01-preview' = {
  parent: eventhub_name_resource
  name: 'default'
  properties: {
    publicNetworkAccess: 'Enabled'
    defaultAction: 'Allow'
    virtualNetworkRules: []
    ipRules: []
    trustedServiceAccessEnabled: false
  }
}

resource eventhub_name_events_Default 'Microsoft.EventHub/namespaces/eventhubs/consumergroups@2024-05-01-preview' = {
  parent: eventhub_name_events
  name: '$Default'
  properties: {}
}

resource eventhub_name_events_AzureFunction 'Microsoft.EventHub/namespaces/eventhubs/consumergroups@2024-05-01-preview' = {
  parent: eventhub_name_events
  name: 'azure-function'
  properties: {}
}


// Azure Event Hubs Data Sender	
// Allows send access to Azure Event Hubs resources.
var eventHubsDataSenderRoleDefinitionId = '2b629674-e913-4c01-ae53-ef4638d8f975'

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(eventhub_name_resource.id, eventgrid_name_resource.id, eventHubsDataSenderRoleDefinitionId)
  scope: eventhub_name_resource
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', eventHubsDataSenderRoleDefinitionId)
    principalId: eventgrid_name_resource.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

output eventHubName string = 'events'
@secure()
output eventHubConnectionString string = 'Endpoint=sb://${eventhub_name}.servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=${eventhub_name_RootManageSharedAccessKey.listKeys().primaryKey}'
output eventHubConsumerGroupName string = 'azure-function'
