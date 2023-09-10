@minLength(3)
@maxLength(60)
param name string
param location string = resourceGroup().location
param tags object
@allowed([ 'basic', 'free', 'standard', 'standard2', 'standard3', 'storage_optimized_l1', 'storage_optimized_l2' ])
param skuName string = 'standard'

@allowed([
  'default'
  'highDensity'
])
param hostingMode string = 'default'
@allowed([
  'new'
  'existing'
])
param newOrExisting string = 'new'

resource search 'Microsoft.Search/searchServices@2022-09-01' = if (newOrExisting == 'new') {
  name: name
  location: location
  tags: tags
  sku: {
    name: skuName
  }
  properties: {
    authOptions: {
      aadOrApiKey: {
        aadAuthFailureMode: 'http401WithBearerChallenge'
      }
    }
    disableLocalAuth: false
    hostingMode: hostingMode
    partitionCount: 1
    publicNetworkAccess: 'enabled'
    replicaCount: 1
  }

  identity: {
    type: 'SystemAssigned'
  }
}

resource searchExisting 'Microsoft.Search/searchServices@2022-09-01' existing = if (newOrExisting == 'existing') {
  name: name
}

output id string = ((newOrExisting == 'new') ? search.id : searchExisting.id)
output endpoint string = 'https://${name}.search.windows.net/'
output name string = ((newOrExisting == 'new') ? search.name : searchExisting.name)
output key string = ((newOrExisting == 'new') ? search.listAdminKeys().secondaryKey : searchExisting.listAdminKeys().secondaryKey)
