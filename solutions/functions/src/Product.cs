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

    [Function("NewProduct")]
    public async Task<OutputType> NewProduct([HttpTrigger(AuthorizationLevel.Anonymous, "post")] HttpRequestData req,
        FunctionContext executionContext,
        [Microsoft.Azure.Functions.Worker.Http.FromBody] Product product)
    {
        _logger.LogInformation("NewProduct function processing a request.");
        HttpResponseData response = req.CreateResponse(HttpStatusCode.InternalServerError);

        try
        {
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

            response = req.CreateResponse(HttpStatusCode.OK);
            await response.WriteStringAsync("New product created successfully!");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error occurred while processing NewProduct request.");
            response = req.CreateResponse(HttpStatusCode.InternalServerError);
            await response.WriteStringAsync("An error occurred while creating the product.");
            return new OutputType()
            {
                HttpResponse = response
            };
        }
        finally
        {

        }
        
        _logger.LogInformation("NewProduct function processed a request.");
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
    public string Id { get; set; }
    [JsonPropertyName("name")]  
    [JsonRequired]
    public string Name { get; set; }
    [JsonPropertyName("description")]
    [JsonRequired]
    public string Description { get; set; }
    [JsonPropertyName("price")]
    [JsonRequired]
    public decimal Price { get; set; }
}

public class OutputType
{
    [ServiceBusOutput("product", Connection = "ServiceBusConnection")]
    public Product OutputEvent { get; set; }

    [HttpResult]
    public HttpResponseData HttpResponse { get; set; }
}