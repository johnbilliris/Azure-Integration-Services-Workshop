using System;
using System.IO;
using System.Threading.Tasks;
using System.Text;
using System.Text.Json;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;
using Azure.Storage.Blobs;
using Azure.Storage.Blobs.Models;
using Microsoft.Extensions.Azure;
using Azure.Messaging.EventHubs;

namespace Company.Function
{
    public class EventProcessor
    {
        private readonly ILogger<EventProcessor> _logger;
        private readonly BlobContainerClient _containerClient;

        public EventProcessor(ILogger<EventProcessor> logger, IAzureClientFactory<BlobServiceClient> blobClientFactory)
        {
            _logger = logger;
            _containerClient = blobClientFactory.CreateClient("EventStorage").GetBlobContainerClient("events");
        }

        [Function("ProcessEventHubMessages")]
        public async Task Run(
            [EventHubTrigger("%EventHubName%", ConsumerGroup = "%EventHubConsumerGroupName%", Connection = "EventHubConnection")] MyEventType[] events,
            FunctionContext context
        )
        {
            _logger.LogInformation($"Event Hub Trigger starting to process {events.Length} events");

            foreach (var eventData in events)
            {
                _logger.LogInformation($"Processing event with id: {eventData.Id}");
                await CopyToProcessedContainerAsync(eventData, $"{eventData.Id}.json");
            }

            _logger.LogInformation($"Event Hub Trigger finished processing all events");
        }


         // Simple async method to demonstrate saving the incoming event data
        private async Task CopyToProcessedContainerAsync(MyEventType input, string blobName)
        {
            _logger.LogInformation($"Starting async save operation for {blobName}");
            
            // Get a reference to the blob
            var blobClient = _containerClient.GetBlobClient(blobName);
            
            // Serialize the event data to JSON
            var jsonString = JsonSerializer.Serialize(input, new JsonSerializerOptions 
            { 
                WriteIndented = true,
                PropertyNamingPolicy = JsonNamingPolicy.CamelCase
            });
            
            // Convert to byte array
            var jsonBytes = Encoding.UTF8.GetBytes(jsonString);
            
            // Configure blob HTTP headers
            var httpHeaders = new BlobHttpHeaders
            {
                ContentType = "application/json",
                ContentEncoding = "utf-8"
            };

            // Upload the blob
            using var stream = new MemoryStream(jsonBytes);
            await blobClient.UploadAsync(stream, httpHeaders);

            // Set metadata separately
            var metadata = new Dictionary<string, string>
            {
                ["eventId"] = input.Id?.ToString() ?? "unknown",
                ["processedAt"] = DateTimeOffset.UtcNow.ToString("O"),
                ["eventType"] = nameof(MyEventType)
            };
            await blobClient.SetMetadataAsync(metadata);

            _logger.LogInformation($"Successfully saved {blobName} to events container");
        }
    }
}
