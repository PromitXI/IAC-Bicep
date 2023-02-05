targetScope= 'subscription'

@description('The Envoirnment of Deployment')
@allowed( [
  'Dev'
  'QA'
  'Prod'
])
param envoirnment string

@description('The Location of The Resource Group and All Other Resources')
param location string

@description('The Name of the Resource Group')
var ResourceGroupName = 'RG-PWB-${envoirnment}-DataPlatform-${location}'
resource resGroup 'Microsoft.Resources/resourceGroups@2022-09-01'={
  location:location
  name:ResourceGroupName
  
}
