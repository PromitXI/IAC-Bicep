@description('The IP Range for the Vnet')
param IpRangePrefix string

@description('The Name of the Envoirnment of Resource')
@allowed( [
  'Dev'
  'Test'
  'Prod'
])
param envoirnment string

@description('Location for all resources.')
param location string 

@description('Address Range of Subnet 1')
param Subnet1AddressRange string

@description('Address Range of Subnet 1')
param Subnet2AddressRange string

@description('The Name of the NSGs')
param nsg1Name string
param nsg2Name string

// resource VnetEXT 'Microsoft.Network/virtualNetworks@2020-06-05-preview' existing={
//   name:'PWB-DEV-WUS3-Vnet'
// }
//  output vnetID string=VnetEXT.id
var VnetName='Vnet-PWB-${location}-${envoirnment}-Data'
var SubnetName1='Snet-PWB-${location}-${envoirnment}-SQL'
var SubnetName2='Snet-PWB-${location}-${envoirnment}-Mgmt'
var Nsg1='NSG-${envoirnment}-SQL-${location}'
var Nsg2='NSG-${envoirnment}-Mgmt-${location}'

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: VnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        IpRangePrefix
      ]
    }
    
  }
}

resource subnet1 'Microsoft.Network/virtualNetworks/subnets@2022-07-01'={
  parent:virtualNetwork
  name: SubnetName1
  properties:{
    addressPrefix:Subnet1AddressRange
    networkSecurityGroup:{
      id:NetworkSecurityGroup1.id
    }
  }

}
resource subnet2 'Microsoft.Network/virtualNetworks/subnets@2022-07-01'={
  parent:virtualNetwork
  name: SubnetName2
  properties:{
    addressPrefix:Subnet2AddressRange
    networkSecurityGroup:{
      id:NetworkSecurityGroup2.id
    }
  }

}

resource NetworkSecurityGroup1 'Microsoft.Network/networkSecurityGroups@2019-11-01' = {

  name: Nsg1
  location: location
  properties: {
    
  }
}

resource NetworkSecurityGroup2 'Microsoft.Network/networkSecurityGroups@2019-11-01' = {
  
  name: Nsg2
  location: location
  properties: {
    
  }
}

output vnetid string=virtualNetwork.id
output sqlsubnetid string=subnet1.id
output mgmtsubnetid string=subnet2.id

