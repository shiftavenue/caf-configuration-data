param location string
param saName string
param containerName string

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: saName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2022-09-01' = {
  name: 'default'
  parent: storageAccount
}

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-02-01' = {
  name: containerName
  parent: blobService
}