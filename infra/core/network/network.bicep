
param location string = resourceGroup().location
param tags object 
param vnetName string 
param vnetAddressPrefix  string 
param containerNsgName string
param containerNsgSecurityRules array = [] 
param firewallSubnetAddressPrefix string
param firewallManagementSubnetAddressPrefix string
param containerSubnetAddressPrefix string 
param privateEndpointSubnetAddressPrefix string

var serviceEndpoints = [
  'Microsoft.CognitiveServices'
  'Microsoft.ContainerRegistry'
  'Microsoft.KeyVault'
  'Microsoft.Sql'
  'Microsoft.Storage'
]

resource containerNsg 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
  name: containerNsgName
  location: location
  tags: tags 
  properties: { 
    securityRules: containerNsgSecurityRules
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets:[
      {
        name: 'AzureFirewallSubnet'
        properties: { 
          addressPrefix: firewallSubnetAddressPrefix
        }
      }
      {
        name: 'AzureFirewallManagementSubnet'
        properties: { 
          addressPrefix: firewallManagementSubnetAddressPrefix
        }
      }
      {
        name: 'ContainerSubnet'
        properties: { 
          addressPrefix: containerSubnetAddressPrefix
          serviceEndpoints:[for endpoint in serviceEndpoints: {
            service: endpoint
            locations:[ location]
          }]
          delegations:[
            {
               name:'Microsoft.App/environments'
               properties:{
                 serviceName: 'Microsoft.App/environments'
               }
            }
          ]
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
          networkSecurityGroup: {
            id: containerNsg.id
          }
        }
      }
      {
        name: 'PrivateEndpointSubnet'
        properties: { 
          addressPrefix: privateEndpointSubnetAddressPrefix
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
  }
}


// resource azureFiewallSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-04-01' = {
//   parent: virtualNetwork
//   name: 'AzureFirewallSubnet'
//   properties: { 
//     addressPrefix: firewallSubnetAddressPrefix
//   }
// }

// resource azureFiewallMgmtSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-04-01' = {
//   parent: virtualNetwork
//   name: 'AzureFirewallManagementSubnet'
//   properties: { 
//     addressPrefix: firewallManagementSubnetAddressPrefix
//   }

//   dependsOn:[ azureFiewallSubnet]
// }

// resource containerSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-04-01' = {
//   parent: virtualNetwork
//   name: 'ContainerSubnet'
//   properties: { 
//     addressPrefix: containerSubnetAddressPrefix
//     serviceEndpoints:[for endpoint in serviceEndpoints: {
//       service: endpoint
//       locations:[ location]
//     }]
//     privateEndpointNetworkPolicies: 'Disabled'
//     privateLinkServiceNetworkPolicies: 'Enabled'
//   }

//   dependsOn:[ azureFiewallMgmtSubnet]
// }

// resource privateEndpointSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-04-01' = {
//   parent: virtualNetwork
//   name: 'PrivateEndpointSubnet'
//   properties: { 
//     addressPrefix: privateEndpointSubnetAddressPrefix
//     privateEndpointNetworkPolicies: 'Enabled'
//     privateLinkServiceNetworkPolicies: 'Enabled'
//   }

//   dependsOn:[ containerSubnet]
// }

resource containerSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-04-01' existing = {
  parent:virtualNetwork
  name: 'ContainerSubnet'
}

resource privateEndpointSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-04-01' existing = {
  parent:virtualNetwork
  name: 'PrivateEndpointSubnet'
}

output vnet_id string =  virtualNetwork.id
output vnet_name string =  virtualNetwork.name
output container_subnet_id string =  containerSubnet.id
output private_endpoint_subnet_id string =  privateEndpointSubnet.id
