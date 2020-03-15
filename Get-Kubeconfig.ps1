param(
    [string]$name,
    [string]$resourceGroup,
)

az aks get-credentials --name $name --resource-group $resourceGroup