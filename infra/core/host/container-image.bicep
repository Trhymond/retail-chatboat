
param location string = resourceGroup().location
param tags object = {}
param contextPath string
param dockerfilePath string
param containerRegistryName string
param userIdentityName string
param imageName string
param imageRepositoryUrl string

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2022-02-01-preview' existing = {
  name: containerRegistryName
}

resource userIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: userIdentityName
}

resource acrTask 'Microsoft.ContainerRegistry/registries/tasks@2019-06-01-preview' = {
  name: 'dockerBuild'
  parent: containerRegistry
  location: location
  tags: tags
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities:  { '${userIdentity.id}': {} }
  }
  properties: {
    platform: {
      os: 'Linux'
    }
    step:{
      type: 'Docker'
      dockerFilePath: dockerfilePath
      imageNames:[ imageName]
      isPushEnabled: true 
      noCache: true 
      contextPath: contextPath 
      arguments: []
      contextAccessToken: ''
    }
    trigger:{
       sourceTriggers: [
        {
          name: 'trigger1'
          sourceRepository: {
            repositoryUrl: imageRepositoryUrl
            sourceControlType: 'Github'
            branch: 'main'
            sourceControlAuthProperties: {
              tokenType: 'PAT'
              token: ''
            }
          }
          sourceTriggerEvents:  [
             'commit'
          ]
        }
       ]
    }
  }
}

