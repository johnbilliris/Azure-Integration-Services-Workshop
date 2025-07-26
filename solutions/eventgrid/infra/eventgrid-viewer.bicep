// https://learn.microsoft.com/en-us/azure/event-grid/publish-deliver-events-with-namespace-topics-webhook-portal

@description('The name of the web app that you wish to create.')
param siteName string

@description('The name of the App Service plan to use for hosting the web app.')
param hostingPlanName string

@description('The pricing tier for the hosting plan.')
@allowed([
  'F1'
  'D1'
  'B1'
  'B2'
  'B3'
  'S1'
])
param sku string = 'F1'

@description('The URL for the GitHub repository that contains the project to deploy.')
param repoURL string = 'https://github.com/Azure-Samples/azure-event-grid-viewer.git'

@description('The branch of the GitHub repository to use.')
param branch string = 'main'

@description('Location for all resources.')
param location string = resourceGroup().location

param tags object = {}

resource hostingPlan 'Microsoft.Web/serverfarms@2020-12-01' = {
  name: hostingPlanName
  location: location
  tags: tags
  sku: {
    name: sku
    capacity: 0
  }
}

resource site 'Microsoft.Web/sites@2020-12-01' = {
  name: siteName
  location: location
  tags: tags
  properties: {
    serverFarmId: hostingPlan.name
    siteConfig: {
      webSocketsEnabled: true
      netFrameworkVersion: 'v6.0'
    }
    httpsOnly: true
  }
}

resource siteName_web 'Microsoft.Web/sites/sourcecontrols@2020-12-01' = {
  parent: site
  name: 'web'
  properties: {
    repoUrl: repoURL
    branch: branch
    isManualIntegration: true
  }
}

output appServiceEndpoint string = 'https://${site.properties.hostNames[0]}'
