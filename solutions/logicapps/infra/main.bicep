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

param email_recipient string = ''


var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))

@description('Name of the resource group for all resources')
var resourceGroupName = take('ais-hol-logicapps-${environmentName}-rg', 90)

var connections_office365_name = 'office365'
var workflows_httptrigger_name = 'logicapp-aishol-httptrigger-${resourceToken}'
var workflows_basic_name = 'logicapp-aishol-basic-${resourceToken}'

var tags = { 'azd-env-name': environmentName 
             'azd-resource-group': resourceGroupName
             'azd-location': location
             'azd-deployment-time': deploymentTime }


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
    connections_office365_name: connections_office365_name
    workflows_httptrigger_name: workflows_httptrigger_name
    workflows_basic_name: workflows_basic_name
    email_recipient: email_recipient
    location: location
    tags: tags
  }
}
