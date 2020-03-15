function newAppRegistration {
    
    param(
        [string]$name = "cloudskills",
        [string]$keyvaultName = "sp-keyvault-cloudskills"
    )
    
    # Create App Registration
    $appCreation = az ad sp create-for-rbac --skip-assignment --name $name | ConvertFrom-Json
    $appCreation
    
    # Retrieve the Client ID for KeyVault
    $clientID = az ad app list --display-name $name --query "[].{SyncRoot:appId}" | ConvertFrom-Json | Select -ExpandProperty SyncRoot
    
    az keyvault secret set --vault-name $keyvaultName --name "AKSClientID" --value $clientID.SyncRoot
    az keyvault secret set --vault-name $keyvaultName --name "AKSClientSecret" --value $appCreation.password
    }