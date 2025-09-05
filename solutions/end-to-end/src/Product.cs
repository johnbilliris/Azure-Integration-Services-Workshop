using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;
using System.Net;
using System.Text.Json;
using System.Text.Json.Serialization;

namespace My.Functions;

public class Products
{
    private readonly ILogger<Products> _logger;

    public Products(ILogger<Products> logger)
    {
        _logger = logger;
    }

    [Function("Product")]
    public async Task<OutputType> NewProduct([HttpTrigger(AuthorizationLevel.Anonymous, "POST")] HttpRequestData req,
        FunctionContext executionContext,
        [Microsoft.Azure.Functions.Worker.Http.FromBody] Product product)
    {
        _logger.LogInformation("Product function processing a request.");
        HttpResponseData response = req.CreateResponse(HttpStatusCode.OK);

        if (product == null)
        {
            response.StatusCode = HttpStatusCode.BadRequest;
            await response.WriteStringAsync("Invalid product data.");
            return new OutputType()
            {
                HttpResponse = response
            };
        }
        if (string.IsNullOrEmpty(product.Id))
        {
            product.Id = Guid.NewGuid().ToString();
        }

        await response.WriteStringAsync("New product created successfully!");
        return new OutputType()
        {
            OutputEvent = product,
            HttpResponse = response
        };
    }
}

public class Product
{
    [JsonPropertyName("id")]
    public string? Id { get; set; }
    [JsonPropertyName("name")]  
    [JsonRequired]
    public required string Name { get; set; }
    [JsonPropertyName("description")]
    [JsonRequired]
    public required string Description { get; set; }
    [JsonPropertyName("price")]
    [JsonRequired]
    public decimal Price { get; set; }
}

public class OutputType
{
    [ServiceBusOutput("product", Connection = "ServiceBusConnection")]
    public Product? OutputEvent { get; set; }

    [HttpResult]
    public required HttpResponseData HttpResponse { get; set; }
}