targetScope = 'subscription'

param rgName string = 'tf_backend_util'
param location string = 'westeurope'
param saName string = 'tfbackend${split(subscription().id, '-')[4]}'
param containerName string = 'tf-state'

resource rg 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: rgName
  location: location
}

module storageAcct 'storage.bicep' = {
  name: 'storageModule'
  scope: rg
  params: {
    location: location
    saName: saName
    containerName: containerName
  }
}

output rgName string = rgName
output saName string = saName
output containerName string = containerName

