function storageAccount {
[cmdletbinding()]
param(
    [string]$resourceGroupName = "Dev10",
    [string]$storageAccountName = "cloudskillstfstate",
    [string]$containerName = "tfstate"
)

az group create --name $resourceGroupName --location eastus2
az storage account create --resource-group $resourceGroupName --name $storageAccountName --sku Standard_LRS --encryption-services blob
$primaryKey=$(az storage account keys list --resource-group $resourceGroupName --account-name $storageAccountName --query [0].value -o tsv)
az storage container create --name $containerName --account-name $storageAccountName --account-key $primaryKey
}