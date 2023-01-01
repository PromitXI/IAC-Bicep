@description('The Name of the Envoirnment of Resource')
@allowed( [
  'Dev'
  'Test'
  'Prod'
])
param envoirnment string

@description('The Location of The Resource Group and All Other Resources')
param location string='westeurope'


var synapsename=toLower('PWBSynapseData${envoirnment}')
var datalakename =toLower(take('pwb${envoirnment}data${uniqueString(resourceGroup().id)}',12))
var blobname =toLower('filesys${envoirnment}')

resource datalakestore 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: datalakename
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Premium_LRS'
    
  }
  properties:{
    
    
    allowBlobPublicAccess:false

  }
}
resource blobservice 'Microsoft.Storage/storageAccounts/blobServices@2022-09-01'={
  parent:datalakestore
  name:'default'

}
resource filesystem 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-09-01'={
  parent:blobservice
  name:blobname
}



resource azsynapse 'Microsoft.Synapse/workspaces@2021-06-01'={
  dependsOn:[
    datalakestore
  ]
  location:location
  name:synapsename
  identity:{
    type:'SystemAssigned'
  }
  properties:{
    defaultDataLakeStorage:{
      resourceId:datalakestore.id
      accountUrl:'https://${datalakename}.dfs.core.windows.net'
      filesystem:blobname
    }
    managedVirtualNetwork:'default'
    publicNetworkAccess:'Disabled'
  }
}


