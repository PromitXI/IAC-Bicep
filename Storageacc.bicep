@description('The Name of the Envoirnment of Resource')
@allowed( [
  'Dev'
  'QA'
  'Prod'
])
param envoirnment string

@description('Location for all resources.')
param location string 

var storageaccoutname=toLower('PWB${envoirnment}stracc00')




resource StorageAccounts 'Microsoft.Storage/storageAccounts@2022-09-01'=[for item in range(1,3): {
  name:'${storageaccoutname}${item}'
  location:location
  
  kind:'StorageV2'
  sku: {
    name: 'Premium_LRS'
  }
  properties:{
    allowBlobPublicAccess:false

  }
  
}]


