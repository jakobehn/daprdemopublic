$RESOURCE_GROUP="containerapp"
$LOCATION="northeurope"
$LOG_ANALYTICS_WORKSPACE="containerapps-logs"
$CONTAINERAPPS_ENVIRONMENT="containerapp-env"

# # Create resource group
az group create `
  --name $RESOURCE_GROUP `
  --location "$LOCATION"

# # Create log analytics workspace
az monitor log-analytics workspace create `
  --resource-group $RESOURCE_GROUP `
  --workspace-name $LOG_ANALYTICS_WORKSPACE

$LOG_ANALYTICS_WORKSPACE_CLIENT_ID=(az monitor log-analytics workspace show --query customerId -g $RESOURCE_GROUP -n $LOG_ANALYTICS_WORKSPACE --out tsv)
$LOG_ANALYTICS_WORKSPACE_CLIENT_SECRET=(az monitor log-analytics workspace get-shared-keys --query primarySharedKey -g $RESOURCE_GROUP -n $LOG_ANALYTICS_WORKSPACE --out tsv)

# # Create container apps environment
az containerapp env create `
  --name $CONTAINERAPPS_ENVIRONMENT `
  --resource-group $RESOURCE_GROUP `
  --logs-workspace-id $LOG_ANALYTICS_WORKSPACE_CLIENT_ID `
  --logs-workspace-key $LOG_ANALYTICS_WORKSPACE_CLIENT_SECRET `
  --location "$LOCATION"

# Deploy orderweb
az containerapp create `
    --name orderweb `
    --resource-group $RESOURCE_GROUP `
    --environment $CONTAINERAPPS_ENVIRONMENT `
    --image <acr>.azurecr.io/orderweb:1.1 `
    --target-port 80 `
    --ingress 'external' `
    --enable-dapr `
    --dapr-app-port 80 `
    --dapr-app-id orderweb `
    --dapr-components .\statestore.yaml `
    --registry-login-server <acr>.azurecr.io `
    --registry-username <username> `
    --registry-password <password> `
    --environment-variables DAPR_HTTP_PORT=3500

# Deploy orderapi
az containerapp create `
    --name orderapi `
    --resource-group $RESOURCE_GROUP `
    --environment $CONTAINERAPPS_ENVIRONMENT `
    --image <acr>.azurecr.io/orderapi:1.1 `
    --enable-dapr `
    --dapr-app-port 80 `
    --dapr-app-id orderapi `
    --dapr-components .\statestore.yaml `
    --registry-login-server <acr>.azurecr.io `
    --registry-username <acr> `
    --registry-password <password> `
    --environment-variables DAPR_HTTP_PORT=3500

# Deploy warehouseapi
az containerapp create `
    --name warehouseapi `
    --resource-group $RESOURCE_GROUP `
    --environment $CONTAINERAPPS_ENVIRONMENT `
    --image <acr>.azurecr.io/warehouseapi:1.1 `
    --min-replicas 1 `
    --max-replicas 10 `
    --enable-dapr `
    --dapr-app-port 80 `
    --dapr-app-id warehouseapi `
    --dapr-components .\statestore.yaml `
    --registry-login-server <acr>.azurecr.io `
    --registry-username <acr> `
    --registry-password <password> `
    --environment-variables DAPR_HTTP_PORT=3500