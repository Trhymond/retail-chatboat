
// https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview
// https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns

param location string = resourceGroup().location
param privateEndpointName string 
param vnetId string 
param subnetId string 
param privateLinkServiceId string
param privateLinkGroupId string
param privareEndpointDnsGroupName string

var privateDnsZoneNames = [
  {
    key: 'storage-blob'
    type: 'blob'
    value: 'privatelink.blob.core.windows.net'
  }
  {
    key: 'container-registry'
    type: 'registry'
    value: 'privatelink.azurecr.io'
  }
  {
    key: 'keyvault'
    type: 'vault'
    value: 'privatelink.vaultcore.azure.net'
  }
  {
    key: 'azure-search'
    type: 'searchService'
    value: 'privatelink.search.windows.net'
  }
  {
    key: 'form-recognizer'
    type: 'account'
    value: 'privatelink.cognitiveservices.azure.com'
  }
  {
    key: 'openai'
    type: 'account'
    value: 'privatelink.openai.azure.com'
  }
]

var privateDnsZoneName = filter(privateDnsZoneNames, p => privateLinkGroupId == p.key)[0]

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: privateLinkServiceId
          groupIds: [
            privateDnsZoneName.type
          ]
        }
      }
    ]
  }
}

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDnsZoneName.value
  location: 'global'
}

resource privateEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-01-01' = {
  name: '${privateEndpointName}/${privareEndpointDnsGroupName}'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: privateDnsZone.id
        }
      }
    ]
  }
  dependsOn:[
    privateEndpoint
  ]
}

resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZone
  //name: '${privateDnsZoneName.value}/${privateDnsZoneName.value}-link'
  name: '${privateDnsZoneName.value}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
  dependsOn:[
    privateEndpoint
  ]
}

