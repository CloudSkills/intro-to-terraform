# Terraform CloudSkills.io Bootcamp

## Prerequisites

1. Azure subscription
2. Install AZ CLI
3. Configure AZ CLI

## Code

Code for this bootcamp can be found [here](https://github.com/AdminTurnedDevOps/CloudskillsCode/tree/master/CloudSkills_DevOps_Bootcamp)

## What is Terraform?

Terraform is an open-source infrastructure-as-code tool written in HCL (HashiCorp configuration language) by [HashiCorp](https://www.hashicorp.com/). 

### Is Terraform Popular?

Absolutely!

![Terraform%20CloudSkills%20io%20Bootcamp/Untitled.png](Terraform%20CloudSkills%20io%20Bootcamp/Untitled.png)

## Immutable vs Mutable

There are several long posts and even books written on immutable vs mutable languages, but let's keep it simple.

**Mutable** == Changes happen over time. As you apply more and more changes. the server builds a history. This could lead to configuration drift because depending on what changes you're making to each server, the other servers may not have the same changes. This can be avoided by following proper configuration management protocols.

**Immutable** == Each change is net new. For example, if you're deploying a new server, then deploy that server again, it's not making changes to the existing. It's creating a new one. This is a big issue because a lot of organizations simply aren't ready for immutable infrastructure due to the nature of it *blowing away what already exists*.

![Terraform%20CloudSkills%20io%20Bootcamp/Untitled%201.png](Terraform%20CloudSkills%20io%20Bootcamp/Untitled%201.png)

Fun Fact: Terraform is considered a functional programming language due to its immutable and declarative nature.

### Declarative vs Procedural

Declarative vs Procedural come into play for a lot of Terraform users.

Let's take Ansible and Terraform for example. Ansible encourages a procedural style, or a step-by-step to the end state of your infrastructure in code. Terraform encourages a declarative style. You write code that specifies the desired end state, and the IaC tool itself is responsible for figuring out how to achieve that state.

## Azure CLI Configuration

1. Install the Azure CLI: [https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
2. From your terminal run `az login`. A web browser will show. Type in your email and password that you use to log into your Azure portal.
3. If successful you will see a screen that says "You have logged into Azure successfully".
4. Your terminal that you ran `az login` from will show your subscription.

If you need to set a specific subscription, run the following:
`az account set --subscription="SUBSCRIPTION_ID"`

## Terraform State Configuration

The Terraform state file ([.TFSTATE](https://www.terraform.io/docs/state/index.html)) is the metadata for your environment configuration. Any time a configuration is updated, the TFSTATE is used. If the existing TFSTATE is **NOT** used, a new environment gets created.

The TFSTATE configuration should be stored in a centralized location so everyone on the team can use it. In Azure, the TFSTATE is recommended to be stored in a storage account.

The code to automatically create the storage account can be found [here](https://github.com/AdminTurnedDevOps/CloudskillsCode/blob/master/CloudSkills_DevOps_Bootcamp/TFSTATE_Storage_Account/storageAccount.ps1)

## Authentication and Permissions

### KeyVault

For Terraform to create Azure Kubernetes Services (AKS) resources, permissions need to exist. To create other Terraform resources, you can authenticate using the AZ CLI. For the `azurerm_kubernetes_cluster` Terraform resource to authenticate, it requires a service principal.

The code to automatically create the KeyVault can be found [here](https://github.com/AdminTurnedDevOps/CloudskillsCode/blob/master/CloudSkills_DevOps_Bootcamp/Service_Principal/servicePrincipalKeyvault.ps1)

Once the KeyVault is created, the app registration gets created in the Azure portal.

### App Registration

App registration allows the AKS cluster to be created by providing Terraform a service principal that contains a client ID and a client secret (similar to a username and password).

The code to automatically create the app registration can be found [here](https://github.com/AdminTurnedDevOps/CloudskillsCode/blob/master/CloudSkills_DevOps_Bootcamp/Service_Principal/newAppRegistration.ps1)

### KeyVault Permissions for Azure DevOps

Once the pipeline is ran, you may get an error similar to the error below.

    2020-03-09T11:07:44.4067497Z ##[error]
    AKSClientID: "Access denied. Caller was not found on any access policy.\r\nCaller: appid=***;oid=some_guid_will_be_here

The error occurs because the pipeline's service/client ID does not have access to KeyVault. The service/client ID is automatically generated in [app registrations](https://docs.microsoft.com/en-us/azure/active-directory/develop/quickstart-register-app). To add the necessary access to KeyVault, you can do one of three things;

1. Go to *[app registrations](https://portal.azure.com/#blade/Microsoft_AAD_RegisteredApps/ApplicationsListBlade)* in the Azure portal and search for the Azure DevOps project's client ID. The name of the client ID will be in the following format:

    `AzureDevOps_OrganizationName-ProjectName-subscriptionID`

    ![Terraform%20CloudSkills%20io%20Bootcamp/Untitled%202.png](Terraform%20CloudSkills%20io%20Bootcamp/Untitled%202.png)

     Once you have the client ID, go to KeyVault —> Access Policies —> click on the blue *+ Add Access Policy* button as shown in the screenshot below.

![Terraform%20CloudSkills%20io%20Bootcamp/Untitled%203.png](Terraform%20CloudSkills%20io%20Bootcamp/Untitled%203.png)

  2.  Copy/paste the GUID from the `Access denied` output above. Once you have the client ID, go to KeyVault —> Access Policies —> click on the blue *+ Add Access Policy* button.

  3.  Copy the client ID that you receive from app registrations in step one and add the client ID to the `$AzureDevOpsClientID` parameter found in [this script](https://github.com/AdminTurnedDevOps/CloudskillsCode/blob/master/CloudSkills_DevOps_Bootcamp/Keyvault/servicePrincipalKeyvault.ps1).

## Building the Terraform Code

The Terraform code will be build in the Continuous Integration (CI) section of Azure. As this code is lives in a GitHub repository, it will be copied and published as an artifact to Azure DevOps within the build pipeline.

For the Azure DevOps tasks in the release pipeline, you will be using;

![Terraform%20CloudSkills%20io%20Bootcamp/Untitled%204.png](Terraform%20CloudSkills%20io%20Bootcamp/Untitled%204.png)

- The first task copies the code from GitHub to Azure DevOps
- The second task published the code as an artifact to be used in the release pipeline which you will see in the next section **Creating the AKS Cluster in Azure DevOps**

## Creating the AKS Cluster in Azure DevOps

Creating the AKS cluster is done with Terraform in Azure DevOps. The defaults of the AKS cluster are;

1. One worker node
2. Standard_D2_v2 vm size (D series)
3. Environment is development

For the Azure DevOps tasks in the release pipeline, you will be using;

![Terraform%20CloudSkills%20io%20Bootcamp/Untitled%205.png](Terraform%20CloudSkills%20io%20Bootcamp/Untitled%205.png)

- The first two tasks are for KeyVault. This is where your client ID and secret key exist for the AKS deployment.
- The third task is for installing Terraform on the microsoft-hosted agent, which is a container, running the release pipeline
- The fourth, fifth, and sixth task is for initializing (staging) the Terraform environment, planning the deployment to ensure no errors, and deploying (applying) the AKS cluster.

## Creating the AKS Cluster in Azure DevOps with YAML Pipelines

For the multi-stage/YAML pipeline, you will be using the same code for the AKS deployment. The only difference is the deployment will be done with an Azure DevOps YAML pipeline.

The code for this pipeline can be found [here](https://github.com/AdminTurnedDevOps/CloudskillsCode/blob/master/azure-pipelines.yml).

![Terraform%20CloudSkills%20io%20Bootcamp/Untitled%206.png](Terraform%20CloudSkills%20io%20Bootcamp/Untitled%206.png)

## Retrieving the Kubernetes Configuration (Kubeconfig)

To retrieve the Kubernetes (kubeconfig) locally and start interacting with AKS, you'll need to clone the Kubernetes configuration. The `AZ CLI` gives a helpful command to do that.

    az aks get-credentials --name MyManagedCluster --resource-group MyResourceGroup

![Terraform%20CloudSkills%20io%20Bootcamp/Untitled%207.png](Terraform%20CloudSkills%20io%20Bootcamp/Untitled%207.png)

After the Kubeconfig is set as your context, you will be able to manage the Kubernetes environment from your localhost.

![Terraform%20CloudSkills%20io%20Bootcamp/Untitled%208.png](Terraform%20CloudSkills%20io%20Bootcamp/Untitled%208.png)

## Creating a Kubernetes Deployment

For the deployment, it will be a basic Nginx container running inside of a Kubernetes deployment. The code can be found [here](https://github.com/AdminTurnedDevOps/CloudskillsCode/blob/master/CloudSkills_DevOps_Bootcamp/Nginx_Example_App/nginx.yml).

The command to create the Kubernetes deployment from the `.yml` is below. The command will take the Nginx YAML file and configure a Kubernetes deployment running in AKS.

`kubectl create -f Nginx_Example_App/nginx.yml`

The Kubernetes deployment will be created on a local terminal. Below is a screenshot of spinning up the deployment.

![Terraform%20CloudSkills%20io%20Bootcamp/Untitled%209.png](Terraform%20CloudSkills%20io%20Bootcamp/Untitled%209.png)

## Create a Kubernetes Service

A Kubernetes service is what is used after you create a deployment to make the service public to the world. In some cases, you don't want to do this. In this case since it's a web server, it should be public facing.

The command to create the Kubernetes service is below. The `expose` command looks at an existing deployment (in this case, the Nginx deployment) and turns the deployment into a public-facing service that is accessible at the load balancer.

`kubectl expose deployment nginx-deployment --type=LoadBalancer --name=nginx-service`

Going into the load balancer section in the [Azure portal](https://portal.azure.com/#@mlevan1992outlook.onmicrosoft.com/resource/subscriptions/220284d2-6a19-4781-87f8-5c564ec4fec9/resourceGroups/mc_dev10_cloudskills-aks01_eastus2/providers/Microsoft.Network/loadBalancers/kubernetes/overview), you can see the load balancer created. If I go to the public IP address shown in the screenshot below, I will get an Nginx splash page.

![Terraform%20CloudSkills%20io%20Bootcamp/Untitled%2010.png](Terraform%20CloudSkills%20io%20Bootcamp/Untitled%2010.png)

![Terraform%20CloudSkills%20io%20Bootcamp/Untitled%2011.png](Terraform%20CloudSkills%20io%20Bootcamp/Untitled%2011.png)