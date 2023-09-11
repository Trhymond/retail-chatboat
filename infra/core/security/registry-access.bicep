param containerRegistryName string
param principalId string
param roles array = ['pull']

var acrPullRole = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')
var acrPushRole = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '8311e382-0749-4cb8-b61a-304f252e45ec')

resource aksAcrPull 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for role in roles: {
  scope: containerRegistry // Use when specifying a scope that is different than the deployment scope
  name: guid(subscription().id, resourceGroup().id, principalId, role)
  properties: {
    roleDefinitionId: role == 'push' ? acrPushRole : acrPullRole
    principalType: 'ServicePrincipal'
    principalId: principalId
  }
}]

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2022-02-01-preview' existing = {
  name: containerRegistryName
}
