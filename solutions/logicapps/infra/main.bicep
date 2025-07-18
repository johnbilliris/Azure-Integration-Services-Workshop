
targetScope = 'subscription'

@minLength(1)
@description('Name of the resource group for all resources')
param resourceGroupName string

@minLength(1)
@description('Location for all resources')
param location string = 'australiaeast'

param connections_office365_name string = 'office365'

param workflows_httptrigger_name string = 'logicapp-httptrigger'

param workflows_basic_name string = 'My-Consumption-Logic-App'

param email_recipient string = ''

// Organize resources in a resource group
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
}

module resources 'resources.bicep' = {
  name: 'resources'
  scope: rg
  params: {
    connections_office365_name: connections_office365_name
    workflows_httptrigger_name: workflows_httptrigger_name
    workflows_basic_name: workflows_basic_name
    email_recipient: email_recipient
    location: location
  }
}

