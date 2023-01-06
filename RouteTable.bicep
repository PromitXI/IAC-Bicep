

@description('Location for all resources.')
param location string 

@description('The Name of the Envoirnment of Resource')
@allowed( [
  'Dev'
  'Test'
  'Prod'
])
param envoirnment string

@description('Route Table Name')
param Routename string ='To-Hub-FW'

@description('IP Adress of Next HopFirewall,Appliance, Router')
param nextHopIP string 

var RouteTableName='RT-PWB-Data-${envoirnment}'

resource symbolicname 'Microsoft.Network/routeTables@2022-05-01' = {
  name: RouteTableName
  location: location
  tags: {
    Envoirnment: envoirnment
    admin: 'Promit Bhattacherjee'
  }
  properties: {
    disableBgpRoutePropagation: false
    routes: [
      {
        id: '123456'
        name: Routename
        properties: {
          addressPrefix: '0.0.0.0/0'
          hasBgpOverride: false
          nextHopIpAddress: nextHopIP
          nextHopType: 'VirtualAppliance'
        }
        type: 'Microsoft.Network/routeTables/routes'
      }
    ]
  }
}
