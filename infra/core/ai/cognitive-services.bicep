
@minLength(3)
@maxLength(64)
param name string
param location string = resourceGroup().location
param tags object
@allowed([ 'CognitiveServices', 'ComputerVision', 'CustomVision.Prediction', 'CustomVision.Training', 'Face', 'FormRecognizer', 'SpeechServices', 'LUIS', 'QnAMaker', 'TextAnalytics', 'TextTranslation', 'AnomalyDetector', 'ContentModerator', 'Personalizer', 'OpenAI' ])
param kind string = 'CognitiveServices'
param skuName string
param customSubDomainName string = name
param publicNetworkAccess string = 'enabled'
param deployments array = []
@allowed([
  'new'
  'existing'
])
param newOrExisting string = 'new'

resource account 'Microsoft.CognitiveServices/accounts@2023-05-01' = if (newOrExisting == 'new') {
  name: name
  location: location
  tags: tags
  kind: kind
  properties: {
    customSubDomainName: customSubDomainName
    publicNetworkAccess: publicNetworkAccess
  }
  sku: {
    name: skuName
  }

  identity: {
    type: 'SystemAssigned'
  }
}

resource accountExisting 'Microsoft.CognitiveServices/accounts@2023-05-01' existing = if (newOrExisting == 'existing') {
  name: name
}

@batchSize(1)
resource deployment 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = [for deployment in deployments: {
  parent: account
  name: deployment.name
  properties: {
    model: deployment.model
    raiPolicyName: contains(deployment, 'raiPolicyName') ? deployment.raiPolicyName : null
  }
  sku: contains(deployment, 'sku') ? deployment.sku : {
    name: 'Standard'
    capacity: 20
  }
}]

output id string = ((newOrExisting == 'new') ? account.id : accountExisting.id)
output name string = ((newOrExisting == 'new') ? account.name : accountExisting.name)
output endpoint string = ((newOrExisting == 'new') ? account.properties.endpoint : accountExisting.properties.endpoint)
output key string = ((newOrExisting == 'new') ? account.listKeys().key1 : accountExisting.listKeys().key1)
