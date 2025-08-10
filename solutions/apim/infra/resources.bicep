@minLength(1)
@description('Location for all resources')
param location string = resourceGroup().location

@description('Name of the API Management')
@minLength(1)
param apimName string = 'apim-aishol'

@description('SKU for the API Management')
@allowed(['Developer', 'Basic', 'Standard', 'Premium'])
@minLength(1)
param apim_sku string = 'Developer'

@description('Email address of the API Management publisher')
@minLength(1)
param publisherEmail string

param tags object = {}


resource apim 'Microsoft.ApiManagement/service@2024-06-01-preview' = {
  name: apimName
  location: location
  tags: tags
  sku: {
    name: apim_sku
    capacity: 1
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publisherEmail: publisherEmail
    publisherName: 'Microsoft'
    notificationSenderEmail: 'apimgmt-noreply@mail.windowsazure.com'
    virtualNetworkType: 'None'
    apiVersionConstraint: {
      minApiVersion: '2021-08-01'
    }
  }
}

resource administrators 'Microsoft.ApiManagement/service/groups@2024-06-01-preview' = {
  parent: apim
  name: 'administrators'
  properties: {
    displayName: 'Administrators'
    description: 'Administrators is a built-in group containing the admin email account provided at the time of service creation. Its membership is managed by the system.'
    type: 'system'
  }
}

resource developers 'Microsoft.ApiManagement/service/groups@2024-06-01-preview' = {
  parent: apim
  name: 'developers'
  properties: {
    displayName: 'Developers'
    description: 'Developers is a built-in group. Its membership is managed by the system. Signed-in users fall into this group.'
    type: 'system'
  }
}

resource guests 'Microsoft.ApiManagement/service/groups@2024-06-01-preview' = {
  parent: apim
  name: 'guests'
  properties: {
    displayName: 'Guests'
    description: 'Guests is a built-in group. Its membership is managed by the system. Unauthenticated users visiting the developer portal fall into this group.'
    type: 'system'
  }
}

resource starter 'Microsoft.ApiManagement/service/products@2024-06-01-preview' = {
  parent: apim
  name: 'starter'
  properties: {
    displayName: 'Starter'
    description: 'Subscribers will be able to run 5 calls/minute up to a maximum of 100 calls/week.'
    subscriptionRequired: true
    approvalRequired: false
    subscriptionsLimit: 1
    state: 'published'
  }
}

resource unlimited 'Microsoft.ApiManagement/service/products@2024-06-01-preview' = {
  parent: apim
  name: 'unlimited'
  properties: {
    displayName: 'Unlimited'
    description: 'Subscribers have completely unlimited access to the API. Administrator approval is required.'
    subscriptionRequired: true
    approvalRequired: true
    subscriptionsLimit: 1
    state: 'published'
  }
}

resource starter_colors_api 'Microsoft.ApiManagement/service/products/apis@2024-06-01-preview' = {
  parent: starter
  name: 'colors-api'
  dependsOn: [ colorsApi]
}

resource unlimited_colors_api 'Microsoft.ApiManagement/service/products/apis@2024-06-01-preview' = {
  parent: unlimited
  name: 'colors-api'
  dependsOn: [ colorsApi]
}

resource starter_star_wars 'Microsoft.ApiManagement/service/products/apis@2024-06-01-preview' = {
  parent: starter
  name: 'star-wars'
  dependsOn: [ starWarsApi]
}

resource unlimited_star_wars 'Microsoft.ApiManagement/service/products/apis@2024-06-01-preview' = {
  parent: unlimited
  name: 'star-wars'
  dependsOn: [ starWarsApi]
}

resource starter_administrators 'Microsoft.ApiManagement/service/products/groups@2024-06-01-preview' = {
  parent: starter
  name: 'administrators'
  dependsOn: [ administrators]
}

resource unlimited_administrators 'Microsoft.ApiManagement/service/products/groups@2024-06-01-preview' = {
  parent: unlimited
  name: 'administrators'
  dependsOn: [ administrators]
}

resource starter_developers 'Microsoft.ApiManagement/service/products/groups@2024-06-01-preview' = {
  parent: starter
  name: 'developers'
  dependsOn: [ developers]
}

resource unlimited_developers 'Microsoft.ApiManagement/service/products/groups@2024-06-01-preview' = {
  parent: unlimited
  name: 'developers'
  dependsOn: [ developers]
}

resource starter_guests 'Microsoft.ApiManagement/service/products/groups@2024-06-01-preview' = {
  parent: starter
  name: 'guests'
  dependsOn: [ guests]
}

resource unlimited_guests 'Microsoft.ApiManagement/service/products/groups@2024-06-01-preview' = {
  parent: unlimited
  name: 'guests'
  dependsOn: [ guests]
}

resource starter_policy 'Microsoft.ApiManagement/service/products/policies@2024-06-01-preview' = {
  parent: starter
  name: 'policy'
  properties: {
    value: '<!--\r\n            IMPORTANT:\r\n            - Policy elements can appear only within the <inbound>, <outbound>, <backend> section elements.\r\n            - Only the <forward-request> policy element can appear within the <backend> section element.\r\n            - To apply a policy to the incoming request (before it is forwarded to the backend service), place a corresponding policy element within the <inbound> section element.\r\n            - To apply a policy to the outgoing response (before it is sent back to the caller), place a corresponding policy element within the <outbound> section element.\r\n            - To add a policy position the cursor at the desired insertion point and click on the round button associated with the policy.\r\n            - To remove a policy, delete the corresponding policy statement from the policy document.\r\n            - Position the <base> element within a section element to inherit all policies from the corresponding section element in the enclosing scope.\r\n            - Remove the <base> element to prevent inheriting policies from the corresponding section element in the enclosing scope.\r\n            - Policies are applied in the order of their appearance, from the top down.\r\n        -->\r\n<policies>\r\n  <inbound>\r\n    <rate-limit calls="5" renewal-period="60" />\r\n    <quota calls="100" renewal-period="604800" />\r\n    <base />\r\n  </inbound>\r\n  <backend>\r\n    <base />\r\n  </backend>\r\n  <outbound>\r\n    <base />\r\n  </outbound>\r\n</policies>'
    format: 'xml'
  }
}

// resource unlimited_689446ee463461031427e6d1 'Microsoft.ApiManagement/service/products/apiLinks@2024-06-01-preview' = {
//   parent: unlimited
//   name: '689446ee463461031427e6d1'
//   properties: {
//     apiId: starWarsApi.id
//   }
//   dependsOn: [ unlimited_star_wars ]
// }

// resource starter_689446ef463461031427e6d3 'Microsoft.ApiManagement/service/products/apiLinks@2024-06-01-preview' = {
//   parent: starter
//   name: '689446ef463461031427e6d3'
//   properties: {
//     apiId: starWarsApi.id
//   }
//   dependsOn: [starter_star_wars ]
// }

// resource starter_689447b9463461031427e6e7 'Microsoft.ApiManagement/service/products/apiLinks@2024-06-01-preview' = {
//   parent: starter
//   name: '689447b9463461031427e6e7'
//   properties: {
//     apiId: colorsApi.id
//   }
//   dependsOn: [ starter_colors_api]
// }

// resource unlimited_689447ba463461031427e6e9 'Microsoft.ApiManagement/service/products/apiLinks@2024-06-01-preview' = {
//   parent: unlimited
//   name: '689447ba463461031427e6e9'
//   properties: {
//     apiId: colorsApi.id
//   }
//   dependsOn: [ unlimited_colors_api]
// }

// Colors APIs
resource colorsApi 'Microsoft.ApiManagement/service/apis@2024-06-01-preview' = {
  parent: apim
  name: 'colors-api'
  properties: {
    displayName: 'Colors API'
    apiRevision: '1'
    description: 'Colors API'
    subscriptionRequired: true
    serviceUrl: 'https://colors-api.azurewebsites.net/'
    protocols: [
      'https'
    ]
    authenticationSettings: {
      oAuth2AuthenticationSettings: []
      openidAuthenticationSettings: []
    }
    subscriptionKeyParameterNames: {
      header: 'Ocp-Apim-Subscription-Key'
      query: 'subscription-key'
    }
    termsOfServiceUrl: 'https://github.com/markharrison/ColorsAPI/blob/master/LICENSE'
    contact: {
      name: 'Mark Harrison'
      url: 'https://github.com/markharrison/ColorsAPI'
      email: 'mark.colorsapi@harrison.ws'
    }
    license: {
      name: 'Use under MIT License'
      url: 'https://github.com/markharrison/ColorsAPI/blob/master/LICENSE'
    }
    isCurrent: true
    path: ''
  }
}

resource Colors 'Microsoft.ApiManagement/service/tags@2024-06-01-preview' = {
  parent: apim
  name: 'Colors'
  properties: {
    displayName: 'Colors'
  }
}

// resource Colors_68944798463461031427e6db 'Microsoft.ApiManagement/service/tags/operationLinks@2024-06-01-preview' = {
//   parent: Colors
//   name: '68944798463461031427e6db'
//   properties: {
//     operationId: colorsApi_GetColors.id
//   }
// }

// resource Colors_68944798463461031427e6dc 'Microsoft.ApiManagement/service/tags/operationLinks@2024-06-01-preview' = {
//   parent: Colors
//   name: '68944798463461031427e6dc'
//   properties: {
//     operationId: colorsApi_UpdateColors.id
//   }
// }

// resource Colors_68944798463461031427e6dd 'Microsoft.ApiManagement/service/tags/operationLinks@2024-06-01-preview' = {
//   parent: Colors
//   name: '68944798463461031427e6dd'
//   properties: {
//     operationId: colorsApi_DeletesColors.id
//   }
// }

// resource Colors_68944798463461031427e6de 'Microsoft.ApiManagement/service/tags/operationLinks@2024-06-01-preview' = {
//   parent: Colors
//   name: '68944798463461031427e6de'
//   properties: {
//     operationId: colorsApi_GetColorById.id
//   }
// }

// resource Colors_68944798463461031427e6df 'Microsoft.ApiManagement/service/tags/operationLinks@2024-06-01-preview' = {
//   parent: Colors
//   name: '68944798463461031427e6df'
//   properties: {
//     operationId: colorsApi_UpdateColorById.id
//   }
// }

// resource Colors_68944798463461031427e6e0 'Microsoft.ApiManagement/service/tags/operationLinks@2024-06-01-preview' = {
//   parent: Colors
//   name: '68944798463461031427e6e0'
//   properties: {
//     operationId: colorsApi_DeleteColorById.id
//   }
// }

// resource Colors_68944798463461031427e6e1 'Microsoft.ApiManagement/service/tags/operationLinks@2024-06-01-preview' = {
//   parent: Colors
//   name: '68944798463461031427e6e1'
//   properties: {
//     operationId: colorsApi_GetColorBy.id
//   }
// }

// resource Colors_68944798463461031427e6e2 'Microsoft.ApiManagement/service/tags/operationLinks@2024-06-01-preview' = {
//   parent: Colors
//   name: '68944798463461031427e6e2'
//   properties: {
//     operationId: colorsApi_GetRandomColor.id
//   }
// }

// resource Colors_68944798463461031427e6e3 'Microsoft.ApiManagement/service/tags/operationLinks@2024-06-01-preview' = {
//   parent: Colors
//   name: '68944798463461031427e6e3'
//   properties: {
//     operationId: colorsApi_ResetColors.id
//   }
// }

resource colorsApi_DeleteColorById 'Microsoft.ApiManagement/service/apis/operations@2024-06-01-preview' = {
  parent: colorsApi
  name: 'DeleteColorById'
  properties: {
    displayName: 'Delete color by id'
    method: 'DELETE'
    urlTemplate: '/colors/{colorId}'
    templateParameters: [
      {
        name: 'colorId'
        description: 'Id of Color to delete'
        type: 'integer'
        required: true
        values: []
        //schemaId: colorsApiSchema.name
        typeName: 'Colors-colorId-DeleteRequest'
      }
    ]
    description: 'Deletes color specified by {colorId} (must be between 1 and 1000).'
    responses: [
      {
        statusCode: 204
        description: 'Success - color deleted'
        representations: [
          {
            contentType: 'text/plain'
            examples: {
              default: {}
            }
            schemaId: colorsApiSchema.name
            typeName: 'ColorsItem'
          }
          {
            contentType: 'application/json'
            examples: {
              default: {
                value: {
                  id: 0
                  name: 'string'
                  hexcode: 'string'
                  data: 'string'
                }
              }
            }
            schemaId: colorsApiSchema.name
            typeName: 'ColorsItem'
          }
          {
            contentType: 'text/json'
            examples: {
              default: {
                value: {
                  id: 0
                  name: 'string'
                  hexcode: 'string'
                  data: 'string'
                }
              }
            }
            schemaId: colorsApiSchema.name
            typeName: 'ColorsItem'
          }
        ]
        headers: []
      }
      {
        statusCode: 422
        description: 'Unprocessable Entity'
        representations: [
          {
            contentType: 'text/plain'
            examples: {
              default: {}
            }
            schemaId: colorsApiSchema.name
            typeName: 'ProblemDetails'
          }
          {
            contentType: 'application/json'
            examples: {
              default: {
                value: {
                  type: 'string'
                  title: 'string'
                  status: 0
                  detail: 'string'
                  instance: 'string'
                }
              }
            }
            schemaId: colorsApiSchema.name
            typeName: 'ProblemDetails'
          }
          {
            contentType: 'text/json'
            examples: {
              default: {
                value: {
                  type: 'string'
                  title: 'string'
                  status: 0
                  detail: 'string'
                  instance: 'string'
                }
              }
            }
            schemaId: colorsApiSchema.name
            typeName: 'ProblemDetails'
          }
        ]
        headers: []
      }
    ]
  }
}

resource colorsApi_DeletesColors 'Microsoft.ApiManagement/service/apis/operations@2024-06-01-preview' = {
  parent: colorsApi
  name: 'DeletesColors'
  properties: {
    displayName: 'Delete colors'
    method: 'DELETE'
    urlTemplate: '/colors'
    templateParameters: []
    description: 'Deletes all colors.'
    responses: [
      {
        statusCode: 204
        description: 'Success - all colors deleted'
        representations: [
          {
            contentType: 'text/plain'
            examples: {
              default: {}
            }
            schemaId: colorsApiSchema.name
            typeName: 'ColorsItem'
          }
          {
            contentType: 'application/json'
            examples: {
              default: {
                value: {
                  id: 0
                  name: 'string'
                  hexcode: 'string'
                  data: 'string'
                }
              }
            }
            schemaId: colorsApiSchema.name
            typeName: 'ColorsItem'
          }
          {
            contentType: 'text/json'
            examples: {
              default: {
                value: {
                  id: 0
                  name: 'string'
                  hexcode: 'string'
                  data: 'string'
                }
              }
            }
            schemaId: colorsApiSchema.name
            typeName: 'ColorsItem'
          }
        ]
        headers: []
      }
    ]
  }
}

resource colorsApi_GetColorById 'Microsoft.ApiManagement/service/apis/operations@2024-06-01-preview' = {
  parent: colorsApi
  name: 'GetColorById'
  properties: {
    displayName: 'Get color by id'
    method: 'GET'
    urlTemplate: '/colors/{colorId}'
    templateParameters: [
      {
        name: 'colorId'
        description: 'Id of Color to return'
        type: 'integer'
        required: true
        values: []
        schemaId: colorsApiSchema.name
        typeName: 'Colors-colorId-GetRequest'
      }
    ]
    description: 'Returns color specified by {colorId} (must be between 1 and 1000).'
    responses: [
      {
        statusCode: 200
        description: 'Success - returns color'
        representations: [
          {
            contentType: 'text/plain'
            examples: {
              default: {}
            }
            schemaId: colorsApiSchema.name
            typeName: 'ColorsItem'
          }
          {
            contentType: 'application/json'
            examples: {
              default: {
                value: {
                  id: 0
                  name: 'string'
                  hexcode: 'string'
                  data: 'string'
                }
              }
            }
            schemaId: colorsApiSchema.name
            typeName: 'ColorsItem'
          }
          {
            contentType: 'text/json'
            examples: {
              default: {
                value: {
                  id: 0
                  name: 'string'
                  hexcode: 'string'
                  data: 'string'
                }
              }
            }
            schemaId: colorsApiSchema.name
            typeName: 'ColorsItem'
          }
        ]
        headers: []
      }
      {
        statusCode: 404
        description: 'Not Found'
        representations: [
          {
            contentType: 'text/plain'
            examples: {
              default: {}
            }
            schemaId: colorsApiSchema.name
            typeName: 'ProblemDetails'
          }
          {
            contentType: 'application/json'
            examples: {
              default: {
                value: {
                  type: 'string'
                  title: 'string'
                  status: 0
                  detail: 'string'
                  instance: 'string'
                }
              }
            }
            schemaId: colorsApiSchema.name
            typeName: 'ProblemDetails'
          }
          {
            contentType: 'text/json'
            examples: {
              default: {
                value: {
                  type: 'string'
                  title: 'string'
                  status: 0
                  detail: 'string'
                  instance: 'string'
                }
              }
            }
            schemaId: colorsApiSchema.name
            typeName: 'ProblemDetails'
          }
        ]
        headers: []
      }
      {
        statusCode: 422
        description: 'Unprocessable Entity'
        representations: [
          {
            contentType: 'text/plain'
            examples: {
              default: {}
            }
            schemaId: colorsApiSchema.name
            typeName: 'ProblemDetails'
          }
          {
            contentType: 'application/json'
            examples: {
              default: {
                value: {
                  type: 'string'
                  title: 'string'
                  status: 0
                  detail: 'string'
                  instance: 'string'
                }
              }
            }
            schemaId: colorsApiSchema.name
            typeName: 'ProblemDetails'
          }
          {
            contentType: 'text/json'
            examples: {
              default: {
                value: {
                  type: 'string'
                  title: 'string'
                  status: 0
                  detail: 'string'
                  instance: 'string'
                }
              }
            }
            schemaId: colorsApiSchema.name
            typeName: 'ProblemDetails'
          }
        ]
        headers: []
      }
    ]
  }
}

resource colorsApi_GetColorBy 'Microsoft.ApiManagement/service/apis/operations@2024-06-01-preview' = {
  parent: colorsApi
  name: 'GetColorByName'
  properties: {
    displayName: 'Get color by name'
    method: 'GET'
    urlTemplate: '/colors/findbyname?colorName={colorName}'
    templateParameters: [
      {
        name: 'colorName'
        description: 'Name of Color to return'
        type: 'string'
        required: true
        values: []
        schemaId: colorsApiSchema.name
        typeName: 'ColorsFindbynameGetRequest'
      }
    ]
    description: 'Returns color specified by {colorName} '
    responses: [
      {
        statusCode: 200
        description: 'Success - returns color'
        representations: [
          {
            contentType: 'text/plain'
            examples: {
              default: {}
            }
            schemaId: colorsApiSchema.name
            typeName: 'ColorsItem'
          }
          {
            contentType: 'application/json'
            examples: {
              default: {
                value: {
                  id: 0
                  name: 'string'
                  hexcode: 'string'
                  data: 'string'
                }
              }
            }
            schemaId: colorsApiSchema.name
            typeName: 'ColorsItem'
          }
          {
            contentType: 'text/json'
            examples: {
              default: {
                value: {
                  id: 0
                  name: 'string'
                  hexcode: 'string'
                  data: 'string'
                }
              }
            }
            schemaId: colorsApiSchema.name
            typeName: 'ColorsItem'
          }
        ]
        headers: []
      }
      {
        statusCode: 404
        description: 'Not Found'
        representations: [
          {
            contentType: 'text/plain'
            examples: {
              default: {}
            }
            schemaId: colorsApiSchema.name
            typeName: 'ProblemDetails'
          }
          {
            contentType: 'application/json'
            examples: {
              default: {
                value: {
                  type: 'string'
                  title: 'string'
                  status: 0
                  detail: 'string'
                  instance: 'string'
                }
              }
            }
            schemaId: colorsApiSchema.name
            typeName: 'ProblemDetails'
          }
          {
            contentType: 'text/json'
            examples: {
              default: {
                value: {
                  type: 'string'
                  title: 'string'
                  status: 0
                  detail: 'string'
                  instance: 'string'
                }
              }
            }
            schemaId: colorsApiSchema.name
            typeName: 'ProblemDetails'
          }
        ]
        headers: []
      }
    ]
  }
}

resource colorsApi_GetColors 'Microsoft.ApiManagement/service/apis/operations@2024-06-01-preview' = {
  parent: colorsApi
  name: 'GetColors'
  properties: {
    displayName: 'Get colors'
    method: 'GET'
    urlTemplate: '/colors'
    templateParameters: []
    description: 'Returns all colors.'
    responses: [
      {
        statusCode: 200
        description: 'Success - returns list of colors'
        representations: [
          {
            contentType: 'text/plain'
            examples: {
              default: {}
            }
            schemaId: colorsApiSchema.name
            typeName: 'ColorsGet200TextPlainResponse'
          }
          {
            contentType: 'application/json'
            examples: {
              default: {
                value: [
                  {
                    id: 0
                    name: 'string'
                    hexcode: 'string'
                    data: 'string'
                  }
                ]
              }
            }
            schemaId: colorsApiSchema.name
            typeName: 'ColorsGet200ApplicationJsonResponse'
          }
          {
            contentType: 'text/json'
            examples: {
              default: {
                value: [
                  {
                    id: 0
                    name: 'string'
                    hexcode: 'string'
                    data: 'string'
                  }
                ]
              }
            }
            schemaId: colorsApiSchema.name
            typeName: 'ColorsGet200TextJsonResponse'
          }
        ]
        headers: []
      }
    ]
  }
}

resource colorsApi_GetRandomColor 'Microsoft.ApiManagement/service/apis/operations@2024-06-01-preview' = {
  parent: colorsApi
  name: 'GetRandomColor'
  properties: {
    displayName: 'Get random color'
    method: 'GET'
    urlTemplate: '/colors/random'
    templateParameters: []
    description: 'Returns random color.'
    responses: [
      {
        statusCode: 200
        description: 'Success - returns random color'
        representations: [
          {
            contentType: 'text/plain'
            examples: {
              default: {}
            }
            schemaId: colorsApiSchema.name
            typeName: 'ColorsItem'
          }
          {
            contentType: 'application/json'
            examples: {
              default: {
                value: {
                  id: 0
                  name: 'string'
                  hexcode: 'string'
                  data: 'string'
                }
              }
            }
            schemaId: colorsApiSchema.name
            typeName: 'ColorsItem'
          }
          {
            contentType: 'text/json'
            examples: {
              default: {
                value: {
                  id: 0
                  name: 'string'
                  hexcode: 'string'
                  data: 'string'
                }
              }
            }
            schemaId: colorsApiSchema.name
            typeName: 'ColorsItem'
          }
        ]
        headers: []
      }
      {
        statusCode: 404
        description: 'Not Found'
        representations: [
          {
            contentType: 'text/plain'
            examples: {
              default: {}
            }
            schemaId: colorsApiSchema.name
            typeName: 'ProblemDetails'
          }
          {
            contentType: 'application/json'
            examples: {
              default: {
                value: {
                  type: 'string'
                  title: 'string'
                  status: 0
                  detail: 'string'
                  instance: 'string'
                }
              }
            }
            schemaId: colorsApiSchema.name
            typeName: 'ProblemDetails'
          }
          {
            contentType: 'text/json'
            examples: {
              default: {
                value: {
                  type: 'string'
                  title: 'string'
                  status: 0
                  detail: 'string'
                  instance: 'string'
                }
              }
            }
            schemaId: colorsApiSchema.name
            typeName: 'ProblemDetails'
          }
        ]
        headers: []
      }
    ]
  }
}

resource colorsApi_ResetColors 'Microsoft.ApiManagement/service/apis/operations@2024-06-01-preview' = {
  parent: colorsApi
  name: 'ResetColors'
  properties: {
    displayName: 'Reset colors'
    method: 'POST'
    urlTemplate: '/colors/reset'
    templateParameters: []
    description: 'Reset colors to default.'
    responses: [
      {
        statusCode: 201
        description: 'Success - colors reset'
        representations: [
          {
            contentType: 'text/plain'
            examples: {
              default: {}
            }
            schemaId: colorsApiSchema.name
            typeName: 'ColorsItem'
          }
          {
            contentType: 'application/json'
            examples: {
              default: {
                value: {
                  id: 0
                  name: 'string'
                  hexcode: 'string'
                  data: 'string'
                }
              }
            }
            schemaId: colorsApiSchema.name
            typeName: 'ColorsItem'
          }
          {
            contentType: 'text/json'
            examples: {
              default: {
                value: {
                  id: 0
                  name: 'string'
                  hexcode: 'string'
                  data: 'string'
                }
              }
            }
            schemaId: colorsApiSchema.name
            typeName: 'ColorsItem'
          }
        ]
        headers: []
      }
    ]
  }
}

resource colorsApi_UpdateColorById 'Microsoft.ApiManagement/service/apis/operations@2024-06-01-preview' = {
  parent: colorsApi
  name: 'UpdateColorById'
  properties: {
    displayName: 'Update / create color by id'
    method: 'POST'
    urlTemplate: '/colors/{colorId}'
    templateParameters: [
      {
        name: 'colorId'
        description: 'Id of Color to update'
        type: 'integer'
        required: true
        values: []
        schemaId: colorsApiSchema.name
        typeName: 'Colors-colorId-PostRequest'
      }
    ]
    description: 'Updates color specified by {colorId} (must be between 1 and 1000);  use {colorId} = 0 to insert new color'
    request: {
      description: 'Colors to update'
      queryParameters: []
      headers: []
      representations: [
        {
          contentType: 'application/json'
          examples: {
            default: {
              value: {
                id: 0
                name: 'string'
                hexcode: 'string'
                data: 'string'
              }
            }
          }
          schemaId: colorsApiSchema.name
          typeName: 'ColorsItem'
        }
        {
          contentType: 'text/json'
          examples: {
            default: {
              value: {
                id: 0
                name: 'string'
                hexcode: 'string'
                data: 'string'
              }
            }
          }
          schemaId: colorsApiSchema.name
          typeName: 'ColorsItem'
        }
        {
          contentType: 'application/*+json'
          examples: {
            default: {
              value: {
                id: 0
                name: 'string'
                hexcode: 'string'
                data: 'string'
              }
            }
          }
          schemaId: colorsApiSchema.name
          typeName: 'ColorsItem'
        }
      ]
    }
    responses: [
      {
        statusCode: 201
        description: 'Success - color created/updated'
        representations: [
          {
            contentType: 'text/plain'
            examples: {
              default: {}
            }
            schemaId: colorsApiSchema.name
            typeName: 'ColorsItem'
          }
          {
            contentType: 'application/json'
            examples: {
              default: {
                value: {
                  id: 0
                  name: 'string'
                  hexcode: 'string'
                  data: 'string'
                }
              }
            }
            schemaId: colorsApiSchema.name
            typeName: 'ColorsItem'
          }
          {
            contentType: 'text/json'
            examples: {
              default: {
                value: {
                  id: 0
                  name: 'string'
                  hexcode: 'string'
                  data: 'string'
                }
              }
            }
            schemaId: colorsApiSchema.name
            typeName: 'ColorsItem'
          }
        ]
        headers: []
      }
      {
        statusCode: 422
        description: 'Unprocessable Entity'
        representations: [
          {
            contentType: 'text/plain'
            examples: {
              default: {}
            }
            schemaId: colorsApiSchema.name
            typeName: 'ProblemDetails'
          }
          {
            contentType: 'application/json'
            examples: {
              default: {
                value: {
                  type: 'string'
                  title: 'string'
                  status: 0
                  detail: 'string'
                  instance: 'string'
                }
              }
            }
            schemaId: colorsApiSchema.name
            typeName: 'ProblemDetails'
          }
          {
            contentType: 'text/json'
            examples: {
              default: {
                value: {
                  type: 'string'
                  title: 'string'
                  status: 0
                  detail: 'string'
                  instance: 'string'
                }
              }
            }
            schemaId: colorsApiSchema.name
            typeName: 'ProblemDetails'
          }
        ]
        headers: []
      }
    ]
  }
}

resource colorsApi_UpdateColors 'Microsoft.ApiManagement/service/apis/operations@2024-06-01-preview' = {
  parent: colorsApi
  name: 'UpdateColors'
  properties: {
    displayName: 'Update / create colors'
    method: 'POST'
    urlTemplate: '/colors'
    templateParameters: []
    description: 'Updates colors - creates color if it doesn\'t exist'
    request: {
      description: 'Colors to update'
      queryParameters: []
      headers: []
      representations: [
        {
          contentType: 'application/json'
          examples: {
            default: {
              value: [
                {
                  id: 0
                  name: 'string'
                  hexcode: 'string'
                  data: 'string'
                }
              ]
            }
          }
          schemaId: colorsApiSchema.name
          typeName: 'ColorsPostRequest'
        }
        {
          contentType: 'text/json'
          examples: {
            default: {
              value: [
                {
                  id: 0
                  name: 'string'
                  hexcode: 'string'
                  data: 'string'
                }
              ]
            }
          }
          schemaId: colorsApiSchema.name
          typeName: 'ColorsPostRequest-1'
        }
        {
          contentType: 'application/*+json'
          examples: {
            default: {
              value: [
                {
                  id: 0
                  name: 'string'
                  hexcode: 'string'
                  data: 'string'
                }
              ]
            }
          }
          schemaId: colorsApiSchema.name
          typeName: 'ColorsPostRequest-2'
        }
      ]
    }
    responses: [
      {
        statusCode: 201
        description: 'Success - colors updated/created'
        representations: [
          {
            contentType: 'text/plain'
            examples: {
              default: {}
            }
            schemaId: colorsApiSchema.name
            typeName: 'ColorsItem'
          }
          {
            contentType: 'application/json'
            examples: {
              default: {
                value: {
                  id: 0
                  name: 'string'
                  hexcode: 'string'
                  data: 'string'
                }
              }
            }
            schemaId: colorsApiSchema.name
            typeName: 'ColorsItem'
          }
          {
            contentType: 'text/json'
            examples: {
              default: {
                value: {
                  id: 0
                  name: 'string'
                  hexcode: 'string'
                  data: 'string'
                }
              }
            }
            schemaId: colorsApiSchema.name
            typeName: 'ColorsItem'
          }
        ]
        headers: []
      }
      {
        statusCode: 422
        description: 'Unprocessable Entity'
        representations: [
          {
            contentType: 'text/plain'
            examples: {
              default: {}
            }
            schemaId: colorsApiSchema.name
            typeName: 'ProblemDetails'
          }
          {
            contentType: 'application/json'
            examples: {
              default: {
                value: {
                  type: 'string'
                  title: 'string'
                  status: 0
                  detail: 'string'
                  instance: 'string'
                }
              }
            }
            schemaId: colorsApiSchema.name
            typeName: 'ProblemDetails'
          }
          {
            contentType: 'text/json'
            examples: {
              default: {
                value: {
                  type: 'string'
                  title: 'string'
                  status: 0
                  detail: 'string'
                  instance: 'string'
                }
              }
            }
            schemaId: colorsApiSchema.name
            typeName: 'ProblemDetails'
          }
        ]
        headers: []
      }
    ]
  }
}

resource colorsSchema 'Microsoft.ApiManagement/service/schemas@2024-06-01-preview' = {
  parent: apim
  name: 'colorsSchema'
  properties: {
    schemaType: 'json'
    document: {
      openapi: '3.0.4'
      info: {
        title: 'Mark Harrison Colors API'
        description: 'Colors API'
        termsOfService: 'https://github.com/markharrison/ColorsAPI/blob/master/LICENSE'
        contact: {
          name: 'Mark Harrison'
          url: 'https://github.com/markharrison/ColorsAPI'
          email: 'mark.colorsapi@harrison.ws'
        }
        license: {
          name: 'Use under MIT License'
          url: 'https://github.com/markharrison/ColorsAPI/blob/master/LICENSE'
        }
        version: '3.0.1'
      }
      servers: [
        {
          url: 'https://colors-api.azurewebsites.net/'
        }
      ]
      paths: {
        '/colors': {
          get: {
            tags: [
              'Colors'
            ]
            summary: 'Get colors'
            description: 'Returns all colors.'
            operationId: 'GetColors'
            responses: {
              '200': {
                description: 'Success - returns list of colors'
                content: {
                  'text/plain': {
                    schema: {
                      type: 'array'
                      items: {
                        '$ref': '#/components/schemas/ColorsItem'
                      }
                    }
                  }
                  'application/json': {
                    schema: {
                      type: 'array'
                      items: {
                        '$ref': '#/components/schemas/ColorsItem'
                      }
                    }
                  }
                  'text/json': {
                    schema: {
                      type: 'array'
                      items: {
                        '$ref': '#/components/schemas/ColorsItem'
                      }
                    }
                  }
                }
              }
            }
          }
          post: {
            tags: [
              'Colors'
            ]
            summary: 'Update / create colors'
            description: 'Updates colors - creates color if it doesn\'t exist'
            operationId: 'UpdateColors'
            requestBody: {
              description: 'Colors to update'
              content: {
                'application/json': {
                  schema: {
                    type: 'array'
                    items: {
                      '$ref': '#/components/schemas/ColorsItem'
                    }
                  }
                }
                'text/json': {
                  schema: {
                    type: 'array'
                    items: {
                      '$ref': '#/components/schemas/ColorsItem'
                    }
                  }
                }
                'application/*+json': {
                  schema: {
                    type: 'array'
                    items: {
                      '$ref': '#/components/schemas/ColorsItem'
                    }
                  }
                }
              }
              required: true
            }
            responses: {
              '201': {
                description: 'Success - colors updated/created'
                content: {
                  'text/plain': {
                    schema: {
                      '$ref': '#/components/schemas/ColorsItem'
                    }
                  }
                  'application/json': {
                    schema: {
                      '$ref': '#/components/schemas/ColorsItem'
                    }
                  }
                  'text/json': {
                    schema: {
                      '$ref': '#/components/schemas/ColorsItem'
                    }
                  }
                }
              }
              '422': {
                description: 'Unprocessable Entity'
                content: {
                  'text/plain': {
                    schema: {
                      '$ref': '#/components/schemas/ProblemDetails'
                    }
                  }
                  'application/json': {
                    schema: {
                      '$ref': '#/components/schemas/ProblemDetails'
                    }
                  }
                  'text/json': {
                    schema: {
                      '$ref': '#/components/schemas/ProblemDetails'
                    }
                  }
                }
              }
            }
          }
          delete: {
            tags: [
              'Colors'
            ]
            summary: 'Delete colors'
            description: 'Deletes all colors.'
            operationId: 'DeletesColors'
            responses: {
              '204': {
                description: 'Success - all colors deleted'
                content: {
                  'text/plain': {
                    schema: {
                      '$ref': '#/components/schemas/ColorsItem'
                    }
                  }
                  'application/json': {
                    schema: {
                      '$ref': '#/components/schemas/ColorsItem'
                    }
                  }
                  'text/json': {
                    schema: {
                      '$ref': '#/components/schemas/ColorsItem'
                    }
                  }
                }
              }
            }
          }
        }
        '/colors/{colorId}': {
          get: {
            tags: [
              'Colors'
            ]
            summary: 'Get color by id'
            description: 'Returns color specified by {colorId} (must be between 1 and 1000).'
            operationId: 'GetColorById'
            parameters: [
              {
                name: 'colorId'
                in: 'path'
                description: 'Id of Color to return'
                required: true
                schema: {
                  type: 'integer'
                  format: 'int32'
                }
              }
            ]
            responses: {
              '200': {
                description: 'Success - returns color'
                content: {
                  'text/plain': {
                    schema: {
                      '$ref': '#/components/schemas/ColorsItem'
                    }
                  }
                  'application/json': {
                    schema: {
                      '$ref': '#/components/schemas/ColorsItem'
                    }
                  }
                  'text/json': {
                    schema: {
                      '$ref': '#/components/schemas/ColorsItem'
                    }
                  }
                }
              }
              '404': {
                description: 'Not Found'
                content: {
                  'text/plain': {
                    schema: {
                      '$ref': '#/components/schemas/ProblemDetails'
                    }
                  }
                  'application/json': {
                    schema: {
                      '$ref': '#/components/schemas/ProblemDetails'
                    }
                  }
                  'text/json': {
                    schema: {
                      '$ref': '#/components/schemas/ProblemDetails'
                    }
                  }
                }
              }
              '422': {
                description: 'Unprocessable Entity'
                content: {
                  'text/plain': {
                    schema: {
                      '$ref': '#/components/schemas/ProblemDetails'
                    }
                  }
                  'application/json': {
                    schema: {
                      '$ref': '#/components/schemas/ProblemDetails'
                    }
                  }
                  'text/json': {
                    schema: {
                      '$ref': '#/components/schemas/ProblemDetails'
                    }
                  }
                }
              }
            }
          }
          post: {
            tags: [
              'Colors'
            ]
            summary: 'Update / create color by id'
            description: 'Updates color specified by {colorId} (must be between 1 and 1000);  use {colorId} = 0 to insert new color'
            operationId: 'UpdateColorById'
            parameters: [
              {
                name: 'colorId'
                in: 'path'
                description: 'Id of Color to update'
                required: true
                schema: {
                  type: 'integer'
                  format: 'int32'
                }
              }
            ]
            requestBody: {
              description: 'Colors to update'
              content: {
                'application/json': {
                  schema: {
                    '$ref': '#/components/schemas/ColorsItem'
                  }
                }
                'text/json': {
                  schema: {
                    '$ref': '#/components/schemas/ColorsItem'
                  }
                }
                'application/*+json': {
                  schema: {
                    '$ref': '#/components/schemas/ColorsItem'
                  }
                }
              }
              required: true
            }
            responses: {
              '201': {
                description: 'Success - color created/updated'
                content: {
                  'text/plain': {
                    schema: {
                      '$ref': '#/components/schemas/ColorsItem'
                    }
                  }
                  'application/json': {
                    schema: {
                      '$ref': '#/components/schemas/ColorsItem'
                    }
                  }
                  'text/json': {
                    schema: {
                      '$ref': '#/components/schemas/ColorsItem'
                    }
                  }
                }
              }
              '422': {
                description: 'Unprocessable Entity'
                content: {
                  'text/plain': {
                    schema: {
                      '$ref': '#/components/schemas/ProblemDetails'
                    }
                  }
                  'application/json': {
                    schema: {
                      '$ref': '#/components/schemas/ProblemDetails'
                    }
                  }
                  'text/json': {
                    schema: {
                      '$ref': '#/components/schemas/ProblemDetails'
                    }
                  }
                }
              }
            }
          }
          delete: {
            tags: [
              'Colors'
            ]
            summary: 'Delete color by id'
            description: 'Deletes color specified by {colorId} (must be between 1 and 1000).'
            operationId: 'DeleteColorById'
            parameters: [
              {
                name: 'colorId'
                in: 'path'
                description: 'Id of Color to delete'
                required: true
                schema: {
                  type: 'integer'
                  format: 'int32'
                }
              }
            ]
            responses: {
              '204': {
                description: 'Success - color deleted'
                content: {
                  'text/plain': {
                    schema: {
                      '$ref': '#/components/schemas/ColorsItem'
                    }
                  }
                  'application/json': {
                    schema: {
                      '$ref': '#/components/schemas/ColorsItem'
                    }
                  }
                  'text/json': {
                    schema: {
                      '$ref': '#/components/schemas/ColorsItem'
                    }
                  }
                }
              }
              '422': {
                description: 'Unprocessable Entity'
                content: {
                  'text/plain': {
                    schema: {
                      '$ref': '#/components/schemas/ProblemDetails'
                    }
                  }
                  'application/json': {
                    schema: {
                      '$ref': '#/components/schemas/ProblemDetails'
                    }
                  }
                  'text/json': {
                    schema: {
                      '$ref': '#/components/schemas/ProblemDetails'
                    }
                  }
                }
              }
            }
          }
        }
        '/colors/findbyname': {
          get: {
            tags: [
              'Colors'
            ]
            summary: 'Get color by name'
            description: 'Returns color specified by {colorName} '
            operationId: 'GetColorByName'
            parameters: [
              {
                name: 'colorName'
                in: 'query'
                description: 'Name of Color to return'
                required: true
                schema: {
                  type: 'string'
                }
              }
            ]
            responses: {
              '200': {
                description: 'Success - returns color'
                content: {
                  'text/plain': {
                    schema: {
                      '$ref': '#/components/schemas/ColorsItem'
                    }
                  }
                  'application/json': {
                    schema: {
                      '$ref': '#/components/schemas/ColorsItem'
                    }
                  }
                  'text/json': {
                    schema: {
                      '$ref': '#/components/schemas/ColorsItem'
                    }
                  }
                }
              }
              '404': {
                description: 'Not Found'
                content: {
                  'text/plain': {
                    schema: {
                      '$ref': '#/components/schemas/ProblemDetails'
                    }
                  }
                  'application/json': {
                    schema: {
                      '$ref': '#/components/schemas/ProblemDetails'
                    }
                  }
                  'text/json': {
                    schema: {
                      '$ref': '#/components/schemas/ProblemDetails'
                    }
                  }
                }
              }
            }
          }
        }
        '/colors/random': {
          get: {
            tags: [
              'Colors'
            ]
            summary: 'Get random color'
            description: 'Returns random color.'
            operationId: 'GetRandomColor'
            responses: {
              '200': {
                description: 'Success - returns random color'
                content: {
                  'text/plain': {
                    schema: {
                      '$ref': '#/components/schemas/ColorsItem'
                    }
                  }
                  'application/json': {
                    schema: {
                      '$ref': '#/components/schemas/ColorsItem'
                    }
                  }
                  'text/json': {
                    schema: {
                      '$ref': '#/components/schemas/ColorsItem'
                    }
                  }
                }
              }
              '404': {
                description: 'Not Found'
                content: {
                  'text/plain': {
                    schema: {
                      '$ref': '#/components/schemas/ProblemDetails'
                    }
                  }
                  'application/json': {
                    schema: {
                      '$ref': '#/components/schemas/ProblemDetails'
                    }
                  }
                  'text/json': {
                    schema: {
                      '$ref': '#/components/schemas/ProblemDetails'
                    }
                  }
                }
              }
            }
          }
        }
        '/colors/reset': {
          post: {
            tags: [
              'Colors'
            ]
            summary: 'Reset colors'
            description: 'Reset colors to default.'
            operationId: 'ResetColors'
            responses: {
              '201': {
                description: 'Success - colors reset'
                content: {
                  'text/plain': {
                    schema: {
                      '$ref': '#/components/schemas/ColorsItem'
                    }
                  }
                  'application/json': {
                    schema: {
                      '$ref': '#/components/schemas/ColorsItem'
                    }
                  }
                  'text/json': {
                    schema: {
                      '$ref': '#/components/schemas/ColorsItem'
                    }
                  }
                }
              }
            }
          }
        }
      }
      components: {
        schemas: {
          ColorsItem: {
            required: [
              'id'
              'name'
            ]
            type: 'object'
            properties: {
              id: {
                type: 'integer'
                description: 'Represents a numeric identifier for the color. It is required and must be an integer.'
                format: 'int32'
              }
              name: {
                minLength: 1
                type: 'string'
                description: 'Represents the name of the color. It is required and must be a string.'
              }
              hexcode: {
                type: 'string'
                description: 'Represents the hexadecimal code for the color. It is optional and can be an empty string.'
              }
              data: {
                type: 'string'
                description: 'Represents additional data or metadata related to the color. It is optional and can be an empty string.'
              }
            }
            additionalProperties: false
            description: 'An object representing a color with its identifier, name, hexadecimal code, and additional data.'
          }
          ProblemDetails: {
            type: 'object'
            properties: {
              type: {
                type: 'string'
                nullable: true
              }
              title: {
                type: 'string'
                nullable: true
              }
              status: {
                type: 'integer'
                format: 'int32'
                nullable: true
              }
              detail: {
                type: 'string'
                nullable: true
              }
              instance: {
                type: 'string'
                nullable: true
              }
            }
            additionalProperties: {}
          }
        }
      }
    }
  }
}

resource colorsApiSchema 'Microsoft.ApiManagement/service/apis/schemas@2024-06-01-preview' = {
  parent: colorsApi
  name: 'colorsApiSchema'
  properties: {
    contentType: 'application/vnd.oai.openapi.components+json'
    document: {}
  }
}

resource colorsApi_DeleteColorById_Colors 'Microsoft.ApiManagement/service/apis/operations/tags@2024-06-01-preview' = {
  parent: colorsApi_DeleteColorById
  name: 'Colors'
}

resource colorsApi_DeletesColors_Colors 'Microsoft.ApiManagement/service/apis/operations/tags@2024-06-01-preview' = {
  parent: colorsApi_DeletesColors
  name: 'Colors'
}

resource colorsApi_GetColorById_Colors 'Microsoft.ApiManagement/service/apis/operations/tags@2024-06-01-preview' = {
  parent: colorsApi_GetColorById
  name: 'Colors'
}

resource colorsApi_GetColorByName_Colors 'Microsoft.ApiManagement/service/apis/operations/tags@2024-06-01-preview' = {
  parent: colorsApi_GetColorBy
  name: 'Colors'
}

resource colorsApi_GetColors_Colors 'Microsoft.ApiManagement/service/apis/operations/tags@2024-06-01-preview' = {
  parent: colorsApi_GetColors
  name: 'Colors'
}

resource colorsApi_GetRandomColor_Colors 'Microsoft.ApiManagement/service/apis/operations/tags@2024-06-01-preview' = {
  parent: colorsApi_GetRandomColor
  name: 'Colors'
}

resource colorsApi_ResetColors_Colors 'Microsoft.ApiManagement/service/apis/operations/tags@2024-06-01-preview' = {
  parent: colorsApi_ResetColors
  name: 'Colors'
}

resource colorsApi_UpdateColorById_Colors 'Microsoft.ApiManagement/service/apis/operations/tags@2024-06-01-preview' = {
  parent: colorsApi_UpdateColorById
  name: 'Colors'
}

resource colorsApi_UpdateColors_Colors 'Microsoft.ApiManagement/service/apis/operations/tags@2024-06-01-preview' = {
  parent: colorsApi_UpdateColors
  name: 'Colors'
}

// Star Wars APIs
resource starWarsApi 'Microsoft.ApiManagement/service/apis@2024-06-01-preview' = {
  parent: apim
  name: 'star-wars'
  properties: {
    displayName: 'Star Wars'
    apiRevision: '1'
    description: 'The Star Wars API'
    subscriptionRequired: true
    serviceUrl: 'https://swapi.tech/api'
    path: 'sw'
    protocols: [
      'https'
    ]
    authenticationSettings: {
      oAuth2AuthenticationSettings: []
      openidAuthenticationSettings: []
    }
    subscriptionKeyParameterNames: {
      header: 'Ocp-Apim-Subscription-Key'
      query: 'subscription-key'
    }
    isCurrent: true
  }
}

resource starWarsApi_policy 'Microsoft.ApiManagement/service/apis/policies@2024-06-01-preview' = {
  parent: starWarsApi
  name: 'policy'
  properties: {
    value: '<!--\r\n    - Policies are applied in the order they appear.\r\n    - Position <base/> inside a section to inherit policies from the outer scope.\r\n    - Comments within policies are not preserved.\r\n-->\r\n<!-- Add policies as children to the <inbound>, <outbound>, <backend>, and <on-error> elements -->\r\n<policies>\r\n  <!-- Throttle, authorize, validate, cache, or transform the requests -->\r\n  <inbound>\r\n    <base />\r\n    <set-header name="Ocp-Apim-Subscription-Key" exists-action="delete" />\r\n  </inbound>\r\n  <!-- Control if and how the requests are forwarded to services  -->\r\n  <backend>\r\n    <base />\r\n  </backend>\r\n  <!-- Customize the responses -->\r\n  <outbound>\r\n    <base />\r\n  </outbound>\r\n  <!-- Handle exceptions and customize error responses  -->\r\n  <on-error>\r\n    <base />\r\n  </on-error>\r\n</policies>'
    format: 'xml'
  }
}

resource starWarsApi_get_people 'Microsoft.ApiManagement/service/apis/operations@2024-06-01-preview' = {
  parent: starWarsApi
  name: 'get-people'
  properties: {
    displayName: 'Get People'
    method: 'GET'
    urlTemplate: '/people/'
    templateParameters: []
    responses: []
  }
}

resource starWarsApi_get_people_by_id 'Microsoft.ApiManagement/service/apis/operations@2024-06-01-preview' = {
  parent: starWarsApi
  name: 'get-people-by-id'
  properties: {
    displayName: 'Get People By Id'
    method: 'GET'
    urlTemplate: '/people/{id}/'
    templateParameters: [
      {
        name: 'id'
        required: true
        values: []
        type: 'integer'
      }
    ]
    responses: []
  }
}
