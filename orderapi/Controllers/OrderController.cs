using Microsoft.AspNetCore.Mvc;

namespace orderapi.Controllers;

[ApiController]
[Route("[controller]")]
public class OrderController : ControllerBase
{

    private readonly ILogger<OrderController> _logger;

    public OrderController(ILogger<OrderController> logger)
    {
        _logger = logger; 
    }

    [HttpGet(Name = "GetOrder")]
    public Order Get(Guid orderId)
    {
        return new Order();
    }

    [HttpPost(Name = "PostOrder")]
    public async Task Post(Order order)
    {
        var client = new Dapr.Client.DaprClientBuilder().Build();
        await client.PublishEventAsync<Order>("orderpubsub", "ordercreated", order);
    }    
}
