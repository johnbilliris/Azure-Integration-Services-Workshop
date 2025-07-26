@minLength(1)
@description('Location for all resources')
param location string = resourceGroup().location

param connections_office365_name string = 'office365'

param workflows_httptrigger_name string = 'logicapp-httptrigger'

param workflows_basic_name string = 'logicapp-basic'

@minLength(1)
@description('Email recipient for notifications')
param email_recipient string

param tags object = {}

resource connections_office365 'Microsoft.Web/connections@2016-06-01' = {
  name: connections_office365_name
  location: location
  tags: tags
  #disable-next-line BCP187
  kind: 'V1'
  properties: {
    displayName: email_recipient
    api: {
      name: connections_office365_name
      displayName: 'Office 365 Outlook'
      description: 'Microsoft Office 365 is a cloud-based service that is designed to help meet your organization\'s needs for robust security, reliability, and user productivity.'
      iconUri: 'https://conn-afd-prod-endpoint-bmc9bqahasf3grgk.b01.azurefd.net/v1.0.1757/1.0.1757.4256/${connections_office365_name}/icon.png'
      brandColor: '#0078D4'
      id: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Web/locations/${location}/managedApis/${connections_office365_name}'
      type: 'Microsoft.Web/locations/managedApis'
    }
    testLinks: [
      {
        #disable-next-line no-hardcoded-env-urls
        requestUri: 'https://management.azure.com:443/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Web/connections/${connections_office365_name}/extensions/proxy/testconnection?api-version=2016-06-01'
        method: 'get'
      }
    ]
  }
}

resource workflows_httptrigger 'Microsoft.Logic/workflows@2019-05-01' = {
  name: workflows_httptrigger_name
  location: location
  tags: tags
  properties: {
    state: 'Enabled'
    definition: {
      '$schema': 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'
      contentVersion: '1.0.0.0'
      parameters: {
        '$connections': {
          defaultValue: {}
          type: 'Object'
        }
      }
      triggers: {
        When_a_HTTP_request_is_received: {
          type: 'Request'
          kind: 'Http'
          inputs: {
            method: 'GET'
          }
        }
      }
      actions: {
        Get_Colors: {
          runAfter: {}
          type: 'Http'
          inputs: {
            uri: 'https://colors-api.azurewebsites.net/colors'
            method: 'GET'
          }
          runtimeConfiguration: {
            contentTransfer: {
              transferMode: 'Chunked'
            }
          }
        }
        Parse_JSON: {
          runAfter: {
            Get_Colors: [
              'Succeeded'
            ]
          }
          type: 'ParseJson'
          inputs: {
            content: '@body(\'Get_Colors\')'
            schema: {
              type: 'array'
              items: {
                type: 'object'
                properties: {
                  id: {
                    type: 'integer'
                  }
                  name: {
                    type: 'string'
                  }
                  hexcode: {
                    type: 'string'
                  }
                  data: {
                    type: 'string'
                  }
                }
                required: [
                  'id'
                  'name'
                  'hexcode'
                  'data'
                ]
              }
            }
          }
        }
        For_each_Color: {
          foreach: '@body(\'Parse_JSON\')'
          actions: {
            'Send_an_email_(V2)': {
              type: 'ApiConnection'
              inputs: {
                host: {
                  connection: {
                    name: '@parameters(\'$connections\')[\'office365\'][\'connectionId\']'
                  }
                }
                method: 'post'
                body: {
                  To: email_recipient
                  Subject: 'Color Information at @{utcNow()}'
                  Body: '<p class="editor-paragraph">Color Name: @{items(\'For_each_Color\')?[\'name\']}, Hex Code: @{items(\'For_each_Color\')?[\'hexcode\']}</p>'
                  Importance: 'Normal'
                }
                path: '/v2/Mail'
              }
            }
          }
          runAfter: {
            Parse_JSON: [
              'Succeeded'
            ]
          }
          type: 'Foreach'
        }
        Response: {
          runAfter: {
            For_each_Color: [
              'Succeeded'
            ]
          }
          type: 'Response'
          kind: 'Http'
          inputs: {
            statusCode: 200
            body: '@body(\'Get_Colors\')'
          }
        }
      }
      outputs: {}
    }
    parameters: {
      '$connections': {
        value: {
          office365: {
            id: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Web/locations/${location}/managedApis/office365'
            connectionId: connections_office365.id
            connectionName: 'office365'
          }
        }
      }
    }
  }
}

resource workflows_basic 'Microsoft.Logic/workflows@2019-05-01' = {
  name: workflows_basic_name
  location: location
  tags: tags
  properties: {
    state: 'Enabled'
    definition: {
      '$schema': 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'
      contentVersion: '1.0.0.0'
      parameters: {
        '$connections': {
          defaultValue: {}
          type: 'Object'
        }
      }
      triggers: {
        Recurrence: {
          recurrence: {
            interval: 1
            frequency: 'Minute'
            timeZone: 'AUS Eastern Standard Time'
          }
          evaluatedRecurrence: {
            interval: 1
            frequency: 'Minute'
            timeZone: 'AUS Eastern Standard Time'
          }
          type: 'Recurrence'
        }
      }
      actions: {
        'Send_an_email_(V2)': {
          runAfter: {}
          type: 'ApiConnection'
          inputs: {
            host: {
              connection: {
                name: '@parameters(\'$connections\')[\'office365\'][\'connectionId\']'
              }
            }
            method: 'post'
            body: {
              To: email_recipient
              Subject: 'Logic App run at @{utcNow()}'
              Body: '<p class="editor-paragraph">Logic App run at @{utcNow()}</p>'
              Importance: 'Normal'
            }
            path: '/v2/Mail'
          }
        }
      }
      outputs: {}
    }
    parameters: {
      '$connections': {
        value: {
          office365: {
            id: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Web/locations/${location}/managedApis/office365'
            connectionId: connections_office365.id
            connectionName: 'office365'
          }
        }
      }
    }
  }
}
