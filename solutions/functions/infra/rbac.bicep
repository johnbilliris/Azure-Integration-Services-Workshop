param storageAccountName string
param serviceBusName string
param applicationInsightsName string
param managedIdentityPrincipalId string // Principal ID for the Managed Identity

var serviceBusDataOwner = '090c5cfd-751d-490a-894a-3ce6f1109419' // Service Bus Data Owner role
var storageTableDataContributor = '0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3' // Storage Table Data Contributor role
var storageBlobDataContributor = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe' // Storage Blob Data Contributor role
var monitoringRoleDefinitionId = '3913510d-42f4-4e42-8a64-420c390055eb' // Monitoring Metrics Publisher role ID

resource storageAccount 'Microsoft.Storage/storageAccounts@2025-01-01' existing = {
  name: storageAccountName
}

resource serviceBus 'Microsoft.ServiceBus/namespaces@2024-01-01' existing = {
  name: serviceBusName
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: applicationInsightsName
}

// Role assignment for Storage Table - Managed Identity
resource storageTableRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccount.id, managedIdentityPrincipalId, storageTableDataContributor) // Use managed identity ID
  scope: storageAccount
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', storageTableDataContributor)
    principalId: managedIdentityPrincipalId // Use managed identity ID
    principalType: 'ServicePrincipal' // Managed Identity is a Service Principal
  }
}

// Role assignment for Storage Blob - Managed Identity
resource storageBlobRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccount.id, managedIdentityPrincipalId, storageBlobDataContributor) // Use managed identity ID
  scope: storageAccount
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', storageBlobDataContributor)
    principalId: managedIdentityPrincipalId // Use managed identity ID
    principalType: 'ServicePrincipal' // Managed Identity is a Service Principal
  }
}

// Role assignment for Service Bus - Managed Identity
resource serviceBusRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(serviceBus.id, managedIdentityPrincipalId, serviceBusDataOwner) // Use managed identity ID
  scope: serviceBus
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', serviceBusDataOwner)
    principalId: managedIdentityPrincipalId // Use managed identity ID
    principalType: 'ServicePrincipal' // Managed Identity is a Service Principal
  }
}

// Role assignment for Application Insights - Managed Identity
resource appInsightsRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(applicationInsights.id, managedIdentityPrincipalId, monitoringRoleDefinitionId) // Use managed identity ID
  scope: applicationInsights
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', monitoringRoleDefinitionId)
    principalId: managedIdentityPrincipalId // Use managed identity ID
    principalType: 'ServicePrincipal' // Managed Identity is a Service Principal
  }
}
