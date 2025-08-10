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

param publisherEmail string

var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))

@description('Name of the resource group for all resources')
var resourceGroupName = take('ais-hol-apim-${environmentName}-rg', 90)

@description('Name of the API Management')
var apimName = take('apim-aishol-${resourceToken}', 50)

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
    apimName: apimName
    publisherEmail: publisherEmail
    location: location
    tags: tags
  }
}

