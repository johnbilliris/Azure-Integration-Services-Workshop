targetScope = 'subscription'

@minLength(1)
@description('Name of the resource group for all resources')
param resourceGroupName string

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

// Organize resources in a resource group
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
}

module resources 'resources.bicep' = {
  name: 'resources'
  scope: rg
  params: {
    servicebus_name: servicebus_name
    servicebus_namespace_sku: servicebus_namespace_sku
    location: location
  }
}

