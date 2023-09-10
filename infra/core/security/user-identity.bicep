
param name string 
param location string = resourceGroup().location

resource userIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: name
  location: location
}

output id string = userIdentity.id
output name string = userIdentity.name
