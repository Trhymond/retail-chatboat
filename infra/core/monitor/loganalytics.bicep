@minLength(4)
@maxLength(63)
param name string
param location string = resourceGroup().location
param tags object

var skuName = 'PerGB2018'

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: name
  location: location
  tags: tags

  properties: {
    sku: {
      name: skuName
    }
    retentionInDays: 90
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }

  identity: {
    type: 'SystemAssigned'
  }
}


output id string = logAnalytics.id 
output name string =  logAnalytics.name 
