# PowerShell script to generate local.settings.json

# Get values from azd environment
Write-Host "Getting environment values from azd..."
$azdValues = azd env get-values
$AZUREWEBJOBSSTORAGE = ($azdValues | Select-String 'AZUREWEBJOBSSTORAGE="(.*?)"').Matches.Groups[1].Value
$EventHubName = ($azdValues | Select-String 'EventHubName="(.*?)"').Matches.Groups[1].Value
$EventHubConsumerGroupName = ($azdValues | Select-String 'EventHubConsumerGroupName="(.*?)"').Matches.Groups[1].Value
$EventHubConnection = ($azdValues | Select-String 'EventHubConnection="(.*?)"').Matches.Groups[1].Value

# Create the JSON content
$jsonContent = @"
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
"@

# Write content to local.settings.json
$settingsPath = Join-Path (Get-Location) "src" "local.settings.json"
$jsonContent | Out-File -FilePath $settingsPath -Encoding utf8

Write-Host "local.settings.json generated successfully in src directory!"