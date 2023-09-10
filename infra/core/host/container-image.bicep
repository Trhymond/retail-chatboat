
param location string = resourceGroup().location
param tags object = {}
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
  name: 'build-${imageName}-${replace(imageVersion, '.', '-')}'
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
      architecture: 'amd64'
    }
    agentConfiguration: {
      cpu: 2
    }
    step:{
      type: 'Docker'
      contextPath: '${githubRepoUrl}#${githubBranch}'
      dockerFilePath: dockerfilePath
      imageNames:[ '${containerRegistry.properties.loginServer}/${imageName}:${imageVersion}']
      isPushEnabled: true 
      noCache: false 
      arguments: []
    }
    timeout: 3600
    trigger:{
      baseImageTrigger: { 
        baseImageTriggerType: 'Runtime'
        name: 'defaultBaseimageTriggerName'
      }
       sourceTriggers: [
        {
          name: 'defaultSourceTriggerName'
          sourceRepository: {
            repositoryUrl: '${githubRepoUrl}#${githubBranch}'
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

