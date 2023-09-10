targetScope = 'subscription'

@minLength(1)
@maxLength(4)
@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param environmentName string

@minLength(1)

@description('Primary location for all resources')
param location string

@description('The resouce name prefix to generate names if prvided resource name is blank')
param namePrefix string

@description('Default Tags for all resources')
param tags object

param servicePrincipalObjectId string

@description('The resource group name')
param resourceGroupName string

@description('The virtual network name')
param vnetName string

@description('The virtual network address prefix')
param vnetAddressPrefix string

@description('The firewall subnet address prefix')
param firewallSubnetAddressPrefix string

@description('The firewall subnet management address prefix')
param firewallManagementSubnetAddressPrefix string

@description('The container subnet address prefix')
param containerSubnetAddressPrefix string

@description('The private subnet address prefix')
param privateEndpointSubnetAddressPrefix string

@description('The network security group name')
param nsgName string

@description('The storage account name')
param storageAccountName string

@description('The storage account access tier')
param storageAccessTier string

@description('The storage account sku name')
param storageSkuName string

@description('The storage account container name')
param storageContainerName string

@description('The keyvault name')
param keyVaultName string

@description('The keyvault sku name')
param keyvaultSkuName string

@description('The log analytics workspace name')
param logAnalyticsWorkspaceName string

@description('The appinsgights name')
param appinsightsName string

@description('The search service name')
param searchServiceName string

@description('The search service sku name')
param searchServiceSkuName string = 'standard'

@description('The search index name')
param searchIndexName string

@description('The Content field name')
param kbFieldContent string

@description('The sourcepage field name')
param kbFieldSourcePage string

@description('The form recognizer service name')
param formRecognizerServiceName string

@description('The form recognizer service sku name')
param formRecognizerSkuName string = 'S0'

@description('The openai service name')
param openAiServiceName string

@description('The openapi service sku name')
param openAiSkuName string = 'S0'

@description('The openapi gpt deployment name')
param gptDeploymentName string = 'text_completion'

@description('The openapi gpt embeddings deployment name')
param gptEmbeddingDeploymentName string = 'embeddings'

@description('The openapi GPT deployment name')
param gptModelDeployments array = []

@description('The user identity name')
param userIdentityName string 

@description('The container registry name')
param containerRegistryName string 

@description('The container managed environment name')
param containerAppEnvName string

@description('The number of CPU cores allocated to a single container instance, e.g., 0.5')
param containerCpuCoreCount string = '0.5'

@description('The maximum number of replicas to run. Must be at least 1.')
@minValue(1)
param containerMaxReplicas int = 10

@description('The amount of memory allocated to a single container instance, e.g., 1Gi')
param containerMemory string = '1.0Gi'

@description('The minimum number of replicas to run. Must be at least 1.')
@minValue(1)
param containerMinReplicas int = 1

@allowed([ 'http', 'grpc' ])
@description('The protocol used by Dapr to connect to the app, e.g., HTTP or gRPC')
param daprAppProtocol string = 'http'

@description('Enable or disable Dapr for the container app')
param daprEnabled bool = false

@description('The Dapr app ID')
param daprAppId string = 'dapr-backend'

@description('The name of the container image for python backend')
param backendImageName string = 'chatbot-backend'

@description('The version of the backend container image')
param backendImageVersion string = '1.0.0'

@description('The name of the container image for node frontend')
param frontendImageName string = 'chatbot-frontend'

@description('The version of the frontend container image')
param frontendImageversion string = '1.0.0'

@description('The secrets required for the container')
param secrets array = []

@description('Specifies if the resource is external')
param external bool = false

@description('The git repo url')
param gitRepoUrl string 

@description('The git token')
param gitToken string 

// Variables
var locationShortNameVar = 'eus'
var resourceGroupNameVar = empty(resourceGroupName) ? 'rg-${namePrefix}-${environmentName}-${locationShortNameVar}' : resourceGroupName

// Resources
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupNameVar
  location: location
  tags: tags
}

module azname 'core/aznames/aznames.bicep' = {
  name: 'aznames-module'
  scope: resourceGroup
  params: {
    resourceTypes: [ 'storage_account', 'key_vault', 'application_insights', 'log_analytics_workspace', 'search_service', 'form_recognizer_service', 'openai_service', 'virtual_network', 'managed_identity', 'network_security_group', 'container_registry', 'container_environment' ]
    namePrefix: namePrefix
    environment: environmentName
    location: location
  }
}

var storageAccountNameVar = empty(storageAccountName) ? first(filter(azname.outputs.resourceNames, item => item.resourceType == 'storage_account')).resourceName : storageAccountName
var keyVaultNameVar = empty(keyVaultName) ? first(filter(azname.outputs.resourceNames, item => item.resourceType == 'key_vault')).resourceName : keyVaultName
var logAnalyticsWorkspaceNameVar = empty(logAnalyticsWorkspaceName) ? first(filter(azname.outputs.resourceNames, item => item.resourceType == 'log_analytics_workspace')).resourceName : logAnalyticsWorkspaceName
var appinsightsNameVar = empty(appinsightsName) ? first(filter(azname.outputs.resourceNames, item => item.resourceType == 'application_insights')).resourceName : appinsightsName
var appinsightsDashboardNameVar = replace(appinsightsNameVar, 'appi', 'dash')
var containerAppEnvNameVar = empty(containerAppEnvName) ? first(filter(azname.outputs.resourceNames, item => item.resourceType == 'container_environment')).resourceName : containerAppEnvName
var containerRegistryNameVar = empty(containerRegistryName) ? first(filter(azname.outputs.resourceNames, item => item.resourceType == 'container_registry')).resourceName : containerRegistryName
var searchServiceNameVar = empty(searchServiceName) ? first(filter(azname.outputs.resourceNames, item => item.resourceType == 'search_service')).resourceName : searchServiceName
var formRecognizerServiceNameVar = empty(formRecognizerServiceName) ? first(filter(azname.outputs.resourceNames, item => item.resourceType == 'form_recognizer_service')).resourceName : formRecognizerServiceName
var openAiServiceNameVar = empty(openAiServiceName) ? first(filter(azname.outputs.resourceNames, item => item.resourceType == 'openai_service')).resourceName : openAiServiceName
var userIdentityNameVar = empty(userIdentityName) ? first(filter(azname.outputs.resourceNames, item => item.resourceType == 'managed_identity')).resourceName : userIdentityName
var vnetNameVar = empty(vnetName) ? first(filter(azname.outputs.resourceNames, item => item.resourceType == 'virtual_network')).resourceName : vnetName
var nsgNameVar = empty(nsgName) ? first(filter(azname.outputs.resourceNames, item => item.resourceType == 'network_security_group')).resourceName : nsgName


module userIdentity 'core/security/user-identity.bicep' = {
  name: 'userIdentity-module'
  scope: resourceGroup
  params:{
    name: userIdentityNameVar
    location:  location
  }
}
/*
module network 'core/network/network.bicep' = {
  name: 'network-module'
  scope: resourceGroup
  params: {
      location: location
      tags: tags 
      vnetName: vnetNameVar
      vnetAddressPrefix: vnetAddressPrefix
      firewallSubnetAddressPrefix: firewallSubnetAddressPrefix
      firewallManagementSubnetAddressPrefix: firewallManagementSubnetAddressPrefix
      containerSubnetAddressPrefix: containerSubnetAddressPrefix
      privateEndpointSubnetAddressPrefix: privateEndpointSubnetAddressPrefix
      containerNsgName: nsgNameVar
      containerNsgSecurityRules: [
        { 
          name: 'AllowInfrSubnetAddressSpaceIn'
          properties: {
            description: 'Allow communication between IPs in the infrastructure subnet'
            protocol: '*'
            sourcePortRange: '*'
            destinationPortRange: '*'
            sourceAddressPrefix: containerSubnetAddressPrefix
            destinationAddressPrefix: '*'
            access: 'Allow'
            priority: 100
            direction: 'Inbound'
            sourcePortRanges:[]
            destinationPortRanges:[]
            sourceAddressPrefixes: []
            destinationAddressPrefixes: []
          }
        }
        {
          name: 'AllowInternaAKSSecureConnectionUdp'
          properties: {
            description: 'Required for internal AKS secure connection between underlying nodes and control plane.'
            protocol: 'Udp'
            sourcePortRange: '*'
            destinationPortRange: '1194'
            sourceAddressPrefix: 'AzureCloud.eastus'
            destinationAddressPrefix: '*'
            access: 'Allow'
            priority: 200
            direction: 'Outbound'
            sourcePortRanges:[]
            destinationPortRanges:[]
            sourceAddressPrefixes: []
            destinationAddressPrefixes: []
          }
        }        
        {
          name: 'AllowInternaAKSSecureConnectionTcp'
          properties: {
            description: 'Required for internal AKS secure connection between underlying nodes and control plane.'
            protocol: 'Tcp'
            sourcePortRange: '*'
            destinationPortRange: '9000'
            sourceAddressPrefix: 'AzureCloud.eastus'
            destinationAddressPrefix: '*'
            access: 'Allow'
            priority: 210
            direction: 'Outbound'
            destinationPortRanges:[]
            sourceAddressPrefixes: []
            destinationAddressPrefixes: []
          }
        }   
        {
          name: 'AllowAzureMonitor'
          properties: {
            description: 'Allows outbound calls to Azure Monitor.'
            protocol: 'Tcp'
            sourcePortRange: '*'
            destinationPortRange: '443'
            sourceAddressPrefix: 'AzureMonitor'
            destinationAddressPrefix: '*'
            access: 'Allow'
            priority: 220
            direction: 'Outbound'
            destinationPortRanges:[]
            sourceAddressPrefixes: []
            destinationAddressPrefixes: []    
          }          
        }    
        {
          name: 'AllowContainerRegistry'
          properties: {
            description: 'Allows outbound calls to Azure Container Resgistry.'
            protocol: 'Tcp'
            sourcePortRange: '*'
            destinationPortRange: '443'
            sourceAddressPrefix: 'AzureContainerRegistry'
            destinationAddressPrefix: '*'
            access: 'Allow'
            priority: 230
            direction: 'Outbound'
            destinationPortRanges:[]
            sourceAddressPrefixes: []
            destinationAddressPrefixes: []     
          }       
        }  
        {
          name: 'AllowFrontdoor'
          properties: {
            description: 'This is a dependency of the MicrosoftContainerRegistry service tag.'
            protocol: 'Tcp'
            sourcePortRange: '*'
            destinationPortRange: '443'
            sourceAddressPrefix: 'AzureFrontDoor.FirstParty'
            destinationAddressPrefix: '*'
            access: 'Allow'
            priority: 240
            direction: 'Outbound'
            destinationPortRanges:[]
            sourceAddressPrefixes: []
            destinationAddressPrefixes: []   
          }       
        }   
        {
          name: 'AllowContainerAppControlPane'
          properties: {
            description: 'Container Apps control plane.'
            protocol: 'Tcp'
            sourcePortRange: '*'
            sourceAddressPrefix: '*'
            destinationAddressPrefix: '*'
            access: 'Allow'
            priority: 250
            direction: 'Outbound'
            destinationPortRanges:['5671','5672']
            sourceAddressPrefixes: []
            destinationAddressPrefixes: []      
          }        
        }         
        {
          name: 'AllowNTP'
          properties: {
            description: 'NTP Server'
            protocol: '*'
            sourcePortRange: '*'
            destinationPortRange: '123'
            sourceAddressPrefix: '*'
            destinationAddressPrefix: '*'
            access: 'Allow'
            priority: 260
            direction: 'Outbound'
            destinationPortRanges:[]
            sourceAddressPrefixes: []
            destinationAddressPrefixes: []  
          }          
        }  
        {
          name: 'AllowInfrSubnetAddressSpaceOut'
          properties: {
            description: 'Allow communication between IPs in the infrastructure subnet'
            protocol: '*'
            sourcePortRange: '*'
            destinationPortRange: '*'
            sourceAddressPrefix: containerSubnetAddressPrefix
            destinationAddressPrefix: '*'
            access: 'Allow'
            priority: 270
            direction: 'Outbound'
            destinationPortRanges:[]
            sourceAddressPrefixes: []
            destinationAddressPrefixes: []   
          }           
        }
        {
          name: 'AllowHttps'
          properties: {
            description: 'Allowing all outbound on port 443 provides a way to allow all FQDN based outbound dependencies that dont have a static IP.'
            protocol: 'Tcp'
            sourcePortRange: '*'
            destinationPortRange: '443'
            sourceAddressPrefix: containerSubnetAddressPrefix
            destinationAddressPrefix: '*'
            access: 'Allow'
            priority: 280
            direction: 'Outbound'
            destinationPortRanges:[]
            sourceAddressPrefixes: []
            destinationAddressPrefixes: [] 
          }             
        }
      ]
  }
}

module storage 'core/storage/storage-account.bicep' = {
  name: 'storage-module'
  scope: resourceGroup
  params: {
    name: storageAccountNameVar
    location: location
    tags: tags
    accessTier: storageAccessTier
    skuName: storageSkuName
    deleteRetentionPolicy: {
      enabled: true
      days: 2
    }
    containers: [
      {
        name: storageContainerName
        publicAccess: 'None'
      }
    ]
  }
}

module privateEndpointStorage 'core/network/private-endpoint.bicep' = {
  name: 'storage-pe-module'
  scope: resourceGroup
  params: {
    vnetId: network.outputs.vnet_id
    subnetId: network.outputs.private_endpoint_subnet_id
    location: location
    privateLinkGroupId: 'storage-blob'
    privateEndpointName:'pep-${storage.outputs.name}'
    privateLinkServiceId: storage.outputs.id
    privareEndpointDnsGroupName: 'dnsgroup'
  }

  dependsOn:[ 
    storage
  ]
}

module keyvault 'core/keyvault/keyvault.bicep' = {
  name: 'keyvault-module'
  scope: resourceGroup
  params: {
    name: keyVaultNameVar
    location: location
    tags: tags
    skuName: keyvaultSkuName
  }
}

module privateEndpointKeyvault 'core/network/private-endpoint.bicep' = {
  name: 'keyvault-pe-module'
  scope: resourceGroup
  params: {
    vnetId: network.outputs.vnet_id
    subnetId: network.outputs.private_endpoint_subnet_id
    location: location
    privateLinkGroupId: 'keyvault'
    privateEndpointName:'pep-${keyvault.outputs.name}'
    privateLinkServiceId: keyvault.outputs.id
    privareEndpointDnsGroupName: 'dnsgroup'
  }

  dependsOn:[ 
    keyvault
  ]
}

module monitoring 'core/monitor/monitoring.bicep' = {
  name: 'monitoring-module'
  scope: resourceGroup
  params: {
    location: location
    tags: tags
    includeDashboard: false
    logAnalyticsName: logAnalyticsWorkspaceNameVar
    applicationInsightsName: appinsightsNameVar
    applicationInsightsDashboardName:  appinsightsDashboardNameVar
  }
}

module search 'core/search/search-service.bicep' = {
  name: 'search-module'
  scope: resourceGroup
  params: {
    name: searchServiceNameVar
    location: location
    tags: tags
    skuName: searchServiceSkuName
  }
}

module privateEndpointSearch 'core/network/private-endpoint.bicep' = {
  name: 'search-pe-module'
  scope: resourceGroup
  params: {
    vnetId: network.outputs.vnet_id
    subnetId: network.outputs.private_endpoint_subnet_id
    location: location
    privateLinkGroupId: 'azure-search'
    privateEndpointName:'pep-${search.outputs.name}'
    privateLinkServiceId: search.outputs.id
    privareEndpointDnsGroupName: 'dnsgroup'
  }

  dependsOn:[ 
    search
  ]
}

module formRecognizer 'core/ai/cognitive-services.bicep' = {
  name: 'formrecognizer-module'
  scope: resourceGroup
  params: {
    name: formRecognizerServiceNameVar
    kind: 'FormRecognizer'
    location: location
    tags: tags
    skuName: formRecognizerSkuName
  }
}

module privateEndpointFormRecognizer 'core/network/private-endpoint.bicep' = {
  name: 'formRecognizer-pe-module'
  scope: resourceGroup
  params: {
    vnetId: network.outputs.vnet_id
    subnetId: network.outputs.private_endpoint_subnet_id
    location: location
    privateLinkGroupId: 'form-recognizer'
    privateEndpointName:'pep-${formRecognizer.outputs.name}'
    privateLinkServiceId: formRecognizer.outputs.id
    privareEndpointDnsGroupName: 'dnsgroup'
  }

  dependsOn:[ 
    formRecognizer
  ]
}


// module openAi 'core/ai/cognitive-services.bicep' = {
//   name: 'openai-module'
//   scope: resourceGroup
//   params: {
//     name: openAiServiceNameVar
//     location: location
//     tags: tags
//     skuName: openAiSkuName
//     kind: 'OpenAI'

//     deployments: [for deployment in gptModelDeployments: {
//       name: deployment.name
//       model: {
//         format: 'OpenAI'
//         name: deployment.modelName
//         version: deployment.version
//       }
//       sku: {
//         name: 'Standard'
//         capacity: deployment.capacity
//       }
//     }]
//   }
// }

module containerAppsEnvironment 'core/host/container-apps-environment.bicep' = {
  name: 'container-apps-environment-module'
  scope: resourceGroup
  params: {
    name: containerAppEnvNameVar
    location: location
    tags: tags
    logAnalyticsWorkspaceName: monitoring.outputs.logAnalyticsWorkspaceName
    applicationInsightsName: monitoring.outputs.applicationInsightsName
    subnetId: network.outputs.container_subnet_id
  }

  dependsOn: [ 
    network
  ]
}
*/

module containerRegistry 'core/host/container-registry.bicep' = {
  name: 'container-registry-module'
  scope: resourceGroup
  params: {
    name: containerRegistryNameVar
    location: location
    tags: tags
  }
  dependsOn: [ 
    // network
  ]
}
/*
module privateEndpointContainerRegistry 'core/network/private-endpoint.bicep' = {
  name: 'containerRegistry-pe-module'
  scope: resourceGroup
  params: {
    vnetId: network.outputs.vnet_id
    subnetId: network.outputs.private_endpoint_subnet_id
    location: location
    privateLinkGroupId: 'container-registry'
    privateEndpointName:'pep-${containerRegistry.outputs.name}'
    privateLinkServiceId: containerRegistry.outputs.id
    privareEndpointDnsGroupName: 'dnsgroup'
  }

  dependsOn:[ 
    containerRegistry
  ]
}
*/
module backendImage 'core/host/container-image.bicep' = {
  name: 'backend-image-module'
  scope: resourceGroup
  params: {
    location: location
    userIdentityName: userIdentityNameVar
    tags: tags
    containerRegistryName: containerRegistry.outputs.name
    dockerfilePath: './app/backend/Dockerfile'
    imageName: backendImageName
    imageVersion: backendImageVersion
    githubRepoUrl: gitRepoUrl
    githubToken: gitToken
    githubBranch: 'main'
  }
  dependsOn:[
    userIdentity
    containerRegistry
  ]
}

/*
module frontendImage 'core/host/container-image.bicep' = {
  name: 'frotend-image-module'
  scope: resourceGroup
  params: {
    location: location
    userIdentityName: userIdentityNameVar
    tags: tags
    containerRegistryName: containerRegistry.outputs.name
    contextPath: ''
    dockerfilePath: './app/frontend/Dockerfile'
    imageName: frotendImageName
  }
  dependsOn:[
    userIdentity
    containerRegistry
  ]
}

module backend 'core/host/container-app.bicep' = {
  name: 'container-app-backend'
  scope: resourceGroup
  params:{
    name: 'backend'
    location: location
    tags: union(tags, { 'azd-service-name': 'backend' })
    userIdentityName: userIdentityNameVar
    ingressEnabled: true
    containerName: 'backend'
    containerAppsEnvironmentName: containerApps.outputs.environmentName
    containerRegistryName: containerRegistryNameVar
    containerCpuCoreCount: containerCpuCoreCount
    containerMemory: containerMemory
    containerMinReplicas: containerMinReplicas
    containerMaxReplicas: containerMaxReplicas
    daprEnabled: daprEnabled
    daprAppId: daprAppId
    daprAppProtocol: daprAppProtocol
    secrets: secrets
    external: external
    imageName: '${backendImageName}:1.0.0'
    targetPort: 8081
    serviceBinds: []
    env:[
      {
        name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
        value: monitoring.outputs.applicationInsightsConnectionString
      }
      {
         name: 'AZURE_KEYVAULT_ENDPOINT'
        value: keyvault.outputs.endpoint
      }
      {
        name: 'STORAGE_ACCOUNT_NAME'
        value: storage.outputs.name
      }
      {
        name: 'STORAGE_KEY'
        value: '@Microsoft.KeyVault(VaultName=${keyvault.outputs.name};SecretName=AzureStorageKey)'
      }
      {
        name: 'STORAGE_CONTAINER'
        value: storageContainerName
      }
      {
        name: 'KB_FIELDS_CONTENT'
        value: kbFieldContent
      }
      {
        name: 'KB_FIELDS_ID'
        value: kbFieldSourcePage
      }
      {
        name: 'AZURE_SEARCH_SERVICE'
        value: search.outputs.name
      }
      {
        name: 'AZURE_SEARCH_KEY'
        value: '@Microsoft.KeyVault(VaultName=${keyvault.outputs.name};SecretName=AzureSearchKey)'
      }
      {
        name: 'AZURE_SEARCH_INDEX'
        value: searchIndexName
      }
      // {
      //   name: 'AZURE_OPENAI_SERVICE'
      //   value: openAi.outputs.name
      // }
      {
        name: 'AZURE_OPENAI_KEY'
        value: '@Microsoft.KeyVault(VaultName=${keyvault.outputs.name};SecretName=AzureOpenAiKey)'
      }
      {
        name: 'AZURE_OPENAI_CHAT_DEPLOYMENT'
        value: gptDeploymentName
      }
      {
        name: 'AZURE_OPENAI_EMBEDDING_DEPLOYMENT'
        value: gptEmbeddingDeploymentName
      }     
    ]
  }

  dependsOn:[
    containerApps
  ]
}

module frontend 'core/host/container-app.bicep' = {
  name: 'container-app-frontend'
  scope: resourceGroup
  params:{
    name: 'frontend'
    location: location
    tags: union(tags, { 'azd-service-name': 'frontend' })
    userIdentityName: userIdentityNameVar
    ingressEnabled: false
    containerName: 'frontend'
    containerAppsEnvironmentName: containerApps.outputs.environmentName
    containerRegistryName: containerRegistryNameVar
    containerCpuCoreCount: containerCpuCoreCount
    containerMemory: containerMemory
    containerMinReplicas: containerMinReplicas
    containerMaxReplicas: containerMaxReplicas
    daprEnabled: false
    external: true
    imageName: frontendImageName
    targetPort: 8081
    env:[
      {
        name: 'BACKEND_URI'
        value: ''
      } 
    ]
  }

  dependsOn:[
    containerApps
    userIdentity
  ]
}

// Security

module keyVaultSecret 'core/keyvault/keyvault-secrets.bicep' = {
  name: 'keyvault-secret-module'
  scope: resourceGroup
  params: {
    keyvaultName: keyvault.outputs.name
    tags: tags
    secrets: [
      {
        name: 'AzureStorageKey'
        value: storage.outputs.key
        contentType: 'Storage account key'
      }
      {
        name: 'AzureSearchServiceKey'
        value: search.outputs.key
        contentType: 'Search service admin key'
      }
      // {
      //   name: 'AzureOpenAiServiceKey'
      //   value: openAi.outputs.key
      //   contentType: 'Azure OpenAI Service key'
      // }
      {
        name: 'AzureFormRecognizerServiceKey'
        value: formRecognizer.outputs.key
        contentType: 'Azure Form Recognozer Service key'
      }
    ]
  }

  dependsOn: [
    keyvault
    // search
    // openAi
    storage
    // formRecognizer
  ]
}

// Storage Blob Data Reader
module storageRoleUser 'core/security/role-assignment.bicep' = {
  scope: resourceGroup
  name: 'storage-role-user'
  params: {
    principalId: servicePrincipalObjectId
    roleDefinitionId: '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1'
    principalType: 'User'
  }
}

// Storage Blob Data Contributor
module storageContribRoleUser 'core/security/role-assignment.bicep' = {
  scope: resourceGroup
  name: 'storage-contribrole-user'
  params: {
    principalId: servicePrincipalObjectId
    roleDefinitionId: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
    principalType: 'User'
  }
}

// Search Index Data Reader
module searchRoleUser 'core/security/role-assignment.bicep' = {
  scope: resourceGroup
  name: 'search-role-user'
  params: {
    principalId: servicePrincipalObjectId
    roleDefinitionId: '1407120a-92aa-4202-b7e9-c0e197c71c8f'
    principalType: 'User'
  }
}

// Search Index Data Contributor
module searchContribRoleUser 'core/security/role-assignment.bicep' = {
  scope: resourceGroup
  name: 'search-contrib-role-user'
  params: {
    principalId: servicePrincipalObjectId
    roleDefinitionId: '8ebe5a00-799e-43f5-93ac-243d3dce84a7'
    principalType: 'User'
  }
}

// Search Service Contributor
module searchSvcContribRoleUser 'core/security/role-assignment.bicep' = {
  scope: resourceGroup
  name: 'search-svccontrib-role-user'
  params: {
    principalId: servicePrincipalObjectId
    roleDefinitionId: '7ca78c08-252a-4471-8644-bb5ff32d4ba0'
    principalType: 'User'
  }
}

// Cognitive Services OpenAI User
module openAiRoleUser 'core/security/role-assignment.bicep' = {
  scope: resourceGroup
  name: 'openai-role-user'
  params: {
    principalId: servicePrincipalObjectId
    roleDefinitionId: '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd'
    principalType: 'User'
  }
}

// Cognitive Services User
module formRecognizerRoleUser 'core/security/role-assignment.bicep' = {
  scope: resourceGroup
  name: 'formrecognizer-role-user'
  params: {
    principalId: servicePrincipalObjectId
    roleDefinitionId: 'a97b65f3-24c7-4388-baec-2e87135dc908'
    principalType: 'User'
  }
}

// Keyvault Reader to User
module keyvaultRoleUser 'core/security/role-assignment.bicep' = {
  scope: resourceGroup
  name: 'keyvault-role-user'
  params: {
    principalId: servicePrincipalObjectId
    roleDefinitionId: '21090545-7ca7-4776-b22c-e363652d74d2'
    principalType: 'User'
  }
}

// // Cognitive Services OpenAI User to backend managed identity
// module openAiRoleBackend 'core/security/role-assignment.bicep' = {
//   scope: resourceGroup
//   name: 'openai-role-backend'
//   params: {
//     principalId: backend.outputs.identityPrincipalId
//     roleDefinitionId: '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd'
//     principalType: 'ServicePrincipal'
//   }
//   dependsOn: [
//     backend
//   ]
// }

// // Storage Blob Data Reader to backend managed identity
// module storageRoleBackend 'core/security/role-assignment.bicep' = {
//   scope: resourceGroup
//   name: 'storage-role-backend'
//   params: {
//     principalId: backend.outputs.identityPrincipalId
//     roleDefinitionId: '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1'
//     principalType: 'ServicePrincipal'
//   }
//   dependsOn: [
//     backend
//   ]
// }

// // Search Index Data Reader to backend managed identity
// module searchRoleBackend 'core/security/role-assignment.bicep' = {
//   scope: resourceGroup
//   name: 'search-role-backend'
//   params: {
//     principalId: backend.outputs.identityPrincipalId
//     roleDefinitionId: '1407120a-92aa-4202-b7e9-c0e197c71c8f'
//     principalType: 'ServicePrincipal'
//   }
//   dependsOn: [
//     backend
//   ]
// }

// // Keyvault Reader to to backend managed identity
// module keyvaultRoleBackend 'core/security/role-assignment.bicep' = {
//   scope: resourceGroup
//   name: 'keyvault-role-backend'
//   params: {
//     principalId: backend.outputs.identityPrincipalId
//     roleDefinitionId: '21090545-7ca7-4776-b22c-e363652d74d2'
//     principalType: 'ServicePrincipal'
//   }
//   dependsOn: [
//     backend
//   ]
// }

// Outputs
output AZURE_LOCATION string = location
output AZURE_TENANT_ID string = subscription().tenantId
output AZURE_SUBSCRIPTION_ID string = subscription().subscriptionId
output AZURE_SERVICEPRINCIPAL_OBJECTID string = servicePrincipalObjectId
output AZURE_RESOURCE_GROUP string = resourceGroup.name
output AZURE_STORAGE_ACCOUNT string = storageAccountNameVar
output AZURE_STORAGE_CONTAINER string = storageContainerName
output AZURE_KEY_VAULT string = keyVaultNameVar
output AZURE_LOG_ANALYTICS_WORKSPACE string = logAnalyticsWorkspaceNameVar
output AZURE_APPINSIGHTS string = appinsightsNameVar
output AZURE_SEARCH_SERVICE string = searchServiceNameVar
output AZURE_FORM_RECOGNIZER_SERVICE string = formRecognizerServiceNameVar
output AZURE_OPENAI_SERVICE string = openAiServiceNameVar
output AZURE_OPENAI_GPT_DEPLOYMENT string = gptDeploymentName
output AZURE_OPENAI_GPT_EMBEDDING_DEPLOYMENT string = gptEmbeddingDeploymentName
output AZURE_SEARCH_INDEX string = searchIndexName
output FRONTEND_URI string = ''
output BACKEND_URI string = ''
output AZD_RESOURCES_CREATED string = 'true'
*/
