#!/bin/bash

# Get values from azd environment
echo "Getting environment values from azd..."
ServiceBusConnection=$(azd env get-values | grep ServiceBusConnection | cut -d'"' -f2)

# Create or update local.settings.json
echo "Generating local.settings.json in src directory..."
cat > src/local.settings.json << EOF
{
  "IsEncrypted": false,
  "Values": {
    "AzureWebJobsStorage": "UseDevelopmentStorage=true",
    "FUNCTIONS_WORKER_RUNTIME": "dotnet-isolated",
    "ServiceBusConnection":"$ServiceBusConnection"
  }
}
EOF

echo "local.settings.json generated successfully in src directory!"