
param location string = resourceGroup().location
param tags object = {}
param contextPath string
param dockerfilePath string
param containerRegistryName string
param userIdentityName string
param imageName string
param imageVersion string = '1.0.0'
param githubRepoUrl string
param githubToken string
param githubBranch string

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
      contextPath: contextPath 
      dockerFilePath: dockerfilePath
      imageNames:[ '${containerRegistry.properties.loginServer}/${imageName}:${imageVersion}']
      isPushEnabled: true 
      noCache: true 
    }
    trigger:{
       sourceTriggers: [
        {
          name: 'trigger1'
          sourceRepository: {
            repositoryUrl: githubRepoUrl
            sourceControlType: 'Github'
            branch: githubBranch
            sourceControlAuthProperties: {
              tokenType: 'PAT'
              token: githubToken
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

