
param location string = resourceGroup().location
param tags object = {}
param dockerfilePath string
param containerRegistryName string
param userIdentityName string
param imageName string
param imageVersion string
param githubRepoUrl string
param githubToken string
param githubBranch string
// param forceUpdateTag string = utcNow()

// var buildName = 'build-${imageName}-${replace(imageVersion, '.', '-')}'
// var acrRunCommand = 'az acr task run --registry ${containerRegistryName} --name ${buildName}'

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
      noCache: true 
      arguments: []
    }
    timeout: 3600
    trigger:{
      // baseImageTrigger: { 
      //   baseImageTriggerType: 'Runtime'
      //   name: 'defaultBaseimageTriggerName'
      // }
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

// resource runAcrTask 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
//   name: 'runAcrTask'
//    kind: 'AzureCLI'
//     location: location 
//     tags: tags 
//     identity: {
//       type: 'UserAssigned'
//       userAssignedIdentities:  { '${userIdentity.id}': {} }
//     }
//     properties:{
//       azCliVersion: 'latest'
//       forceUpdateTag: forceUpdateTag
//       retentionInterval: 'P1D'
//       scriptContent: acrRunCommand
//       timeout: 'PT15M'
//     }
//     dependsOn: [acrTask]
// }
