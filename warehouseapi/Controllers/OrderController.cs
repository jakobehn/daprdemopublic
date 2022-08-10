using Microsoft.AspNetCore.Mvc;

namespace warehouseapi.Controllers;

[ApiController]
[Route("[controller]")]
public class OrderCreatedController : ControllerBase
{

    private readonly ILogger<OrderCreatedController> _logger;

    public OrderCreatedController(ILogger<OrderCreatedController> logger)
    {
        _logger = logger;
    }

    [HttpPost]
    public async Task Post(Order order)
    {
        //TODO: Send notification
    }    
}
