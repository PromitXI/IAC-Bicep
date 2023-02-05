@description('The Name of the Envoirnment of Resource')
@allowed( [
  'Dev'
  'Test'
  'Prod'
])
param envoirnment string

@description('The Location of The Resource Group and All Other Resources')
param location string='westeurope'

@description('The name of the Subnet')
param subnetID string

@description('The Subnet ID of Mgmt Subnet')
param subnet2ID string

@description('The Object ID of Vnet')
param VnetId string


var synapsename=toLower('PWBSynapseData${envoirnment}')
var datalakename =toLower(take('pwb${envoirnment}data${uniqueString(resourceGroup().id)}',12))
var blobname =toLower('filesys${envoirnment}')
var PE1_Name=toLower('${azsynapse.name}-privateEndpoint1')

var PrivateEndpointName='PE-PWB-Synapse-${envoirnment}'
var privateDnsZoneName='privatelink-syn-${envoirnment}'
var pvtEndpointDnsGroupName='${PrivateEndpointName}/SQLDNSGrp${envoirnment}'
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
    publicNetworkAccess:'Enabled'
  }
}

resource privateDnsZone1 'Microsoft.Network/privateDnsZones@2018-09-01' = {

  name: privateDnsZoneName
  location: location
  properties: {
    registrationEnabled: true
  }
}

resource privateEndpoint1 'Microsoft.Network/privateEndpoints@2022-07-01' ={
  
  name:PE1_Name
  location:location
   properties: {
    subnet: {
      id: subnetID
    }
    privateLinkServiceConnections: [
      {
        name: PrivateEndpointName
        properties: {
          privateLinkServiceId: azsynapse.id
          groupIds: [
            'azsynapse'
          ]
        }
      }
    ]
  }
  
}


