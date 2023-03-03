@description('The Azure region into which the resources should be deployed.')
param location string

@secure()
@description('The administrator login username for the SQL server.')
param sqlServerAdministratorLogin string

@secure()
@description('The administrator login password for the SQL server.')
param sqlServerAdministratorLoginPassword string

@description('The name and tier of the SQL database SKU.')
param sqlDatabaseSku object = {
  name: 'Standard'
  tier: 'Standard'
}

@description('The name of the environment. This must be Development/Quality/Production.')
@allowed([
  'Dev'
  'QA'
  'Prod'
])
param envoirnment string

@description('The name of the audit storage account SKU.')
param auditStorageAccountSkuName string = 'Standard_LRS'

@description('The name of the Subnet')
param subnetID string

@description('The Object ID of Vnet')
param VnetId string





//Variables for SQl SERVEr & Storage Accounts
var sqlServerName = take('pwb${envoirnment}${location}${uniqueString(resourceGroup().id)}',14)
var sqlDatabaseName = 'dm_edm_${envoirnment}'
var auditingEnabled = envoirnment == 'Prod'
var auditStorageAccountName = take('pwbaudit${location}${uniqueString(resourceGroup().id)}', 16)


//Variables for Private Endpoint and DNS
var PrivateEndpointName='PE-PWB-SQL-${envoirnment}'
var privateDnsZoneName='privatelink${environment().suffixes.sqlServerHostname}'
var pvtEndpointDnsGroupName='${PrivateEndpointName}/SQLDNSGrp${envoirnment}'

var PrivateEndpointName2='PE2-PWB-SQL-${envoirnment}'
var privateDnsZoneName2='privatelink2${environment().suffixes.sqlServerHostname}'
var pvtEndpointDnsGroupName2='${PrivateEndpointName}/SQLDNSGrp2${envoirnment}'




resource sqlServer 'Microsoft.Sql/servers@2021-11-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: sqlServerAdministratorLogin
    administratorLoginPassword: sqlServerAdministratorLoginPassword
    publicNetworkAccess: 'Disabled'
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2021-11-01-preview' = {
  parent: sqlServer
  name: sqlDatabaseName
  location: location
  sku: sqlDatabaseSku
}

resource auditStorageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = if (auditingEnabled) {
  name: auditStorageAccountName
  location: location
  sku: {
    name: auditStorageAccountSkuName
  }
  kind: 'StorageV2'  
}

resource sqlServerAudit 'Microsoft.Sql/servers/auditingSettings@2021-11-01-preview' = if (auditingEnabled) {
  parent: sqlServer
  name: 'default'
  properties: {
    state: 'Enabled'
    storageEndpoint: envoirnment == 'Prod' ? auditStorageAccount.properties.primaryEndpoints.blob : ''
    storageAccountAccessKey: envoirnment == 'Prod' ? listKeys(auditStorageAccount.id, auditStorageAccount.apiVersion).keys[0].value : ''
  }
}

output serverName string = sqlServer.name
output location string = location
output serverFullyQualifiedDomainName string = sqlServer.properties.fullyQualifiedDomainName


resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: PrivateEndpointName
  location: location
  properties: {
    subnet: {
      id: subnetID
    }
    privateLinkServiceConnections: [
      {
        name: PrivateEndpointName
        properties: {
          privateLinkServiceId: sqlServer.id
          groupIds: [
            'sqlServer'
          ]
        }
      }
    ]
  }
  
}

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDnsZoneName
  location: 'global'
  properties: {}
  
}

resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZone
  name: '${privateDnsZoneName}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: VnetId
    }
  }
}

resource pvtEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  name: pvtEndpointDnsGroupName
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: privateDnsZone.id
        }
      }
    ]
  }
  dependsOn: [
    privateEndpoint
  ]
}
