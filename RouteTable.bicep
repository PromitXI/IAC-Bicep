@description('Name of the UserDefined Route Table')
param RouteTableName string='PWB-Dev-Traffic-RTable'

@description('Location for all resources.')
param location string 

@description('Route Table Name')
param Routename string ='To-Hub-FW'

resource symbolicname 'Microsoft.Network/routeTables@2022-05-01' = {
  name: RouteTableName
  location: location
  tags: {
    Envoirnment: 'Dev'
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
          nextHopIpAddress: '10.221.0.131'
          nextHopType: 'VirtualAppliance'
        }
        type: 'Microsoft.Network/routeTables/routes'
      }
    ]
  }
}
