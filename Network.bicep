@description('The Name of the Virtual Network')
param VirtualNetworkName string

@description('The IP Range for the Vnet')
param IpRangePrefix string

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Name of the Subnet')
param Subnet1Name string

@description('Address Range of Subnet 1')
param Subnet1AddressRange string

@description('Name of the Subnet')
param Subnet2Name string

@description('Address Range of Subnet 1')
param Subnet2AddressRange string

@description('The Name of the NSGs')
param nsg1Name string
param nsg2Name string

// resource VnetEXT 'Microsoft.Network/virtualNetworks@2020-06-05-preview' existing={
//   name:'PWB-DEV-WUS3-Vnet'
// }
//  output vnetID string=VnetEXT.id


resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: VirtualNetworkName
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
  name: Subnet1Name
  properties:{
    addressPrefix:Subnet1AddressRange
    networkSecurityGroup:{
      id:NetworkSecurityGroup1.id
    }
  }

}
resource subnet2 'Microsoft.Network/virtualNetworks/subnets@2022-07-01'={
  parent:virtualNetwork
  name: Subnet2Name
  properties:{
    addressPrefix:Subnet2AddressRange
    networkSecurityGroup:{
      id:NetworkSecurityGroup2.id
    }
  }

}

resource NetworkSecurityGroup1 'Microsoft.Network/networkSecurityGroups@2019-11-01' = {

  name: nsg1Name
  location: location
  properties: {
    
  }
}

resource NetworkSecurityGroup2 'Microsoft.Network/networkSecurityGroups@2019-11-01' = {
  
  name: nsg2Name
  location: location
  properties: {
    
  }
}

output vnetid string=virtualNetwork.id
output sqlsubnetid string=subnet1.id
output mgmtsubnetid string=subnet2.id

