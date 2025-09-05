param workflowName string
param location string = resourceGroup().location
param tags object = {}

param definition object = {
      '$schema': 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'
      contentVersion: '1.0.0.0'
      parameters: {}
      triggers: {}
      outputs: {}
    }
param parameters object = {}

resource workflow 'Microsoft.Logic/workflows@2019-05-01' = {
  name: workflowName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    state: 'Enabled'
    definition: definition
    parameters: parameters
  }
}


output id string = workflow.id
output principalId string = workflow.identity.principalId ?? ''
