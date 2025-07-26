#!/bin/bash

# Get values from azd environment
echo "Getting environment values from azd..."
AZUREWEBJOBSSTORAGE=$(azd env get-values | grep AZUREWEBJOBSSTORAGE | cut -d'"' -f2)
EventHubName=$(azd env get-values | grep EventHubName | cut -d'"' -f2)
EventHubConsumerGroupName=$(azd env get-values | grep EventHubConsumerGroupName | cut -d'"' -f2)
EventHubConnection=$(azd env get-values | grep EventHubConnection | cut -d'"' -f2)

# Create or update local.settings.json
echo "Generating local.settings.json in src directory..."
cat > src/local.settings.json << EOF
{
  "IsEncrypted": false,
  "Values": {
    "AzureWebJobsStorage": "UseDevelopmentStorage=true",
    "FUNCTIONS_WORKER_RUNTIME": "dotnet-isolated",
    "EventStorage": "$AZUREWEBJOBSSTORAGE",
    "EventHubName": "$EventHubName",
    "EventHubConsumerGroupName": "$EventHubConsumerGroupName",
    "EventHubConnection": "$EventHubConnection"
  }
}
EOF

echo "local.settings.json generated successfully in src directory!"