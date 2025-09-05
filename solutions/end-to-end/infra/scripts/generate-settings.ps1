# PowerShell script to generate local.settings.json

# Get values from azd environment
Write-Host "Getting environment values from azd..."
$azdValues = azd env get-values
$ServiceBusConnection = ($azdValues | Select-String 'ServiceBusConnection="(.*?)"').Matches.Groups[1].Value

# Create the JSON content
$jsonContent = @"
{
  "IsEncrypted": false,
  "Values": {
    "AzureWebJobsStorage": "UseDevelopmentStorage=true",
    "FUNCTIONS_WORKER_RUNTIME": "dotnet-isolated",
    "ServiceBusConnection":"$ServiceBusConnection"
  }
}
"@

# Write content to local.settings.json
$settingsPath = Join-Path (Get-Location) "src" "local.settings.json"
$jsonContent | Out-File -FilePath $settingsPath -Encoding utf8

Write-Host "local.settings.json generated successfully in src directory!"